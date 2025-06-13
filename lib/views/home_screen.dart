// lib/views/home_screen.dart

// Imports
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'submit_form_screen.dart'; 
import 'view_data_screen.dart';
import 'take_picture_screen.dart';

// Homescreen 
class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

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
                      builder: (context) => TakePictureScreen(),
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
              const SizedBox(height: 16),

              // Add Invoice Form Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubmitFormPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Submit a New Check'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Add View Tables Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewDataPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.table_chart),
                label: const Text('View Data'),
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