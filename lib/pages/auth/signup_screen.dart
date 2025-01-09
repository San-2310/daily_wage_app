import 'package:daily_wage_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // Add this import
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../localization/locales.dart'; // Add this import
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
    //LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')));
      return;
    }

    // Check and request location permission
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')));
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")));
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
          .showSnackBar(const SnackBar(content: Text("Sign up successful")));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
                  LocaleData.signUp.getString(context), // Update this line
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
                        Text(
                            LocaleData.name
                                .getString(context), // Update this line
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                hintText: LocaleData.enterFullName
                                    .getString(context), // Update this line
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text(
                            LocaleData.email
                                .getString(context), // Update this line
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                hintText: LocaleData.enterEmail
                                    .getString(context), // Update this line
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text(
                            LocaleData.phone
                                .getString(context), // Update this line
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                hintText: LocaleData.enterPhoneNumber
                                    .getString(context), // Update this line
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text(
                            LocaleData.location
                                .getString(context), // Update this line
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                                child: TextField(
                                    controller: _locationController,
                                    decoration: InputDecoration(
                                        hintText: LocaleData
                                            .enterLocationOrUseGeolocation
                                            .getString(
                                                context), // Update this line
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))))),
                            IconButton(
                                icon: const Icon(Icons.location_on),
                                onPressed: _useGeolocation
                                    ? _getCurrentLocation
                                    : null),
                          ],
                        ),
                        SwitchListTile(
                          title: Text(LocaleData.useGeolocation
                              .getString(context)), // Update this line
                          value: _useGeolocation,
                          onChanged: (bool value) {
                            setState(() {
                              _useGeolocation = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                            LocaleData.role
                                .getString(context), // Update this line
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
                              hint: Text(LocaleData.selectRole
                                  .getString(context)), // Update this line
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
                        Text(
                            LocaleData.password
                                .getString(context), // Update this line
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: LocaleData.enterPassword
                                    .getString(context), // Update this line
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 24),
                        Text(
                            LocaleData.confirmPassword
                                .getString(context), // Update this line
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: LocaleData.confirmPassword
                                    .getString(context), // Update this line
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
                                    LocaleData.register
                                        .getString(context), // Update this line
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
                    Text(LocaleData.or.getString(context), // Update this line
                        style:
                            theme.textTheme.bodyLarge?.copyWith(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        LocaleData.alreadyHaveAccount
                            .getString(context), // Update this line
                        style: theme.textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: Text(
                          LocaleData.logIn
                              .getString(context), // Update this line
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
