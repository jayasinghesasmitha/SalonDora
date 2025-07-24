import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:book_my_saloon/utils/colors.dart';
import 'package:book_my_saloon/utils/styles.dart';
import 'package:book_my_saloon/widgets/saloon_card.dart';
import 'package:book_my_saloon/screens/salon_profile.dart';
import 'package:book_my_saloon/screens/auth/login_screen.dart';
import 'package:book_my_saloon/services/auth_service.dart';
import 'package:book_my_saloon/services/salon_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  latLng.LatLng? _currentLocation;
  bool _isLoading = true;
  bool _isSearching = false;
  
  List<Map<String, dynamic>> _allSalons = [];
  List<Map<String, dynamic>> _displayedSalons = [];
  
  final TextEditingController _searchController = TextEditingController();
  final SalonService _salonService = SalonService();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchInitialLocation(),
      _fetchAllSalons(),
    ]);
  }

  Future<void> _fetchAllSalons() async {
    try {
      final salons = await _salonService.getAllSalons();
      setState(() {
        _allSalons = salons;
        _displayedSalons = salons;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading salons: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _searchSalons(String query) async {
    if (query.isEmpty) {
      setState(() {
        _displayedSalons = _allSalons;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final searchResults = await _salonService.searchSalonsByName(query);
      setState(() {
        _displayedSalons = searchResults;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      _isLoading = false;
    });
  }

  // Helper method to get salon location from API data
  latLng.LatLng? _getSalonLocation(Map<String, dynamic> salon) {
    // Assuming your backend returns location data in a specific format
    // Adjust this based on your actual API response structure
    if (salon['location'] != null) {
      // If location is stored as a string like "POINT(lng lat)"
      final locationStr = salon['location'].toString();
      final regex = RegExp(r'POINT\(([^\s]+)\s([^\)]+)\)');
      final match = regex.firstMatch(locationStr);
      if (match != null) {
        final lng = double.tryParse(match.group(1) ?? '');
        final lat = double.tryParse(match.group(2) ?? '');
        if (lng != null && lat != null) {
          return latLng.LatLng(lat, lng);
        }
      }
    }
    
    // Fallback if location parsing fails
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book My Saloon', style: AppStyles.appBarStyle),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
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
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search a Salon...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _isSearching 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: Icon(_searchController.text.isEmpty 
                              ? Icons.search 
                              : Icons.clear),
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                _searchController.clear();
                                _searchSalons('');
                              }
                            },
                          ),
                    ),
                    onChanged: (value) {
                      // Debounce search to avoid too many API calls
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value) {
                          _searchSalons(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Map
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
                            // Current location marker
                            if (_currentLocation != null)
                              Marker(
                                point: _currentLocation!,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                              ),
                            // Salon markers
                            ..._displayedSalons.map((salon) {
                              final salonLocation = _getSalonLocation(salon);
                              if (salonLocation == null) return null;
                              
                              return Marker(
                                point: salonLocation,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SalonProfile(
                                          salonName: salon['salon_name'] ?? 'Unknown Salon'
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 30.0,
                                  ),
                                ),
                              );
                            }).where((marker) => marker != null).cast<Marker>(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Section heading
                  Text(
                    _searchController.text.isEmpty 
                      ? 'All Salons' 
                      : 'Search Results (${_displayedSalons.length})',
                    style: AppStyles.sectionHeadingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Salon list
                  Expanded(
                    flex: 1,
                    child: _displayedSalons.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty 
                                ? 'No salons available' 
                                : 'No salons found for "${_searchController.text}"',
                              style: AppStyles.sectionHeadingStyle,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _displayedSalons.length,
                            itemBuilder: (context, index) {
                              final salon = _displayedSalons[index];
                              return SaloonCard(
                                name: salon['salon_name'] ?? 'Unknown Salon',
                                address: salon['salon_address'] ?? 'Address not available',
                                hours: '8:00 am to 10:00 pm', // You can add this field to your backend
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SalonProfile(
                                        salonName: salon['salon_name'] ?? 'Unknown Salon'
                                      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}