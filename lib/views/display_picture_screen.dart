// lib/views/display_picture_screen.dart

// Imports
import 'dart:io' show File;

import 'package:flutter/material.dart';

// Imports for web support 
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;

// Widget to display picture taken
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              children: [
                // Retake Picture Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Go back to camera
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Retake Picture'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Use This Picture Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, imagePath); // Return image path to previous screen
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Use This Picture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to load image bytes for web (no longer needed)
  // Future<Uint8List> _loadImageBytes(String path) async {
  //   final xFile = XFile(path);
  //   return await xFile.readAsBytes();
  // }
}