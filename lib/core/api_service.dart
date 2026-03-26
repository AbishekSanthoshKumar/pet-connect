import 'package:dio/dio.dart';

class ApiServices {
  final Dio _dio = Dio();

  // Replace with your API base URL
  final String _baseUrl = 'https://api.example.com/';
  String? _token;

  ApiServices() {
    _dio.options.baseUrl = _baseUrl;
  }

  void setAuthToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $_token';
  }

  void clearAuthToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<Response> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response;
    } on DioException catch (e) {
      // Handle DioError here
      throw Exception('Failed to load data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  Future<Response> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      // Handle DioError here
      throw Exception('Failed to post data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to post data');
    }
  }
}
