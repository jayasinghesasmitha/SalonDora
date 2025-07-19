import 'package:http/http.dart' as http;
import 'dart:convert';

class SalonService {
  static const String apiUrl = 'https://your-api-endpoint.com/salons';

  static Future<List<Map<String, dynamic>>> fetchSalons() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load salons');
    }
  }
}