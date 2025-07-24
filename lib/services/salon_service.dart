import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:book_my_saloon/services/auth_service.dart';

class SalonService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api'; // iOS simulator
    } else {
      return 'http://localhost:3000/api'; // Web/Desktop
    }
  }

  // Get all salons
  Future<List<Map<String, dynamic>>> getAllSalons() async {
    try {
      final token = await AuthService().getAccessToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/salons'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch salons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching salons: $e');
    }
  }

  // Search salons by name
  Future<List<Map<String, dynamic>>> searchSalonsByName(String name) async {
    try {
      final token = await AuthService().getAccessToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/salons/name/${Uri.encodeComponent(name)}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search salons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching salons: $e');
    }
  }
}