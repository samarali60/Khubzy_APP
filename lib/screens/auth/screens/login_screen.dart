
import 'package:flutter/material.dart';
import 'package:khubzy/screens/auth/provider/auth_provider.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('تسجيل الدخول'),
          onPressed: () {
            authProvider.login("sample_token");
            print("User logged ");
            Navigator.pushReplacementNamed(context, AppRoutes.main);
          },
        ),
      ),
    );
  }
}
