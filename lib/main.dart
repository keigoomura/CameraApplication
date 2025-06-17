import 'dart:async';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'views/login_screen.dart';

Future<void> main() async {
  // Initialize the camera plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Clearing database
  // await deleteDatabaseFile();

  runApp(const MyApp());
}

// Temp code to delete the database file (dev only)
Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'camera_app_database.db');
  await deleteDatabase(path);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 54, 191, 127)),
        ),
      title: 'Telaeris Checks and Invoices',
      home: LoginScreen(),
    );
  }
}