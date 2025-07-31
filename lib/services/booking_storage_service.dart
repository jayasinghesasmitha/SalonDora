import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookingStorageService {
  static const String _bookingDataKey = 'pending_booking_data';

  // Store booking data when user is not logged in
  static Future<void> storePendingBooking({
    required String salonId,
    required String salonName,
    required String stylistId,
    required String stylistName,
    required List<Map<String, dynamic>> selectedServices,
    required DateTime date,
    required Map<String, dynamic> timeSlot, // Store the actual time slot object
    required int totalDuration,
    required int totalPrice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final bookingData = {
      'salonId': salonId,
      'salonName': salonName,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'selectedServices': selectedServices,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'totalDuration': totalDuration,
      'totalPrice': totalPrice,
      'timestamp': DateTime.now().toIso8601String(), // For cleanup
    };
    
    await prefs.setString(_bookingDataKey, jsonEncode(bookingData));
  }

  // Retrieve stored booking data
  static Future<Map<String, dynamic>?> getPendingBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingDataString = prefs.getString(_bookingDataKey);
    
    if (bookingDataString != null) {
      try {
        final bookingData = jsonDecode(bookingDataString) as Map<String, dynamic>;
        
        // Check if data is not too old (optional - prevent stale data)
        final timestamp = DateTime.parse(bookingData['timestamp']);
        final hoursSinceStored = DateTime.now().difference(timestamp).inHours;
        
        if (hoursSinceStored > 24) {
          // Data is too old, clear it
          await clearPendingBooking();
          return null;
        }
        
        return bookingData;
      } catch (e) {
        // If there's an error parsing, clear the corrupted data
        await clearPendingBooking();
        return null;
      }
    }
    
    return null;
  }

  // Clear stored booking data
  static Future<void> clearPendingBooking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookingDataKey);
  }

  // Check if there's pending booking data
  static Future<bool> hasPendingBooking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_bookingDataKey);
  }
}