// lib/data/auth/auth_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api_constants.dart';

class AuthRepository {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Step 1: Create a Request Token
  Future<String?> createRequestToken() async {
    try {
      final response = await _dio.get(
        ApiConstants.requestTokenUrl,
        queryParameters: {'api_key': ApiConstants.tmdbApiKey},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['request_token'];
      }
    } on DioException catch (e) {
      print("Error creating request token: ${e.response?.data}");
    }
    return null;
  }

  // Step 3: Create a Session ID
  Future<bool> createSession(String requestToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.createSessionUrl,
        queryParameters: {'api_key': ApiConstants.tmdbApiKey},
        data: {'request_token': requestToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final sessionId = response.data['session_id'];
        await _secureStorage.write(key: 'session_id', value: sessionId);
        return true;
      }
    } on DioException catch (e) {
      print("Error creating session: ${e.response?.data}");
    }
    return false;
  }

  // Helper function to check if a session exists
  Future<bool> hasSession() async {
    final sessionId = await _secureStorage.read(key: 'session_id');
    return sessionId != null;
  }

  // Helper function to delete the session (logout)
  Future<void> deleteSession() async {
    await _secureStorage.delete(key: 'session_id');
  }
}
