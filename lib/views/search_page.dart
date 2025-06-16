// lib/views/search_page.dart

// Search page to allow users to search for checks, invoices, and companies

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/invoices.dart';
import '../models/companies.dart';
import '../models/checks.dart';
import '../services/db_provider.dart';
import 'detail_screens.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Invoices> _filteredInvoices = [];
  List<Checks> _filteredChecks = [];
  List<Companies> _filteredCompanies = [];

  Map<int, Checks> _checkByInvoiceId = {};  
  Map<int, String> _companyNamesById = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final db = DBProvider.instance;

    // Load company names
    final companies = await db.companies.getAllCompanies();
    final companyMap = {
      for (var company in companies) company.id!: company.name,
    };

    // Load all check-invoice links and all checks
    final checkInvoices = await db.checkInvoices.getAllCheckInvoices(); // You might need to add this method if not defined
    final allChecks = await db.checks.getAllChecks();
    final checkMap = {
      for (var check in allChecks) check.id!: check,
    };

    // Map invoiceId to its associated check (first only)
    final Map<int, Checks> invoiceToCheck = {};
    for (final link in checkInvoices) {
      if (!invoiceToCheck.containsKey(link.invoiceId)) {
        final check = checkMap[link.checkId];
        if (check != null) {
          invoiceToCheck[link.invoiceId] = check;
        }
      }
    }

    setState(() {
      _companyNamesById = companyMap;
      _checkByInvoiceId = invoiceToCheck;
    });

    _onSearchChanged(); // Trigger initial search (may be empty)
  }

  void _onSearchChanged() async {
    final query = _searchController.text.toLowerCase();
    final db = DBProvider.instance;

    final invoices = await db.invoices.getAllInvoices();
    final checks = await db.checks.getAllChecks();
    final companies = await db.companies.getAllCompanies();

    setState(() {
      _filteredInvoices = invoices.where((inv) {
        final companyName = _companyNamesById[inv.companyId]?.toLowerCase() ?? '';
        return inv.number.toString().contains(query) || companyName.contains(query);
      }).toList();

      _filteredChecks = checks.where((check) {
        final companyName = _companyNamesById[check.companyId]?.toLowerCase() ?? '';
        return check.number.toString().contains(query) || companyName.contains(query);
      }).toList();

      _filteredCompanies = companies.where((comp) {
        return comp.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Helper method to create section titles to separate by company, checks, and invoices
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search checks, invoices, companies...',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                // Display list of companies
                if (_filteredCompanies.isNotEmpty) ...[
                  _buildSectionTitle("Companies"),
                  ..._filteredCompanies.map((c) => ListTile(
                        title: Text(c.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyDetailScreen(company: c),
                            ),
                          );
                        },
                      )),
                ],

                // Display list of checks
                if (_filteredChecks.isNotEmpty) ...[
                  _buildSectionTitle("Checks"),
                  ..._filteredChecks.map((c) => ListTile(
                        title: Text("Check #${c.number}"),
                        subtitle: Text("Company: ${_companyNamesById[c.companyId] ?? 'Unknown'}"),
                        trailing: c.image.isNotEmpty
                            ? Image.file(File(c.image), width: 40, height: 40, fit: BoxFit.cover)
                            : null,
                        onTap: () {
                          final companyName = _companyNamesById[c.companyId] ?? 'Unknown';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckDetailScreen(
                                check: c,
                                companyName: companyName,
                              ),
                            ),
                          );
                        },
                      )),
                ],

                // Display list of invoices
                if (_filteredInvoices.isNotEmpty) ...[
                  _buildSectionTitle("Invoices"),
                  ..._filteredInvoices.map((inv) => ListTile(
                        title: Text("Invoice #${inv.number}"),
                        subtitle: Text("Company: ${_companyNamesById[inv.companyId] ?? 'Unknown'}"),
                        onTap: () {
                          final companyName = _companyNamesById[inv.companyId] ?? 'Unknown';
                          final associatedCheck = _checkByInvoiceId[inv.id!];
                          final checkNumber = associatedCheck?.number.toString();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceDetailScreen(
                                invoice: inv,
                                companyName: companyName,
                                checkNumber: checkNumber,
                              ),
                            ),
                          );
                        },
                      )),
                ],
                
                if (_filteredCompanies.isEmpty &&
                    _filteredChecks.isEmpty &&
                    _filteredInvoices.isEmpty)
                  const Center(child: Text("No results found.")),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}