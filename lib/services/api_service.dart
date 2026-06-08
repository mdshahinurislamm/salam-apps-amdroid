import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/user_model.dart';

class ApiService {
  // ── Your live server ──────────────────────────────────────────────────────
  static const String _baseUrl = 'https://larapress.org/salam/api';
  // ─────────────────────────────────────────────────────────────────────────

  late final Dio _authDio;   // for JSON auth endpoints
  late final Dio _fileDio;   // for binary/file endpoints (no Content-Type override)

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
        // No Content-Type header — let Dio set it naturally for file downloads
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
    int role = 1,
  }) async {
    try {
      final res = await _authDio.post('/signup', data: {
        'first_name': firstName,
        'email': email,
        'password': password,
        'role': role,
      });
      return UserModel.fromJson(res.data as Map<String, dynamic>);
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

  // ── PDF ──────────────────────────────────────────────────────────────────

  /// Downloads the PDF bytes for the given language ('en' or 'ar').
  /// Calls: GET /api/pdf?lang=en  or  GET /api/pdf?lang=ar
  Future<Uint8List> fetchPdf(String languageCode) async {
    try {
      final res = await _fileDio.get(
        '/pdf',
        queryParameters: {'lang': languageCode},
        options: Options(
          responseType: ResponseType.bytes,
          // Follow redirects (some servers redirect to the actual file)
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (res.statusCode != 200) {
        throw 'serverError:${res.statusCode}';
      }

      final bytes = res.data as List<int>;
      if (bytes.isEmpty) {
        throw 'emptyResponse';
      }

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
