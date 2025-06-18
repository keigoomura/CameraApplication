// lib/views/submission_confirmation_screen.dart

// Submission confirmation screen that is displayed after a user submits a form
// The details of the check and its associated invoices, company, and image are displayed

// Imports
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/checks.dart';
import 'submit_form_screen.dart';
import 'home_screen.dart';

class SubmissionConfirmationPage extends StatelessWidget {
  final Checks check;
  final List<String> invoices;

  const SubmissionConfirmationPage({super.key, required this.check, required this.invoices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Center(
              child: Text(
                'Submission Confirmation',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(check.image),
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            Text('Check Number: ${check.number}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Invoice Numbers: ${invoices.join(', ')}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Company Name: ${check.companyId}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Created At: ${check.createdAt}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            const Text(
              'Your invoice has been successfully submitted.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to the form
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubmitFormPage(),
                    ),
                  );
                },
                child: const Text('Submit New Check'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child:ElevatedButton(
                onPressed: 
                () {
                  // Go back to the home screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen(username: 'User')),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
