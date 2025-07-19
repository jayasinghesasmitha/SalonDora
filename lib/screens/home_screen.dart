import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:book_my_saloon/utils/colors.dart';
import 'package:book_my_saloon/utils/styles.dart';
import 'package:book_my_saloon/widgets/saloon_card.dart';
import 'package:book_my_saloon/screens/salon_profile.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  latLng.LatLng? _currentLocation;
  bool _isLoading = true;
  final List<Map<String, dynamic>> _allSalons = [
    {
      'name': 'Salon Senasha',
      'latitude': 6.7951 + 0.006, // ~666 m north
      'longitude': 79.9009,
      'address': 'North of University, Moratuwa',
      'hours': '8:00 am to 10:00 pm'
    },
    {
      'name': 'Dilianka Salon',
      'latitude': 6.7951,
      'longitude': 79.9009 + 0.007, // ~595 m east
      'address': 'East of University, Moratuwa',
      'hours': '8:00 am to 10:00 pm'
    },
    {
      'name': 'Style Studio',
      'latitude': 6.7951 - 0.006, // ~666 m south
      'longitude': 79.9009,
      'address': 'South of University, Moratuwa',
      'hours': '8:00 am to 10:00 pm'
    },
    {
      'name': "Dee's Hair Bea & Bridal Salon",
      'latitude': 6.7951,
      'longitude': 79.9009 - 0.007, // ~595 m west
      'address': 'West of University, Moratuwa',
      'hours': '8:00 am to 10:00 pm'
    },
    {
      'name': 'Salon Sithru',
      'latitude': 6.7951 + 0.004, // ~444 m northeast
      'longitude': 79.9009 + 0.005, // ~425 m east
      'address': 'Northeast of University, Moratuwa',
      'hours': '8:00 am to 10:00 pm'
    },
  ];

  List<Map<String, dynamic>> _nearbySalons = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialLocation();
  }

  Future<void> _fetchInitialLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleLocationError();
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _handleLocationError();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = latLng.LatLng(position.latitude, position.longitude);
        _nearbySalons = _filterNearbySalons(_currentLocation!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _handleLocationError();
    }
  }

  void _handleLocationError() {
    setState(() {
      _currentLocation = latLng.LatLng(6.9271, 79.8612); // Default to Colombo
      _nearbySalons = _filterNearbySalons(_currentLocation!);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _filterNearbySalons(latLng.LatLng currentLocation) {
    return _allSalons.where((salon) {
      final salonLocation = latLng.LatLng(salon['latitude'], salon['longitude']);
      final distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        salonLocation.latitude,
        salonLocation.longitude,
      );
      return distance <= 2000; // Filter salons within 2 km (adjust as needed)
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VIVORA', style: AppStyles.appBarStyle),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search a Salon...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 2,
                    child: FlutterMap(
                      options: MapOptions(
                        center: _currentLocation ?? latLng.LatLng(6.9271, 79.8612),
                        zoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.book_my_saloon',
                        ),
                        MarkerLayer(
                          markers: [
                            if (_currentLocation != null)
                              Marker(
                                point: _currentLocation!,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                              ),
                            ..._nearbySalons.map((salon) => Marker(
                                  point: latLng.LatLng(salon['latitude'], salon['longitude']),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SalonProfile(salonName: salon['name']),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 30.0,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nearby Saloons',
                    style: AppStyles.sectionHeadingStyle,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: _nearbySalons.length,
                      itemBuilder: (context, index) {
                        final salon = _nearbySalons[index];
                        return SaloonCard(
                          name: salon['name'],
                          address: salon['address'],
                          hours: salon['hours'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SalonProfile(salonName: salon['name']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}