import 'package:flutter/material.dart';
import 'package:review/screen/login_sign_up_screen.dart';
import 'package:review/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MaterialApp(
        home: LoginSignupScreen(),

    ),
  );

}

