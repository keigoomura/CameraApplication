// lib/views/submit_form_screen.dart

// Imports
import 'dart:io';

import 'submission_confirmation_screen.dart';
import 'package:flutter/material.dart';
import '../models/checks.dart';
import '../models/companies.dart';

import '../models/invoices.dart';
import '../models/check_invoices.dart';
import '../services/db_provider.dart';

import 'take_picture_screen.dart';

class SubmitFormPage extends StatefulWidget {
  const SubmitFormPage({super.key});

  @override
  SubmitFormPageState createState() => SubmitFormPageState();
}

class SubmitFormPageState extends State<SubmitFormPage> {
  final _companyNameController = TextEditingController();
  final _checkNumberController = TextEditingController();
  final _invoicesController = TextEditingController();

  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back to Home'), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst); // Go back to home
          },
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final imagePath = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (context) => const TakePictureScreen()),
                      );
                      if (imagePath != null && mounted) {
                        setState(() {
                          _imagePath = imagePath;
                        });

                        debugPrint('Received image path: $_imagePath');
                      }
                    },
                    child: const Text('Capture Image'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imagePath == null
                      ? const Icon(Icons.image_not_supported)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _invoicesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Invoices',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _checkNumberController,
              decoration: const InputDecoration(
                labelText: 'Check #',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async{
                final db = DBProvider.instance;

                final companyName = _companyNameController.text.trim();
                final checkNumber = int.tryParse(_checkNumberController.text.trim());
                final invoiceText = _invoicesController.text.trim();

                // Validate inputs
                if (_imagePath == null || _imagePath!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please capture an image')),
                  );
                  return;
                }
                if (checkNumber == null || checkNumber <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid check number')),
                  );
                  return;
                }
                if(companyName.isEmpty || invoiceText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  // Insert Company
                  final company = Companies(name: companyName);
                  final createdCompany = await db.companies.createCompany(company);

                  // // Insert Check with correct companyId
                  final check = Checks(
                    image: _imagePath ?? '',
                    number: checkNumber,
                    companyId: createdCompany.id!,
                    createdAt: DateTime.now(),
                  );
                  final checkId = await db.checks.createCheck(check);

                  // // Insert Invoice
                  final invoice = Invoices(
                    number: checkNumber,
                    companyId: createdCompany.id!,
                    createdAt: DateTime.now(),
                  );
                  final invoiceId = await db.invoices.createInvoice(invoice);

                  // // Insert CheckInvoices
                  final checkInvoice = CheckInvoices(
                    checkId: checkId.id!,
                    invoiceId: invoiceId.id!,
                  );
                  await db.checkInvoices.createCheckInvoice(checkInvoice);


                  // Success feedback
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Check submitted successfully:')),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmissionConfirmationPage(invoice: invoice, imagePath: _imagePath ?? ''),
                      ),
                    );
                  }
                } 
                catch (e) {
                  debugPrint('DB Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error occurred: $e')),
                  );
                }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _checkNumberController.dispose();
    _invoicesController.dispose();
    super.dispose();
  }
}
