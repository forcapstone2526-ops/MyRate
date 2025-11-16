import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'store_owner_login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  void _showPopup(String message, {Color color = Colors.red}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: color,
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  void _updatePassword() async {
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pass.isEmpty || confirm.isEmpty) {
      _showPopup('Please fill in all fields');
      return;
    }
    if (pass != confirm) {
      _showPopup('Passwords do not match');
      return;
    }
    if (pass.length < 6) {
      _showPopup('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showPopup('❌ No logged in user. Please login first.');
        return;
      }

      await user.updatePassword(pass);
      _showPopup('✅ Password updated successfully!', color: Colors.green);
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StoreOwnerLoginFormScreen()),
          (route) => false,
        );
      });
    } on FirebaseAuthException catch (e) {
      _showPopup('❌ Error: ${e.message}');
    } catch (e) {
      _showPopup('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _updatePassword, child: const Text('Update Password')),
          ],
        ),
      ),
    );
  }
}
