import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/widgets/applications_tab.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localization/flutter_localization.dart'; // Add this import

import '../../localization/locales.dart'; // Add this import

class EmployerJobDetailsScreen extends StatefulWidget {
  final String jobId;

  const EmployerJobDetailsScreen({super.key, required this.jobId});

  @override
  _EmployerJobDetailsScreenState createState() =>
      _EmployerJobDetailsScreenState();
}

class _EmployerJobDetailsScreenState extends State<EmployerJobDetailsScreen>
    with SingleTickerProviderStateMixin {
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
  String? _jobStatus;

  // Dropdown for job status
  final List<String> _statusOptions = ['active', 'completed', 'canceled'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchJobDetails() async {
    try {
      DocumentSnapshot jobSnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .get();

      if (jobSnapshot.exists) {
        var data = jobSnapshot.data() as Map<String, dynamic>;

        _jobTitleController.text = data['jobTitle'];
        _jobDescriptionController.text = data['jobDescription'];
        _numWorkersController.text = data['numWorkers'].toString();
        _wagePerDayController.text = data['wagePerDay'].toString();
        _durationController.text = data['duration'].toString();
        _categoryController.text = data['category'];
        _jobStatus = data['status'];

        var location = data['location'];
        if (location != null) {
          if (location['address'] != null) {
            _address = location['address'];
            _locationController.text = _address!;
          } else {
            _latitude = location['latitude'];
            _longitude = location['longitude'];
            _locationController.text =
                '${_latitude}, ${_longitude}'; // Display latitude and longitude
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleData.errorFetchingJobDetails.getString(context)), // Update this line
      ));
    }
  }

  Future<void> _updateJob() async {
    setState(() {
      _isLoading = true;
    });

    final updatedJob = {
      'jobTitle': _jobTitleController.text,
      'jobDescription': _jobDescriptionController.text,
      'numWorkers': int.tryParse(_numWorkersController.text) ?? 0,
      'wagePerDay': double.tryParse(_wagePerDayController.text) ?? 0.0,
      'duration': int.tryParse(_durationController.text) ?? 0,
      'category': _categoryController.text,
      'status': _jobStatus,
      'location': _address != null
          ? {'address': _address}
          : {'latitude': _latitude, 'longitude': _longitude},
    };

    try {
      // Update the job in Firestore
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update(updatedJob);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleData.jobUpdatedSuccessfully.getString(context)), // Update this line
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${LocaleData.errorUpdatingJob.getString(context)} $e'), // Update this line
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteJob() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Delete the job from Firestore
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleData.jobDeletedSuccessfully.getString(context)), // Update this line
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${LocaleData.errorDeletingJob.getString(context)} $e'), // Update this line
      ));
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
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(LocaleData.jobDetails.getString(context))), // Update this line
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: LocaleData.jobDetails.getString(context)), // Update this line
                    Tab(text: LocaleData.applications.getString(context)), // Update this line
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 840,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildJobDetailsForm(),
                      ApplicationTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetailsForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _jobTitleController,
              decoration: InputDecoration(
                  labelText: LocaleData.jobTitle.getString(context), // Update this line
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jobDescriptionController,
              decoration: InputDecoration(
                  labelText: LocaleData.jobDescription.getString(context), // Update this line
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numWorkersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: LocaleData.numWorkers.getString(context), // Update this line
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wagePerDayController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: LocaleData.wagePerDay.getString(context), // Update this line
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: LocaleData.duration.getString(context), // Update this line
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                  labelText: LocaleData.category.getString(context), // Update this line
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            Text(LocaleData.jobStatus.getString(context)), // Update this line
            DropdownButtonFormField<String>(
              value: _jobStatus,
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _jobStatus = value;
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            Text(LocaleData.location.getString(context)), // Update this line
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                        labelText:
                            _address != null ? _address : LocaleData.enterLocation.getString(context), // Update this line
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
              title: Text(LocaleData.useGeolocation.getString(context)), // Update this line
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _deleteJob,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                LocaleData.deleteJob.getString(context), // Update this line
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                  ),
                ),
                InkWell(
                  onTap: _updateJob,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                LocaleData.updateJob.getString(context), // Update this line
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    // Only show the label and value if the value is not null
    if (value == null || value.toString().isEmpty) {
      return SizedBox
          .shrink(); // Don't display anything if the value is null or empty
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 204, 220, 231),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 157, 174, 182),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      '$label: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(value.toString()),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleData.enableLocationServices.getString(context)))); // Update this line
      return;
    }

    // Check and request location permission
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleData.locationPermissionDenied.getString(context)))); // Update this line
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
}
