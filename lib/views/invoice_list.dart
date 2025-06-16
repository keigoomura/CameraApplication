// lib/views/invoice_list.dart

// Displays a table of invoices with company names and associated check numbers

import 'package:flutter/material.dart';
import '../models/invoices.dart';
import '../services/db_provider.dart';

// Helper class to hold invoice display data
class InvoiceDisplayData {
  final Invoices invoice;
  final String companyName;
  final List<String> checkNumbers;

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
          .map((check) => check!.number.toString())
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
            return SingleChildScrollView(
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
            );
          }
        },
      ),
    );
  }
}