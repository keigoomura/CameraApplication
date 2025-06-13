// lib/views/display_picture_screen.dart

// Imports
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// Imports for web support 
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Widget to display picture taken
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back to Camera')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Picture Preview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  // If on web, load image bytes
                  child: kIsWeb
                      ? FutureBuilder<Uint8List>(
                          future: _loadImageBytes(imagePath),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.contain,
                              );
                            } 
                            else if (snapshot.hasError) {
                              return const Text('Error loading image');
                            } 
                            else {
                              return const CircularProgressIndicator();
                            }
                          },
                        )
                      // If not on web, load image from file
                      : Image.file(File(imagePath)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Back to Home button
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        tooltip: 'Go Home',
        child: const Icon(Icons.home),
      ),
    );
  }

  // Helper function to load image bytes for web
  Future<Uint8List> _loadImageBytes(String path) async {
    final xFile = XFile(path);
    return await xFile.readAsBytes();
  }
}