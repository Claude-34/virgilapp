// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:biometric_attendance_app/services/app_state.dart';

class LoginScreen extends StatelessWidget {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Attendance')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 100, color: Colors.indigo),
              const SizedBox(height: 30),
              const Text(
                'Biometric Attendance System',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Please authenticate to access the application.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    bool canCheckBiometrics = await _auth.canCheckBiometrics;
                    if (!canCheckBiometrics) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Biometrics not available on this device.')),
                      );
                      return;
                    }

                    bool authenticated = await _auth.authenticate(
                      localizedReason: 'Scan your fingerprint or face to login',
                      options: const AuthenticationOptions(
                        stickyAuth: true,
                        biometricOnly: true, // Only allow biometrics, no fallback to PIN
                      ),
                    );

                    if (authenticated) {
                      // The authStateChanges listener in AppState will handle navigation after sign-in.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication successful! Logging in...')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Biometric authentication failed or cancelled.')),
                      );
                    }
                  } catch (e) {
                    print("Error during biometric authentication: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Authentication error: ${e.toString()}')),
                    );
                  }
                },
                icon: const Icon(Icons.lock_open),
                label: const Text('Authenticate with Biometrics'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}