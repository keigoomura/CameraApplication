import 'package:flutter/material.dart';
import '../models/checks.dart';
import '../models/companies.dart';
import '../models/invoices.dart';
import '../models/check_invoices.dart';
import '../services/db_provider.dart';

class AddCheckPage extends StatefulWidget {
  const AddCheckPage({super.key});

  @override
  AddCheckPageState createState() => AddCheckPageState();
}

class AddCheckPageState extends State<AddCheckPage> {
  final _companyNameController = TextEditingController();
  final _checkNumberController = TextEditingController();
  final _invoicesController = TextEditingController();

  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {
            //           // Implement image capture logic here
            //         },
            //         child: const Text('Capture Image'),
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     Container(
            //       width: 40,
            //       height: 40,
            //       color: Colors.grey[300],
            //       child: _imagePath == null
            //           ? const Icon(Icons.image_not_supported)
            //           : Image.asset(_imagePath!),
            //     )
            //   ],
            // ),
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

                if (companyName.isEmpty || checkNumber == null || invoiceText.isEmpty) {
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
                    Navigator.pop(context);
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
