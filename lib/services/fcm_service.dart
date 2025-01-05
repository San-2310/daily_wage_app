import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  final String _projectId =
      'your-project-id'; // Replace with your Firebase project ID
  final String _serviceAccountJsonPath =
      '/Users/san_23/Desktop/flutter_projects/daily_wage_app/daily-wage-app-1d4461bf4c3d.json'; // Replace with your service account JSON file path

  // This function handles sending the notification via HTTP v1 API
  Future<void> sendNotification(
      String fcmToken, String title, String body) async {
    // 1. Get the access token using OAuth2
    var authClient = await _getAuthClient();
    var url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');

    var payload = jsonEncode({
      'message': {
        'token': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    });

    // 2. Send the POST request to FCM API with the payload
    try {
      var response = await authClient.post(
        url,
        headers: {
          'Authorization': 'Bearer ${authClient.credentials.accessToken}',
          'Content-Type': 'application/json',
        },
        body: payload,
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully!');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    } finally {
      authClient.close();
    }
  }

  // 3. Get the OAuth2 authenticated client using the service account credentials
  Future<AuthClient> _getAuthClient() async {
    var credentials = ServiceAccountCredentials.fromJson(
        await File(_serviceAccountJsonPath).readAsString());

    var client = await clientViaServiceAccount(
        credentials, ['https://www.googleapis.com/auth/firebase.messaging']);

    return client;
  }
}
