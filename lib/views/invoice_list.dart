// lib/views/invoice_list.dart

// Displays a table of invoices with company names and associated check numbers

import 'package:flutter/material.dart';
import '../models/invoices.dart';
import '../services/db_provider.dart';

// Helper class to hold invoice display data
class InvoiceDisplayData {
  final Invoices invoice;
  final String companyName;
  final List<int> checkNumbers;

  InvoiceDisplayData({
    required this.invoice,
    required this.companyName,
    required this.checkNumbers,
  });
}

class InvoicesListPage extends StatefulWidget {
  const InvoicesListPage({super.key});

  @override
  State<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends State<InvoicesListPage> {
  late Future<List<InvoiceDisplayData>> _invoicesDisplayData;

  // For sorting options
  String _selectedSort = 'Invoice Number (Asc)';

  @override
  void initState() {
    super.initState();
    _invoicesDisplayData = _fetchInvoices();
  }

  Future<List<InvoiceDisplayData>> _fetchInvoices() async {
    final db = DBProvider.instance;
    final invoices = await db.invoices.getAllInvoices();

    final List<InvoiceDisplayData> enrichedInvoices = [];

    for (final invoice in invoices) {
      final company = await db.companies.getCompanyById(invoice.companyId);

      final checkLinks = await db.checkInvoices.getCheckInvoicesByInvoice(invoice.id!);
      final checks = await Future.wait(
        checkLinks.map((link) => db.checks.getCheckById(link.checkId)),
      );

      final checkNumbers = checks
        .where((check) => check != null)
        .map((check) => check!.number)
        .toList();

      enrichedInvoices.add(
        InvoiceDisplayData(
          invoice: invoice,
          companyName: company?.name ?? 'Unknown',
          checkNumbers: checkNumbers,
        ),
      );
    }

    return enrichedInvoices;
  }

  // Sort invoices based on the selected option
  void _sortInvoices(List<InvoiceDisplayData> invoices) {
    switch (_selectedSort) {
      case 'Invoice Number (Asc)':
        invoices.sort((a, b) => a.invoice.number.compareTo(b.invoice.number));
        break;
      case 'Invoice Number (Desc)':
        invoices.sort((a, b) => b.invoice.number.compareTo(a.invoice.number)); 
        break;
      case 'Company Name (A–Z)':
        invoices.sort((a, b) => a.companyName.compareTo(b.companyName));
        break;
      case 'Company Name (Z–A)':
        invoices.sort((a, b) => b.companyName.compareTo(a.companyName));
        break;
      case 'Check Number (Asc)':
        invoices.sort((a, b) {
          final aMin = a.checkNumbers.isNotEmpty ? a.checkNumbers.reduce((x, y) => x < y ? x : y) : double.infinity.toInt();
          final bMin = b.checkNumbers.isNotEmpty ? b.checkNumbers.reduce((x, y) => x < y ? x : y) : double.infinity.toInt();
          return aMin.compareTo(bMin);
        });
        break;

      case 'Check Number (Desc)':
        invoices.sort((a, b) {
          final aMax = a.checkNumbers.isNotEmpty ? a.checkNumbers.reduce((x, y) => x > y ? x : y) : -1;
          final bMax = b.checkNumbers.isNotEmpty ? b.checkNumbers.reduce((x, y) => x > y ? x : y) : -1;
          return bMax.compareTo(aMax);
        });
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoices List")),
      body: FutureBuilder<List<InvoiceDisplayData>>(
        future: _invoicesDisplayData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } 
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No invoices found."));
          } 
          else {
            final invoices = snapshot.data!;
            _sortInvoices(invoices);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedSort,
                    items: const [
                      DropdownMenuItem(value: 'Invoice Number (Asc)', child: Text('Invoice Number (Asc)')),
                      DropdownMenuItem(value: 'Invoice Number (Desc)', child: Text('Invoice Number (Desc)')),
                      DropdownMenuItem(value: 'Company Name (A–Z)', child: Text('Company Name (A–Z)')),
                      DropdownMenuItem(value: 'Company Name (Z–A)', child: Text('Company Name (Z–A)')),
                      DropdownMenuItem(value: 'Check Number (Asc)', child: Text('Check Number (Asc)')),
                      DropdownMenuItem(value: 'Check Number (Desc)', child: Text('Check Number (Desc)')),
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
                          DataColumn(label: Text('Invoice #', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Check #', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: snapshot.data!.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Text(entry.invoice.number.toString())),
                              DataCell(Text(entry.companyName)),
                              DataCell(Text(entry.checkNumbers.join(', '))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ),
              ],
            );
          }
        },
      ),
    );
  }
}