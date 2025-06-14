// lib/views/companies_list.dart

import 'package:flutter/material.dart';
import '../models/companies.dart';
import '../services/db_provider.dart';

class CompaniesListPage extends StatefulWidget {
  const CompaniesListPage({super.key});

  @override
  CompaniesListPageState createState() => CompaniesListPageState();
}

class CompaniesListPageState extends State<CompaniesListPage> {
  late Future<List<Companies>> _companies;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    final db = DBProvider.instance;

    setState(() {
      _companies = db.companies.getAllCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Companies List')),
      body: FutureBuilder<List<Companies>>(
        future: _companies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No companies found.'));
          } 
          else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[300]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Company Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: snapshot.data!.map((company) {
                  return DataRow(
                    cells: [
                      DataCell(Text(company.name)),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}