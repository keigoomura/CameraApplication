// lib/views/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _errorText;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _hideConfirmPassword = !_hideConfirmPassword;
    });
  }

  void _resetPassword() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate inputs
    if (username.isEmpty) {
      setState(() {
        _errorText = 'Please enter your username';
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

    // TODO: Add real password reset logic and confirmation of password reset
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Enter your username to reset password', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              obscureText: _hidePassword,
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
              obscureText: _hideConfirmPassword,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Reset Password'),
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}