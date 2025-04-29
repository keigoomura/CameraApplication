import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// Imports for web support 
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  // Initialize the camera plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Get list of available cameras on device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 54, 191, 127)),
        ),
      title: 'Keigo\'s Camera App',
      home: HomeScreen(
        camera: firstCamera,
      ),
    ),
  );
}

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


// Screen to take picture using given camera
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
        child: const Icon(Icons.home),
        tooltip: 'Go Home',
      ),
    );
  }

  // Helper function to load image bytes for web
  Future<Uint8List> _loadImageBytes(String path) async {
    final xFile = XFile(path);
    return await xFile.readAsBytes();
  }
}
