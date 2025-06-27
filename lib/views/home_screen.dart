// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'submit_form_screen.dart';
import 'view_data_screen.dart';
import 'companies_list.dart';
import 'checks_list.dart';
import 'invoice_list.dart';
import 'search_page.dart';
import 'login_screen.dart';
import '../services/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.username, this.showLoginSuccess = false});

  final String? username;
  final bool showLoginSuccess;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// One time login success message
class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showLoginSuccess) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      });
    }
  }


  void _logout(BuildContext context) async {
    await AuthService().isFreshToken();
    // await AuthService().logout();
    print("Back from logout redirect"); 

    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    //   (Route<dynamic> route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}!'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout', style: TextStyle(fontSize: 14)),
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