import 'package:flutter/material.dart';
import 'package:book_my_saloon/screens/booking_confirmation_screen.dart'; // Import the confirmation screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login without database and pass dummy data
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            saloonName: "VIVORA Salon", // Placeholder saloon name
            service: "Haircut", // Placeholder service
            date: DateTime(2024, 6, 19), // Placeholder date as DateTime
            time: TimeOfDay(hour: 10, minute: 0), 
            selectedEmployee: "John Doe", // Placeholder employee
            selectedTimeSlots: ['10:00', '11:00'], // Placeholder time slots
          ),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // VIVORA Logo
            Text(
              'VIVORA',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Roboto', // Placeholder font, adjust as needed
              ),
            ),
            SizedBox(height: 20),
            // Login or Sign up text
            Text(
              'Log in or Sign up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Create an account or log in to continue with your booking',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Social Login Buttons
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Placeholder for Google login implementation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Google login not implemented yet')),
                        );
                      },
                      icon: Image.network(
                        'https://www.google.com/favicon.ico', // Google logo placeholder
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                      label: Text('Continue with Google'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Email Login Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}