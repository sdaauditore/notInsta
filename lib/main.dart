import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:not_insta/features/auth/presentation/pages/login_page.dart';
import 'package:not_insta/firebase_options.dart';
import 'package:not_insta/themes/light_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: LoginPage(),
    );
  }
}
