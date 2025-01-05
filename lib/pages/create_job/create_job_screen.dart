import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _numWorkersController = TextEditingController();
  final TextEditingController _wagePerDayController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;
  bool _useGeolocation = false;
  double? _latitude;
  double? _longitude;
  String? _address;

  // Simulating getting the current user id

  String get currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ??
      'guest'; // Replace with actual logic for getting the user ID

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
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationController.text =
          '${_latitude}, ${_longitude}'; // Set location to latitude and longitude
    });
  }

  Future<void> _createJob() async {
    setState(() {
      _isLoading = true;
    });

    String jobTitle = _jobTitleController.text;
    String jobDescription = _jobDescriptionController.text;
    int numWorkers = int.tryParse(_numWorkersController.text) ?? 0;
    double wagePerDay = double.tryParse(_wagePerDayController.text) ?? 0.0;
    int duration = int.tryParse(_durationController.text) ?? 0;
    String category = _categoryController.text;

    final job = {
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'employerId': currentUserId,
      'location': _address != null
          ? {'address': _address}
          : {'latitude': _latitude, 'longitude': _longitude},
      'numWorkers': numWorkers,
      'wagePerDay': wagePerDay,
      'duration': duration,
      'category': category,
      'status': 'active',
      'postedAt': Timestamp.fromDate(DateTime.now()),
    };

    try {
      // Store the job in Firestore
      DocumentReference jobRef =
          await FirebaseFirestore.instance.collection('jobs').add(job);

      // Now call the notification function
      await _notificationService.notifyWorkerOfNewJobPosting(
          jobRef.id, jobTitle, jobDescription);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Job posted successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error posting job: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _numWorkersController.dispose();
    _wagePerDayController.dispose();
    _durationController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Job Listing')),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                TextField(
                  controller: _jobTitleController,
                  decoration: InputDecoration(
                      labelText: 'Job Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _jobDescriptionController,
                  decoration: InputDecoration(
                      labelText: 'Job Description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _numWorkersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Number of Workers',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _wagePerDayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Wage per Day',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Duration (in days)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 16),
                Text('Location'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                            labelText:
                                _address != null ? _address : 'Enter location',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                        readOnly: true,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.location_on),
                      onPressed: _useGeolocation ? _getCurrentLocation : null,
                    ),
                  ],
                ),
                SwitchListTile(
                  title: Text('Use Geolocation'),
                  value: _useGeolocation,
                  onChanged: (bool value) {
                    setState(() {
                      _useGeolocation = value;
                      _locationController.clear();
                      _address = null;
                    });
                  },
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: _createJob,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.primary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Center(
                            child: Text(
                              'Post Job',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
