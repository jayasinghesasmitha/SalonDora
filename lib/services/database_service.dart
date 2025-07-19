import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_my_saloon/models/booking_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new booking
  Future<void> addBooking(Booking booking) async {
    try {
      await _firestore.collection('bookings').add({
        'userId': booking.userId,
        'saloonName': booking.saloonName,
        'service': booking.service,
        'date': booking.date,
        'time': booking.time.toString(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
    }
  }

  // Get user bookings
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}