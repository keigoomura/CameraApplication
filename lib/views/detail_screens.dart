// lib/views/detail_screens.dart

// Displays detailed information about a companies, checks, and invoices
// Used for the search functionality

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/checks.dart';
import '../models/companies.dart';
import '../models/invoices.dart';
import '../services/db_provider.dart';

// Company Detail Screen
// Displays detailed information about a company, its checks, and associated invoices

class CompanyDetailScreen extends StatefulWidget {
  final Companies company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late Future<List<_CheckWithInvoices>> _companyChecksWithInvoices;

  @override
  void initState() {
    super.initState();
    _companyChecksWithInvoices = _loadChecksAndInvoices();
  }

  Future<List<_CheckWithInvoices>> _loadChecksAndInvoices() async {
    final db = DBProvider.instance;
    final checks = await db.checks.getChecksByCompany(widget.company.id!);

    final List<_CheckWithInvoices> result = [];

    for (final check in checks) {
      final checkInvoiceLinks = await db.checkInvoices.getCheckInvoicesByCheck(check.id!);
      final invoiceFutures = checkInvoiceLinks
          .map((link) => db.invoices.getInvoiceById(link.invoiceId))
          .toList();

      final invoices = await Future.wait(invoiceFutures);
      final validInvoices = invoices.whereType<Invoices>().toList();

      result.add(_CheckWithInvoices(check: check, invoices: validInvoices));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.company.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Company ID: ${widget.company.id ?? "N/A"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Associated Checks:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<_CheckWithInvoices>>(
              future: _companyChecksWithInvoices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } 
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No checks found for this company.');
                }

                final checksWithInvoices = snapshot.data!;
                return ListView.separated(
                  itemCount: checksWithInvoices.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = checksWithInvoices[index];
                    final check = entry.check;
                    final invoices = entry.invoices;

                    return ExpansionTile(
                      title: Text("Check Number: ${check.number}"),
                      subtitle: Text("Date: ${check.createdAt.toLocal()}"),
                      leading: check.image.isNotEmpty
                          ? Image.file(File(check.image), width: 40, height: 40, fit: BoxFit.cover)
                          : null,
                      children: [
                        ListTile(
                          title: const Text("View Check Details"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckDetailScreen(
                                  check: check,
                                  companyName: widget.company.name,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ...invoices.map((inv) => ListTile(
                              title: Text("Invoice Number: ${inv.number}"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InvoiceDetailScreen(
                                      invoice: inv,
                                      companyName: widget.company.name,
                                      checkNumber: check.number.toString(),
                                    ),
                                  ),
                                );
                              },
                            )),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}

// Helper class to correlate checks with their invoices
class _CheckWithInvoices {
  final Checks check;
  final List<Invoices> invoices;

  _CheckWithInvoices({required this.check, required this.invoices});
}

// Invoice Detail Screen
// Displays detailed information about an invoice, including its associated check

class InvoiceDetailScreen extends StatelessWidget {
  final Invoices invoice;
  final String companyName;
  final String? checkNumber;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    required this.companyName,
    this.checkNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invoice Number: ${invoice.number}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: $companyName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Invoice Number: ${invoice.number}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Created At: ${invoice.createdAt.toLocal()}', style: const TextStyle(fontSize: 16)),
            if (checkNumber != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Associated Check Number: $checkNumber', style: const TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}

// Check Detail Screen
// Displays detailed information about a check

class CheckDetailScreen extends StatelessWidget {
  final Checks check;
  final String companyName;

  const CheckDetailScreen({
    super.key,
    required this.check,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = check.createdAt.toLocal().toString();

    return Scaffold(
      appBar: AppBar(title: Text('Check Number: ${check.number}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: $companyName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Check Number: ${check.number}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Created At: $createdAt', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            check.image.isNotEmpty
                ? Image.file(File(check.image), height: 200)
                : const Text('No image available'),
          ],
        ),
      ),
    );
  }
}
