// lib/views/submit_form_screen.dart

// A form to allow users to submit checks with associated companies, invoices, and image of the check
// Stores the data in a database

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
import 'home_screen.dart';

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
      appBar: AppBar(
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        },
      ),

        title: const Text('Back to Home')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  // Allows user to capture an image using the camera
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
                // Displays the captured image or a placeholder if no image is captured
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

            // Invoice Number(s) Field
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

            // Company Name Field (may change to dropdown in the future)
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Company', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
              ),
            ),

            // Check Number Field
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Check Number', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _checkNumberController,
              decoration: const InputDecoration(
                labelText: 'Check Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            // Submission Button
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

                  // Insert Check
                  final check = Checks(
                    image: _imagePath ?? '',
                    number: checkNumber,
                    companyId: createdCompany.id!,
                    createdAt: DateTime.now(),
                  );
                  final checkId = await db.checks.createCheck(check);

                  // Insert Invoice and CheckInvoice for each invoice number

                  // Parse invoice numbers from the input text (could be comma or space separated)
                  final invoiceStrings = invoiceText
                      .split(RegExp(r'[,\s]+'))
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  // For each invoice number, create an Invoice and a CheckInvoice
                  for (var invoiceStr in invoiceStrings) {
                    final invoiceNumber = int.tryParse(invoiceStr);
                    if (invoiceNumber == null) {
                      debugPrint('Invalid invoice number: $invoiceStr');
                      continue;
                    }

                    final invoice = Invoices(
                      number: invoiceNumber,
                      companyId: createdCompany.id!,
                      createdAt: DateTime.now(),
                    );
                    final invoiceId = await db.invoices.createInvoice(invoice);

                    final checkInvoice = CheckInvoices(
                      checkId: checkId.id!,
                      invoiceId: invoiceId.id!,
                    );
                    await db.checkInvoices.createCheckInvoice(checkInvoice);
                  }

                  // Show success message and navigate to confirmation page
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Check submitted successfully:')),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmissionConfirmationPage(check: check, invoices: invoiceStrings),
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
