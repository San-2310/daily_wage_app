import 'package:daily_wage_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _role; // Default role selection
  bool _useGeolocation = false; // Flag to check if using geolocation

  final AuthServices _authService = AuthServices();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  // Function to get current location using geolocator
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enable location services')));
      return;
    }

    // Check and request location permission
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    // Get the current position of the device
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _locationController.text =
          '${position.latitude}, ${position.longitude}'; // Set location to latitude and longitude
    });
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? error = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _phoneController.text,
      _role!,
      _locationController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Sign up successful")));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(
                  'Sign Up',
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 35),
                ),
                const SizedBox(height: 60),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: theme.colorScheme.primary),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Text("Name",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                hintText: 'Enter your full name',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text("Email",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                hintText: 'Enter your email',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text("Phone Number",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                hintText: 'Enter your phone number',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text("Location",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                                child: TextField(
                                    controller: _locationController,
                                    decoration: InputDecoration(
                                        hintText:
                                            'Enter location or use geolocation',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))))),
                            IconButton(
                                icon: Icon(Icons.location_on),
                                onPressed: _useGeolocation
                                    ? _getCurrentLocation
                                    : null),
                          ],
                        ),
                        SwitchListTile(
                          title: Text("Use Geolocation"),
                          value: _useGeolocation,
                          onChanged: (bool value) {
                            setState(() {
                              _useGeolocation = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Text("Role",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: theme.colorScheme.onSurface),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              hint: Text('Select your role'),
                              value: _role,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _role = newValue!;
                                });
                              },
                              items: <String>[
                                'employer',
                                'worker'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                    value: value, child: Text(value));
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text("Password",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: 'Enter your password',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text("Confirm Password",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: 'Confirm your password',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: _signUp,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: theme.colorScheme.primary,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(
                                    'Register',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onPrimary),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("OR",
                        style:
                            theme.textTheme.bodyLarge?.copyWith(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: theme.textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Text(" Log In",
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
