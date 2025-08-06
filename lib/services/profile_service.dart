import 'dart:io';
import 'package:dio/dio.dart';
import 'package:book_my_salon/services/auth_service.dart';

class ProfileService {
  static ProfileService? _instance;
  late Dio _dio;

  // Singleton pattern
  factory ProfileService() {
    _instance ??= ProfileService._internal();
    return _instance!;
  }

  ProfileService._internal() {
    _dio = Dio();
  }

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/profile';
    } else {
      return 'http://localhost:3000/api/profile';
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await _dio.get(
        baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        // Token expired, try to refresh
        try {
          await AuthService().refreshAccessToken();
          return getUserProfile(); // Retry with new token
        } catch (refreshError) {
          throw Exception('Authentication failed: Please login again');
        }
      }
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Bad request: ${e.response?.data['error'] ?? 'Invalid request'}');
      }
      if (e is DioException && e.response?.statusCode == 500) {
        throw Exception('Server error: ${e.response?.data['error'] ?? 'Internal server error'}');
      }
      throw Exception('Error fetching profile: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? contactNumber,
    String? location,
  }) async {
    try {
      final token = await AuthService().getAccessToken();

      // Prepare user data (email only)
      final Map<String, dynamic> userData = {};
      if (email != null && email.isNotEmpty) {
        userData['email'] = email;
      }

      // Prepare customer data
      final Map<String, dynamic> customerData = {};
      if (firstName != null && firstName.isNotEmpty) {
        customerData['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        customerData['last_name'] = lastName;
      }
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        customerData['date_of_birth'] = dateOfBirth;
      }
      if (contactNumber != null && contactNumber.isNotEmpty) {
        customerData['contact_number'] = contactNumber;
      }
      if (location != null && location.isNotEmpty) {
        customerData['location'] = location;
      }

      // Create request body
      final Map<String, dynamic> requestBody = {};
      if (userData.isNotEmpty) {
        requestBody['userData'] = userData;
      }
      if (customerData.isNotEmpty) {
        requestBody['customerData'] = customerData;
      }

      if (requestBody.isEmpty) {
        throw Exception('No data provided to update');
      }

      final response = await _dio.put(
        baseUrl,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        // Token expired, try to refresh
        try {
          await AuthService().refreshAccessToken();
          return updateUserProfile(
            email: email,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            contactNumber: contactNumber,
            location: location,
          );
        } catch (refreshError) {
          throw Exception('Authentication failed: Please login again');
        }
      }
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('${e.response?.data['error'] ?? 'Invalid profile data'}');
      }
      if (e is DioException && e.response?.statusCode == 500) {
        throw Exception('Server error: ${e.response?.data['error'] ?? 'Internal server error'}');
      }
      throw Exception('Error updating profile: $e');
    }
  }
}