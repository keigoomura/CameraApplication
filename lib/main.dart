import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'views/home_screen.dart';

late final CameraDescription firstCamera;

Future<void> main() async {
  // Initialize the camera plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Get list of available cameras on device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  firstCamera = cameras.first;

  runApp(const MyApp());
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
      title: 'Keigo\'s Camera App',
      home: HomeScreen(
        camera: firstCamera,
      ),
    );
  }
}