import 'dart:io';
import 'package:dio/dio.dart';
import 'package:book_my_salon/services/auth_service.dart';

class SalonService {
  static SalonService? _instance;
  late Dio _dio;

  // Singleton pattern
  factory SalonService() {
    _instance ??= SalonService._internal();
    return _instance!;
  }

  SalonService._internal() {
    // Use the same Dio instance from AuthService to share cookies
    _dio = AuthService().dio;
  }

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api'; // iOS simulator
    } else {
      return 'http://localhost:3000/api'; // Web/Desktop
    }
  }

  // Get all salons with automatic token refresh
  Future<List<Map<String, dynamic>>> getAllSalons() async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await _dio.get(
        '$baseUrl/salons',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        // Token expired, try to refresh
        try {
          await AuthService().refreshAccessToken();
          return getAllSalons(); // Retry with new token
        } catch (refreshError) {
          throw Exception('Authentication failed: Please login again');
        }
      }
      throw Exception('Error fetching salons: $e');
    }
  }

  // Search salons by name with automatic token refresh
  Future<List<Map<String, dynamic>>> searchSalonsByName(String name) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await _dio.get(
        '$baseUrl/salons/name/${Uri.encodeComponent(name)}',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        // Token expired, try to refresh
        try {
          await AuthService().refreshAccessToken();
          return searchSalonsByName(name); // Retry with new token
        } catch (refreshError) {
          throw Exception('Authentication failed: Please login again');
        }
      }
      throw Exception('Error searching salons: $e');
    }
  }
}