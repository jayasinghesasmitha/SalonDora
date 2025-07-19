import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Booking {
  final String? id;
  final String userId;
  final String saloonName;
  final String service;
  final DateTime date;
  final TimeOfDay time;
  final Timestamp? createdAt;

  Booking({
    this.id,
    required this.userId,
    required this.saloonName,
    required this.service,
    required this.date,
    required this.time,
    this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    final timeParts = (data['time'] as String).split(':');
    return Booking(
      id: id,
      userId: data['userId'] as String,
      saloonName: data['saloonName'] as String,
      service: data['service'] as String,
      date: (data['date'] as Timestamp).toDate(),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'saloonName': saloonName,
      'service': service,
      'date': date,
      'time': '${time.hour}:${time.minute}',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}