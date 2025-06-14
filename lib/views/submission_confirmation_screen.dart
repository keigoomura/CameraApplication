// lib/views/submission_confirmation_screen.dart

// Imports
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/invoices.dart';
import 'submit_form_screen.dart';

class SubmissionConfirmationPage extends StatelessWidget {
  final Invoices invoice;
  final String imagePath;

  const SubmissionConfirmationPage({super.key, required this.invoice, required this.imagePath});

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
                  File(imagePath),
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            Text('Invoice Number: ${invoice.number}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Company ID: ${invoice.companyId}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Created At: ${invoice.createdAt}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            const Text(
              'Your invoice has been successfully submitted.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to the invoice form
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
                  Navigator.popUntil(context, (route) => route.isFirst);
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
