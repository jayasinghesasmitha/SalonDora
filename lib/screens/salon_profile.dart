import 'package:flutter/material.dart';
import 'package:book_my_salon/services/salon_service.dart';
import 'booking_screen.dart';

class SalonProfile extends StatefulWidget {
  final String salonId;
  final String salonName;

  const SalonProfile({
    required this.salonId,
    required this.salonName,
    super.key,
  });

  @override
  _SalonProfileState createState() => _SalonProfileState();
}

class _SalonProfileState extends State<SalonProfile> {
  late PageController _pageController;
  Map<String, dynamic>? salonData;
  List<Map<String, dynamic>> services = [];
  Map<String, bool> selectedServices = {};
  bool isLoading = true;
  String? error;

  int get totalCost => selectedServices.entries
      .where((e) => e.value)
      .map(
        (e) =>
            services.firstWhere((s) => s['service_name'] == e.key)['price']
                as int,
      )
      .fold(0, (a, b) => a + b);

  int get totalDuration => selectedServices.entries
      .where((e) => e.value)
      .map(
        (e) =>
            services.firstWhere(
                  (s) => s['service_name'] == e.key,
                )['duration_minutes']
                as int,
      )
      .fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.7, // 70% of width for current image
    );
    _loadSalonData();
  }

  Future<void> _loadSalonData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Fetch salon details and services in parallel
      final results = await Future.wait([
        SalonService().getSalonById(widget.salonId),
        SalonService().getSalonServices(widget.salonId),
      ]);

      setState(() {
        salonData = results[0] as Map<String, dynamic>;
        services = results[1] as List<Map<String, dynamic>>;

        // Initialize selected services map
        selectedServices = {
          for (var service in services)
            service['service_name'] as String: false,
        };

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(onPressed: _loadSalonData, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    // Extract banner images
    final List<String> bannerImages = salonData?['banner_images'] != null
        ? (salonData!['banner_images'] as List)
              .map((img) => img['image_link']?.toString())
              .where((link) => link != null && link!.isNotEmpty)
              .cast<String>()
              .toList()
        : ['https://placehold.co/300x200'];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Center(
                child: Text(
                  "VIVORA",
                  style: TextStyle(
                    fontFamily: 'VivoraFont',
                    fontSize: 28,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: salonData?['salon_logo_link'] != null
                        ? Image.network(
                            salonData!['salon_logo_link'],
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.store,
                                size: 50,
                                color: Colors.grey,
                              );
                            },
                          )
                        : Icon(Icons.store, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonData?['salon_name'] ?? widget.salonName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                salonData?['salon_address'] ?? "Colombo",
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (salonData?['average_rating'] != null)
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                salonData!['average_rating'].toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Horizontal Scrollable Image Gallery
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: bannerImages.length,
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.hasPixels) {
                          final currentPage = _pageController.page ?? 0.0;
                          value = currentPage - index;
                          value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                        }
                        return Transform.scale(
                          scale: Curves.easeInOut.transform(value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                bannerImages[index],
                                fit: BoxFit.cover,
                                width: 200,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    child: Center(child: Text('Image Error')),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Services",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Dynamic services from API
              if (services.isEmpty)
                Text('No services available')
              else
                ...services.map((service) {
                  final serviceName = service['service_name'] as String;
                  final price = service['price'] as int;
                  final duration = service['duration_minutes'] as int;

                  return CheckboxListTile(
                    title: Text(serviceName),
                    subtitle: Text('Rs $price • ${duration} min'),
                    value: selectedServices[serviceName] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedServices[serviceName] = value ?? false;
                      });
                    },
                  );
                }),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Duration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "${(totalDuration / 60).toStringAsFixed(1)} hours",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Rs $totalCost",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: selectedServices.values.contains(true)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              salonName:
                                  salonData?['salon_name'] ?? widget.salonName,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  "Proceed",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
