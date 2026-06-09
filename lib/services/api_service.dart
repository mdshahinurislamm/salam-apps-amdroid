import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class ApiService {
  static const String _baseUrl = 'https://larapress.org/salam/api';

  late final Dio _authDio;
  late final Dio _fileDio;

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

    _fileDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/pdf,*/*',
        },
      ),
    );
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<UserModel> register({
    required String firstName,
    required String email,
    required String password,
    required String age,
    required String country,
    int role = 1,
  }) async {
    try {
      final res = await _authDio.post('/signup', data: {
        'first_name': firstName,
        'email': email,
        'password': password,
        'age': age,
        'country': country,
        'role': role,
      });

      final body = res.data as Map<String, dynamic>;
      final message = (body['message'] ?? '').toString().toLowerCase();

      // Server signals duplicate email
      if (message.contains('already') || message.contains('exist')) {
        throw 'emailAlreadyExists';
      }

      // Server returned full user object (id present) — parse directly
      if (body['id'] != null) {
        return UserModel.fromJson(body);
      }

      // Server returned only {"message": "User account created."} —
      // build a minimal UserModel from what we know so the app can proceed.
      return UserModel(
        id: 0,
        firstName: firstName,
        lastName: '',
        email: email,
        role: role.toString(),
        age: age,
      );
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _authDio.post('/signin', data: {
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(res.data as Map<String, dynamic>);
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

      if (res.statusCode != 200) {
        throw 'serverError:${res.statusCode}';
      }
      final bytes = res.data as List<int>;
      if (bytes.isEmpty) throw 'emptyResponse';
      return Uint8List.fromList(bytes);
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
