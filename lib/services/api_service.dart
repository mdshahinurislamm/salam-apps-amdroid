import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/banner_model.dart';

class ApiService {
  static const String _baseUrl = 'https://larapress.org/salam/api';

  late final Dio _authDio;

  ApiService() {
    _authDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String age,
    required String country,
    int role = 1,
  }) async {
    try {
      final res = await _authDio.post('/signup', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'age': age,
        'country': country,
        'role': role,
      });

      final body = res.data as Map<String, dynamic>;
      final message = (body['message'] ?? '').toString().toLowerCase();

      if (message.contains('already') || message.contains('exist')) {
        throw 'emailAlreadyExists';
      }

      if (body['id'] != null) {
        return UserModel.fromJson(body);
      }

      return UserModel(
        id: 0,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role.toString(),
        age: age,
      );
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _authDio.post('/signin', data: {
        'email': email,
        'password': password,
      });

      final body = res.data as Map<String, dynamic>;

      // Server returns success:false when email not verified
      if (body['success'] == false) {
        final msg = (body['message'] ?? '').toString().toLowerCase();
        if (msg.contains('verify') || msg.contains('verified')) {
          throw 'emailNotVerified';
        }
        throw body['message']?.toString() ?? 'loginFailed';
      }

      // Wrong credentials — server returns message with no id
      if (body['id'] == null) {
        final msg = (body['message'] ?? '').toString().toLowerCase();
        if (msg.contains('incorrect') || msg.contains('invalid') || msg.contains('username')) {
          throw 'invalidCredentials';
        }
        throw msg.isNotEmpty ? msg : 'loginFailed';
      }

      return UserModel.fromJson(body);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── OTP Verification ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _authDio.post('/verifyotp', data: {
        'email': email,
        'otp': otp,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<List<PostModel>> fetchPosts() async {
    try {
      final res = await _authDio.get('/posts');
      final data = res.data;
      final List<dynamic> list =
          data is Map ? (data['data'] as List<dynamic>) : data as List<dynamic>;
      return list
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Banners ───────────────────────────────────────────────────────────────

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final res = await _authDio.get('/banners');
      final data = res.data;
      final List<dynamic> list =
          data is Map ? (data['data'] as List<dynamic>) : data as List<dynamic>;
      return list
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── PDF ──────────────────────────────────────────────────────────────────

  Future<Uint8List> fetchPdfBytes(String pdfUrl) async {
    try {
      final res = await Dio().get(
        pdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status < 500,
          headers: {'Accept': 'application/pdf,*/*'},
        ),
      );
      if (res.statusCode != 200) throw 'serverError:${res.statusCode}';
      final bytes = res.data as List<int>;
      if (bytes.isEmpty) throw 'emptyResponse';
      return Uint8List.fromList(bytes);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }



  // ── Profile ───────────────────────────────────────────────────────────────

  /// GET /profile  — requires Bearer token
  Future<UserModel> getProfile({required String token}) async {
    try {
      final res = await _authDio.get(
        '/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = res.data as Map<String, dynamic>;
      final data = body['data'] ?? body;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// POST /profile/update  — requires Bearer token
  Future<UserModel> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String age,
    required String country,
  }) async {
    try {
      final res = await _authDio.post(
        '/profile/update',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'age': age,
          'country': country,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = res.data as Map<String, dynamic>;
      if (body['success'] == false) {
        throw body['message']?.toString() ?? 'updateFailed';
      }
      final data = body['data'] ?? body;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// POST /profile/changepassword  — requires Bearer token
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final res = await _authDio.post(
        '/profile/changepassword',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = res.data as Map<String, dynamic>;
      if (body['success'] == false) {
        final msg = (body['message'] ?? '').toString().toLowerCase();
        if (msg.contains('incorrect')) throw 'wrongCurrentPassword';
        throw body['message']?.toString() ?? 'changeFailed';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data is Map) {
          final msg = (data['message'] ?? '').toString().toLowerCase();
          if (msg.contains('incorrect')) throw 'wrongCurrentPassword';
        }
      }
      throw _parseError(e);
    }
  }

  /// POST /profile/delete  — requires Bearer token
  Future<void> deleteProfile({required String token}) async {
    try {
      final res = await _authDio.post(
        '/profile/delete',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = res.data as Map<String, dynamic>;
      if (body['success'] == false) {
        throw body['message']?.toString() ?? 'deleteFailed';
      }
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    try {
      final res = await _authDio.post('/forgotpassword', data: {'email': email});
      final body = res.data as Map<String, dynamic>;
      if (body['status'] == false) {
        final msg = (body['message'] ?? '').toString().toLowerCase();
        if (msg.contains('not found')) throw 'userNotFound';
        throw body['message']?.toString() ?? 'requestFailed';
      }
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _authDio.post('/verifyresetotp', data: {
        'email': email,
        'otp': otp,
      });
      final body = res.data as Map<String, dynamic>;
      if (body['status'] == false) {
        final msg = (body['message'] ?? '').toString().toLowerCase();
        if (msg.contains('expired')) throw 'otpExpired';
        throw 'invalidOtp';
      }
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final res = await _authDio.post('/resetpassword', data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      final body = res.data as Map<String, dynamic>;
      if (body['status'] == false) {
        throw body['message']?.toString() ?? 'resetFailed';
      }
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Error helper ─────────────────────────────────────────────────────────

  String _parseError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'timeoutError';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'networkError';
    }
    final status = e.response?.statusCode;
    if (status == 500) return 'serverError:500';
    if (status == 404) return 'serverError:404';
    if (status == 401) return 'unauthorizedError';
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'networkError';
  }
}
