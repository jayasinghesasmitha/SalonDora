import 'package:flutter/material.dart';
import 'package:book_my_salon/screens/current_booking.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({Key? key}) : super(key: key);

  @override
  _BookingHistoryState createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  final List<Map<String, dynamic>> bookings = [
    {
      'salonName': 'Liyo Salon',
      'location': 'Colombo',
      'services': ['Hair Cutting and Shaving', 'Oil Massage', 'Beard Trimming'],
      'date': '27 July 2025',
      'timeSlot': '10:00 am - 10:45 am',
      'price': 'Rs 1700',
      'rating': 0.0, // Initialize rating as 0
      'isRated': false, // Track if rating is finalized
    },
    {
      'salonName': 'Liyo Salon',
      'location': 'Colombo',
      'services': ['Hair Cutting and Shaving', 'Oil Massage', 'Beard Trimming'],
      'date': '27 July 2025',
      'timeSlot': '10:00 am - 10:45 am',
      'price': 'Rs 1700',
      'rating': 0.0, // Initialize rating as 0
      'isRated': false, // Track if rating is finalized
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUnratedBookingsPopup();
    });
  }

  void _showUnratedBookingsPopup() {
    final unratedCount = bookings
        .where((booking) => booking['rating'] == 0.0)
        .length;
    if (unratedCount > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Unrated Bookings',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(
              'You have $unratedCount unrated booking(s). Please rate them!',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200], // Ash variant
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.black)),
              ),
            ],
            backgroundColor: Colors.white,
          );
        },
      );
    }
  }

  void _setRating(int index, double rating) {
    setState(() {
      bookings[index]['rating'] = rating;
    });
  }

  void _confirmRating(int index) {
    setState(() {
      bookings[index]['isRated'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VIVORA',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    color: Colors.grey[200], // Ash variant for block background
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'images/salon_image.jpg',
                                    height: 50,
                                    width: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ); // Keep red for error
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${booking['salonName']} • ${booking['location']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ...booking['services'].map<Widget>(
                                        (service) => Text(
                                          service,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ), // Ash variant
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                booking['price'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            booking['date'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking['timeSlot'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'Rate Us: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (!booking['isRated']) ...[
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return GestureDetector(
                                      onTap: () {
                                        _setRating(
                                          index,
                                          (starIndex + 1).toDouble(),
                                        );
                                      },
                                      child: Icon(
                                        Icons.star,
                                        color: starIndex < booking['rating']
                                            ? Colors.amber
                                            : Colors
                                                  .grey[400], // Ash variant for unselected stars
                                        size: 24,
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: booking['rating'] > 0
                                      ? () {
                                          _confirmRating(index);
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .white, // White background for "Rate" button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Rate',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ] else ...[
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      Icons.star,
                                      color: starIndex < booking['rating']
                                          ? Colors.amber
                                          : Colors
                                                .grey[400], // Ash variant for unselected stars
                                      size: 24,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Rating: ${booking['rating'].toInt()} stars',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .black, // Changed from teal to black
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CurrentBooking()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // Ash variant
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Bookings',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
