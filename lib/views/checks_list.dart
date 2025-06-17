// lib/views/checks_list.dart

// Displays a table of checks with date/time created, company, check number, invoices, and image
// Allows users to view check images in a dialog

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

  // For sorting options
  String _selectedSort = 'Newest First';

  @override
  void initState() {
    super.initState();
    _checksDisplayData = _loadChecks();
  }

  Future<List<CheckDisplayData>>  _loadChecks() async {
    final db = DBProvider.instance;
    final checks = await db.checks.getAllChecks();

    final List<CheckDisplayData> enrichedChecks = [];

    // Get company names and invoice numbers for each check
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

  // Sort checks based on selected option
  void _sortChecks(List<CheckDisplayData> checks) {
    switch (_selectedSort) {
      case 'Newest First':
        checks.sort((a, b) => b.check.createdAt.compareTo(a.check.createdAt));
        break;
      case 'Oldest First':
        checks.sort((a, b) => a.check.createdAt.compareTo(b.check.createdAt));
        break;
      case 'Check Number (Asc)':
        checks.sort((a, b) => a.check.number.compareTo(b.check.number));
        break;
      case 'Check Number (Desc)':
        checks.sort((a, b) => b.check.number.compareTo(a.check.number));
        break;
      case 'Company Name (A–Z)':
        checks.sort((a, b) => a.companyName.compareTo(b.companyName));
        break;
      case 'Company Name (Z–A)':
        checks.sort((a, b) => b.companyName.compareTo(a.companyName));
        break;
    }
  }


  // Show image in a dialog
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
            final checks = snapshot.data!;
            _sortChecks(checks);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedSort,
                    items: const [
                      DropdownMenuItem(value: 'Newest First', child: Text('Newest First')),
                      DropdownMenuItem(value: 'Oldest First', child: Text('Oldest First')),
                      DropdownMenuItem(value: 'Check Number (Asc)', child: Text('Check # Ascending')),
                      DropdownMenuItem(value: 'Check Number (Desc)', child: Text('Check # Descending')),
                      DropdownMenuItem(value: 'Company Name (A–Z)', child: Text('Company Name (A–Z)')),
                      DropdownMenuItem(value: 'Company Name (Z–A)', child: Text('Company Name (Z–A)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey[300]),
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Company')),
                          DataColumn(label: Text('Check #')),
                          DataColumn(label: Text('Invoices')),
                          DataColumn(label: Text('Image')),
                        ],
                        rows: checks.map((entry) {
                          return DataRow(cells: [
                            DataCell(Text(entry.check.createdAt.toString())),
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
                                : const Text('No Image')),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}