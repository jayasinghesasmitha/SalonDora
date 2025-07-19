import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_my_saloon/screens/home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String saloonName;
  final String
  service; // This should be a comma-separated string of selected services
  final DateTime date;
  final TimeOfDay time;
  final String selectedEmployee; // Add employee parameter
  final List<String> selectedTimeSlots; // Add time slots parameter

  const BookingConfirmationScreen({
    Key? key,
    required this.saloonName,
    required this.service,
    required this.date,
    required this.time,
    required this.selectedEmployee,
    required this.selectedTimeSlots,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse selected services
    final List<String> selectedServices = service.split(', ');

    // Service details (should match salon_profile.dart)
    final Map<String, double> servicePrices = {
      "Hair Cutting and Shaving": 100,
      "Oil Massage": 200,
      "Beard Trimming": 300,
    };

    final Map<String, int> serviceDurations = {
      "Hair Cutting and Shaving": 60, // minutes
      "Oil Massage": 120,
      "Beard Trimming": 180,
    };

    // Calculate totals
    double totalPrice = selectedServices.fold(
      0,
      (sum, service) => sum + (servicePrices[service] ?? 0),
    );
    int totalDuration = selectedServices.fold(
      0,
      (sum, service) => sum + (serviceDurations[service] ?? 0),
    );

    // Format date and time
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);
    final startTime = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${time.hour + (time.minute + totalDuration) ~/ 60}:${(time.minute + totalDuration) % 60}'
            .padLeft(2, '0');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                'VIVORA',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Confirmation Icon
            Center(
              child: Icon(Icons.check_circle, color: Colors.green, size: 80),
            ),
            SizedBox(height: 10),

            // Confirmation Text
            Center(
              child: Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),

            // Salon Info Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'images/salon.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                saloonName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Colombo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Services Section
                    Text(
                      'Services Booked:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...selectedServices
                        .map(
                          (service) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(service),
                                Text(
                                  'Rs ${servicePrices[service]?.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Booking Details Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Employee
                    _buildDetailRow('Employee', selectedEmployee),
                    SizedBox(height: 8),

                    // Date
                    _buildDetailRow('Date', formattedDate),
                    SizedBox(height: 8),

                    // Time Slot
                    _buildDetailRow(
                      'Time Slot',
                      '$startTime - $endTime (${totalDuration} mins)',
                    ),
                    SizedBox(height: 8),

                    // Payment Method
                    _buildDetailRow('Payment Method', 'Pay at Salon'),
                    SizedBox(height: 16),

                    // Total Price
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Rs ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Action Buttons
            Column(
              children: [ 
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('BACK TO HOME'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
