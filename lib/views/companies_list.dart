// lib/views/companies_list.dart

// Displays a table of companies with their names

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

  // For sorting options
  String _selectedSort = 'Company Name (A–Z)';

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

  // Sort companies based on the selected option
  void _sortCompanies(List<Companies> companies) {
    switch (_selectedSort) {
      case 'Company Name (A–Z)':
        companies.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Company Name (Z–A)':
        companies.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
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
            final companies = snapshot.data!;
            _sortCompanies(companies);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedSort,
                    items: const [
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