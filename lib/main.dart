import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Seed 25 data layanan ke Firestore jika belum ada
  await FirebaseService().seedServices();
  runApp(const SobatBeresApp());
}

class SobatBeresApp extends StatelessWidget {
  const SobatBeresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sobat Beres',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
