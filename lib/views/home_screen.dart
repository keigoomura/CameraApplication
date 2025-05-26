// Imports
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'take_picture_screen.dart';

// Homescreen 
class HomeScreen extends StatelessWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Make animated Welcome text 
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Welcome to Keigo\'s Camera App!',
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: [
                      Colors.purple,
                      Colors.blue,
                      Colors.yellow,
                      Colors.red,
                    ],
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,        
              ),
              const SizedBox(height: 32),
              // Add button to preview camera
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureScreen(camera: camera),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take a Picture'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}