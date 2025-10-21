import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:manager_hackathon/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return homeapp();
  }
}