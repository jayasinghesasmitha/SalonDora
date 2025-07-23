import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Replace with your actual backend URL
  
  // Login with email and password
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store tokens in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['session']['access_token']);
        await prefs.setString('refresh_token', data['session']['refresh_token']);
        await prefs.setString('user_role', data['customRole']);
        
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Register with email, password and additional data
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? salonName,
    String? salonAddress,
    String? dateOfBirth,
    Map<String, double>? location,
    String? contactNumber,
    String? salonDescription,
    String? salonLogoLink,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
        'role': role,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (salonName != null) 'salon_name': salonName,
        if (salonAddress != null) 'salon_address': salonAddress,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (location != null) 'location': location,
        if (contactNumber != null) 'contact_number': contactNumber,
        if (salonDescription != null) 'salon_description': salonDescription,
        if (salonLogoLink != null) 'salon_logo_link': salonLogoLink,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final token = await getAccessToken();
      
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Clear stored tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_role');
    } catch (e) {
      // Still clear local tokens even if backend call fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_role');
      throw Exception('Logout error: $e');
    }
  }

  // Get current user token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Refresh access token
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Update stored tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['session']['access_token']);
        await prefs.setString('refresh_token', data['session']['refresh_token']);
        
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Token refresh failed');
      }
    } catch (e) {
      throw Exception('Token refresh error: $e');
    }
  }

  // Get current user info (you'll need to create this endpoint on your backend)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/user'), // You'll need to create this endpoint
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Token might be expired, try to refresh
        try {
          await refreshAccessToken();
          return getCurrentUser(); // Retry with new token
        } catch (e) {
          await signOut(); // Clear invalid tokens
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}