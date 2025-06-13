// lib/views/submission_confirmation_screen.dart

// Imports
import 'package:flutter/material.dart';
import '../models/invoices.dart';
import 'submit_form_screen.dart';

class SubmissionConfirmationPage extends StatelessWidget {
  final Invoices invoice;

  const SubmissionConfirmationPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Submitted')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
      ),
    );
  }
}
