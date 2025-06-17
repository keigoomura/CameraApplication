// lib/views/register_screen.dart

// Allow users to create a new account if they do not have one yet

import 'package:flutter/material.dart';
import 'home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _errorText;

  void _register() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate inputs
    if(username.isEmpty) {
      setState(() {
        _errorText = "Username cannot be empty";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorText = "Password cannot be empty";
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _errorText = "Please confirm your password";
      });
      return;
    }

    // Ensure passwords match 
    if (password != confirmPassword) {
      setState(() {
        _errorText = "Passwords do not match";
      });
      return;
    }

    // Clear error
    setState(() {
      _errorText = null;
    });

    // TODO: Add registration logic
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Create a New Account", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
