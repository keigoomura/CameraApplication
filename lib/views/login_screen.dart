// lib/views/login_screen.dart

import 'package:flutter/material.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorText;

  bool _hidePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // TODO: Add real login logic, but for now, go to the home screen
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = "Please enter both username and password";
      });
      return;
    }

    // Clear error
    setState(() {
      _errorText = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
    );
  }

  void _goToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
    );
  }

  void _goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              obscureText: _hidePassword,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 16),
            TextButton(
              onPressed: _goToForgotPassword,
              child: const Text("Forgot Password?"),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: _goToCreateAccount,
              child: const Text("Don't have an account? Create one here"),
            ),
          ],
        ),
      ),
    );
  }
}
