import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/pages/auth/login_screen.dart';
import 'package:daily_wage_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // Add this import
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/locales.dart'; // Add this import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout() async {
    await AuthServices().logOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String _role = '';

  File? _profileImage;
  late SharedPreferences _prefs;
  late String _userId;
  bool _useGeolocation = false; // Flag to check if using geolocation

  // FocusNodes for detecting the focus state of each field
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  //final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _roleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserData();
  }

  // Load user data from Firestore and SharedPreferences
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // If user is not logged in, return

    _userId = user.uid;

    // Load Firestore data
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _locationController.text = data['location'] ?? '';
        _role =
            data['role'] ?? 'Unknown'; // Assuming 'role' is stored in Firestore
      });
    }

    // Load profile image path (if any)
    _profileImage = File(_prefs.getString('profileImage') ?? '');
  }

  // Pick a profile image from the gallery
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });

      // Save the profile image path locally
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/profile_image.png';
      _profileImage?.copy(filePath);

      _prefs.setString('profileImage', filePath); // Save image path
    }
  }

  // Get current location using geolocator
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    //LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocaleData.enableLocationServices
              .getString(context)))); // Update this line
      return;
    }

    // Check and request location permission
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(LocaleData.locationPermissionDenied
                .getString(context)))); // Update this line
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

  // Save user profile data to Firestore and locally
  Future<void> _saveProfile() async {
    try {
      // Update Firestore with the new user details
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocaleData.profileUpdatedSuccessfully
                .getString(context))), // Update this line
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${LocaleData.failedToUpdateProfile.getString(context)} $e')), // Update this line
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.profile.getString(context)), // Update this line
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildEditableField(LocaleData.name.getString(context),
                  _nameController, _nameFocusNode), // Update this line
              const SizedBox(height: 15),
              _buildUneditableField(LocaleData.email.getString(context),
                  _emailController, _emailFocusNode), // Update this line
              const SizedBox(height: 15),
              _buildEditableField(LocaleData.phone.getString(context),
                  _phoneController, _phoneFocusNode), // Update this line
              const SizedBox(height: 15),
              _buildLocationField(),
              const SizedBox(height: 15),
              _buildUneditableField(
                  LocaleData.role.getString(context), // Update this line
                  TextEditingController()..text = _role,
                  _roleFocusNode),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text(LocaleData.saveChanges
                    .getString(context)), // Update this line
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Editable field with container and dynamic border color
  Widget _buildEditableField(
      String label, TextEditingController controller, FocusNode focusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: focusNode.hasFocus
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // Uneditable field with container and dynamic border color
  Widget _buildUneditableField(
      String label, TextEditingController controller, FocusNode focusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: focusNode.hasFocus
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: TextField(
            controller: controller,
            enabled: false,
            focusNode: focusNode,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // Location field with geolocation toggle
  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleData.location.getString(context),
            style: const TextStyle(
                fontWeight: FontWeight.bold)), // Update this line
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: LocaleData.enterLocationOrUseGeolocation
                        .getString(context), // Update this line
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _useGeolocation ? _getCurrentLocation : null,
            ),
          ],
        ),
        SwitchListTile(
          title: Text(
              LocaleData.useGeolocation.getString(context)), // Update this line
          value: _useGeolocation,
          onChanged: (bool value) {
            setState(() {
              _useGeolocation = value;
            });
          },
        ),
      ],
    );
  }
}
