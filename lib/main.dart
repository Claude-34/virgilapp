import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:virgilapp/models/student.dart';
import 'package:virgilapp/screens/add_student_form.dart';
import 'package:virgilapp/screens/attendance_history.dart';
import 'package:virgilapp/screens/attendance_recorder.dart';
import 'package:virgilapp/screens/dashboard_screen.dart';
import 'package:virgilapp/screens/login_screen.dart';
import 'package:virgilapp/screens/student_list.dart';
import 'package:virgilapp/services/app_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Biometric app',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: LoginScreen()),
    );
  }
}
