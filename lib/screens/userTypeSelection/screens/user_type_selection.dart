import 'package:flutter/material.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/userTypeSelection/provider/user_type_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  Future<void> _selectUserType(BuildContext context, String type) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_type', type);

    // Update provider (optional if used globally)
    Provider.of<UserTypeProvider>(context, listen: false).setUserType(type);

    if (type == 'citizen') {
      Navigator.pushReplacementNamed(context, AppRoutes.citizenLogin);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.bakeryLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("اختر نوع المستخدم"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              context,
              label: "مواطن",
              icon: Icons.person,
              color: theme.colorScheme.primary,
              type: "citizen",
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              label: "صاحب مخبز",
              icon: Icons.store,
              color: theme.colorScheme.secondary,
              type: "bakery",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      icon: Icon(icon, size: 30),
      onPressed: () => _selectUserType(context, type),
    );
  }
}
