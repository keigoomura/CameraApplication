// lib/views/view_tables_screen.dart

// Imports
import 'package:flutter/material.dart';
import '../services/db_provider.dart';
import '../models/checks.dart';
import '../models/companies.dart'; 
import '../models/invoices.dart';
import '../models/check_invoices.dart';

class ViewDataPage extends StatefulWidget {
  const ViewDataPage({super.key});

  @override
  ViewDataPageState createState() => ViewDataPageState();
}

class ViewDataPageState extends State<ViewDataPage> {
  late Future<List<Checks>> checks;
  late Future<List<Invoices>> invoices;
  late Future<List<Companies>> companies;
  late Future<List<CheckInvoices>> checkInvoices;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DBProvider.instance;

    setState(() {
      checks = db.checks.getAllChecks();
      invoices = db.invoices.getAllInvoices();
      companies = db.companies.getAllCompanies();
      checkInvoices = db.checkInvoices.getAllCheckInvoices();
    });
  }

  Widget _buildFutureSection<T>(String title, Future<List<T>> future) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ExpansionTile(
            title: Text(title),
            children: [const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )],
          );
        } else if (snapshot.hasError) {
          return ExpansionTile(
            title: Text(title),
            children: [ListTile(title: Text('Error: ${snapshot.error}'))],
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ExpansionTile(
            title: Text(title),
            children: [const ListTile(title: Text('No data found.'))],
          );
        } else {
          return ExpansionTile(
            title: Text(title),
            children: snapshot.data!.map((item) {
              return ListTile(title: Text(item.toString()));
            }).toList(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Contents')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFutureSection('Checks Table', checks),
            _buildFutureSection('Invoices Table', invoices),
            _buildFutureSection('Companies Table', companies),
            _buildFutureSection('Check-Invoices Table', checkInvoices),
          ],
        ),
      ),
    );
  }
}
