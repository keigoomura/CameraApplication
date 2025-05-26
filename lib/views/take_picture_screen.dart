// Imports
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'display_picture_screen.dart';

// Camera preview screen that allows users to take a picture as well
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Show what camera currently sees
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    // Initialize controller
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of controller when widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back to Home')),
      // Add a preview widget to show what the camera sees, 
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          // If controller is initialized, display the camera preview.
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Live Camera Preview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0), // Add padding to only bottom
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: CameraPreview(_controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } 
          // If not yet initialized, show loading indicator
          else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // Button for taking picture
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Try taking a picture, throw error if it fails
          try {
            // Wait until camera controller is initialized
            await _initializeControllerFuture;

            // Take the picture and get the file path
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // Display picture on different screen
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => DisplayPictureScreen(
                      // Give image path to screen
                      imagePath: image.path,
                    ),
              ),
            );
          } 
          catch (e) {
            // Catch and throw error
            print(e);
          }
        },
        child: Column(
          // Icon and label for button
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt),
            SizedBox(height: 4),
            Text(
              'Click to take picture',
              style: TextStyle(fontSize: 8),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}