import 'package:flutter/material.dart';
import 'package:book_my_salon/screens/auth/login_screen.dart';

class BookingScreen extends StatefulWidget {
  final String salonName;

  const BookingScreen({Key? key, required this.salonName}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedEmployee = 'Any';
  String selectedDate = '18';
  List<String> selectedTimeSlots = [];
  bool isConfirmed = false;

  // Employee data with their available time slots per date
  final Map<String, Map<String, List<String>>> employeeSlots = {
    'Kamal': {
      '18': ['9:00', '9:30', '10:00'],
      '19': ['9:00', '9:30', '10:00'],
      '20': ['9:00', '9:30', '10:00'],
      for (int i = 1; i <= 31; i++)
        if (i != 20) '$i': ['9:00', '9:30', '10:00'],
    },
    'Vimal': {
      '18': ['11:00', '11:30', '12:00'],
      '19': ['11:00', '11:30', '12:00'],
      '20': ['11:00', '11:30', '12:00'],
      for (int i = 1; i <= 31; i++)
        if (i != 20) '$i': ['11:00', '11:30', '12:00'],
    },
    'Sunil': {
      '18': ['15:00', '16:00'],
      '19': ['15:00', '16:00'],
      '20': ['15:00'], // Removed 16:00 slot for 20th
      for (int i = 1; i <= 31; i++)
        if (i != 20) '$i': ['15:00', '16:00'],
    },
  };

  // Pricing logic (example: Rs 500 per time slot)
  int get totalPrice => selectedTimeSlots.length * 500;

  @override
  Widget build(BuildContext context) {
    List<String> availableSlots = [];
    if (selectedEmployee == 'Any') {
      employeeSlots.forEach((_, dateSlots) {
        availableSlots.addAll(dateSlots[selectedDate] ?? []);
      });
    } else {
      availableSlots = employeeSlots[selectedEmployee]?[selectedDate] ?? [];
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // VIVORA Logo
            Text(
              'VIVORA',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                // Using a similar font (replace with actual font if available)
                fontFamily: 'Roboto', // Placeholder font, adjust as needed
              ),
            ),
            SizedBox(height: 20),
            // Salon Name
            Text(
              widget.salonName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Date Selection with Horizontal Scroll
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 31,
                itemBuilder: (context, index) {
                  final date = (index + 1).toString();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                        selectedTimeSlots.clear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: selectedDate == date
                                ? Colors.black
                                : Colors.grey,
                            child: Text(
                              date,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('July'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Employee Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmployeeButton('Any'),
                _buildEmployeeButton('Kamal'),
                _buildEmployeeButton('Vimal'),
                _buildEmployeeButton('Sunil'),
              ],
            ),
            SizedBox(height: 20),
            // Time Slots
            Expanded(
              child: ListView.builder(
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (selectedTimeSlots.contains(
                            availableSlots[index],
                          )) {
                            selectedTimeSlots.remove(availableSlots[index]);
                          } else {
                            selectedTimeSlots.add(availableSlots[index]);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedTimeSlots.contains(availableSlots[index])
                            ? Colors.grey[500] // Ash color for selected slots
                            : Colors
                                  .grey[200], // Ash color for unselected slots
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        availableSlots[index],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Booking Details Section
            if (selectedTimeSlots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Employee: ${selectedEmployee}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Text(
                      'Date: ${selectedDate} July 2025',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Text(
                      'Time Slots: ${selectedTimeSlots.join(', ')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Text(
                      'Total Price: Rs $totalPrice',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            // Confirm Button
            ElevatedButton(
              onPressed: selectedTimeSlots.isNotEmpty && !isConfirmed
                  ? () {
                      setState(() {
                        isConfirmed = true;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                // Disable button when onPressed is null
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeButton(String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmployee = name;
          selectedTimeSlots.clear();
        });
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'images/placeholder.png',
              fit: BoxFit.cover,
              width: 50,
              height: 50,
            ),
          ),
          SizedBox(height: 5),
          Text(name),
        ],
      ),
    );
  }
}
