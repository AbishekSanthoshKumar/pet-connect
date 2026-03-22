import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/api_service.dart';

class LoginProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<String?> login({
    required String mobileNumber,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('login', {
        'mobileNumber': mobileNumber,
        'password': password,
        'role': role.toLowerCase(),
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        _apiService.setAuthToken(token);
        _isLoading = false;
        notifyListeners();
        return role; // Return role on success
      }
    } on DioError catch (e) {
      _errorMessage = e.response?.data['message'] ?? e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    }

    _isLoading = false;
    notifyListeners();
    return null; // Return null on failure
  }
}
