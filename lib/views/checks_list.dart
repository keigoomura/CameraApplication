// lib/views/checks_list.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/checks.dart';
import '../services/db_provider.dart';

// Helper class to hold check display data
class CheckDisplayData {
  final Checks check;
  final String companyName;
  final List<String> invoiceNumbers;

  CheckDisplayData({
    required this.check,
    required this.companyName,
    required this.invoiceNumbers,
  });
}

class ChecksListPage extends StatefulWidget {
  const ChecksListPage({super.key});

  @override
  ChecksListPageState createState() => ChecksListPageState();
}

class ChecksListPageState extends State<ChecksListPage> {
  late Future<List<CheckDisplayData>> _checksDisplayData;

  @override
  void initState() {
    super.initState();
    _checksDisplayData = _loadChecks();
  }

  Future<List<CheckDisplayData>>  _loadChecks() async {
    final db = DBProvider.instance;
    final checks = await db.checks.getAllChecks();

    final List<CheckDisplayData> enrichedChecks = [];

    for (final check in checks) {
      final company = await db.companies.getCompanyById(check.companyId);
      final invoiceLinks = await db.checkInvoices.getCheckInvoicesByCheck(check.id!);
      final invoices = await Future.wait(invoiceLinks.map((link) => db.invoices.getInvoiceById(link.invoiceId)));
      final invoiceNumbers = invoices
        .where((inv) => inv != null)
        .map((inv) => inv!.number.toString())
        .toList();

      enrichedChecks.add(CheckDisplayData(
        check: check,
        companyName: company?.name ?? 'Company not listed',
        invoiceNumbers: invoiceNumbers,
      ));
    }

    setState(() {
      _checksDisplayData = Future.value(enrichedChecks);
    });

    return enrichedChecks;
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checks List")),
      body: FutureBuilder<List<CheckDisplayData>>(
        future: _checksDisplayData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No checks found.'));
          } 
          else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[300]),
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check #', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Invoices', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: snapshot.data!.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.check.createdAt.toLocal().toString().split(' ')[0])),
                      DataCell(Text(entry.companyName)),
                      DataCell(Text(entry.check.number.toString())),
                      DataCell(Text(entry.invoiceNumbers.join(', '))),
                      DataCell(entry.check.image.isNotEmpty
                          ? GestureDetector(
                                onTap: () => _showImageDialog(entry.check.image),
                                child: Image.file(
                                  File(entry.check.image),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Text('No Image'),),
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}