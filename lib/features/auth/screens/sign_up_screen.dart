import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/user/screens/unified_dashboard.dart';
import 'package:event_management_app1/features/auth/screens/login_screen.dart';
import 'package:event_management_app1/features/auth/auth_widgets/form_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningUp = false;

  Future<void> _signUp() async {
  setState(() => _isSigningUp = true);

  try {
    final result = await AuthService().signup(
      name: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
     
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UnifiedDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Signup failed")),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signup failed: $e")),
    );
  } finally {
    if (mounted) setState(() => _isSigningUp = false);
  }
}
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text("SignUp")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sign Up", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isSigningUp
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Text("Login", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
