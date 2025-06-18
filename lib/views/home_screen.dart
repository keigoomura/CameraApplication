// lib/views/home_screen.dart

// Imports
import 'package:flutter/material.dart';
import 'submit_form_screen.dart'; 
import 'view_data_screen.dart';
import 'companies_list.dart';
import 'checks_list.dart';
import 'invoice_list.dart';
import 'search_page.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key, this.username});

  final String? username;

  void _logout(BuildContext context) {
    // Pop all routes and go back to the login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username!'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ], 
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildDashboardCard(context, Icons.add, 'Submit Check', const SubmitFormPage()),
                  _buildDashboardCard(context, Icons.table_chart, 'View Data', const ViewDataPage()),
                  _buildDashboardCard(context, Icons.business, 'Companies', const CompaniesListPage()),
                  _buildDashboardCard(context, Icons.check, 'Checks', const ChecksListPage()),
                  _buildDashboardCard(context, Icons.receipt_long, 'Invoices', const InvoicesListPage()),
                  _buildDashboardCard(context, Icons.search, 'Search', const SearchPage()),
                  //_buildDashboardCard(context, Icons.person, 'Profile', ProfilePage(username: username)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDashboardCard(BuildContext context, IconData icon, String title, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destinationPage));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.indigo),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }