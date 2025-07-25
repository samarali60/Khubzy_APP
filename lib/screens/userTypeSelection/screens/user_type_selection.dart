import 'package:flutter/material.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/userTypeSelection/provider/user_type_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  Future<void> _selectUserType(BuildContext context, String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', type);

    Provider.of<UserTypeProvider>(context, listen: false).setUserType(type);

    if (type == 'citizen') {
      Navigator.pushNamed(context, AppRoutes.citizenLogin);
    } else {
      Navigator.pushNamed(context, AppRoutes.bakerySignUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // appBar: AppBar(title: const Text("اختر نوع المستخدم"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "يرجى تحديد نوع المستخدم",
              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Text(
            //   "يرجى تحديد نوع المستخدم",
            //   style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.brown),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 24),

            _buildUserCard(
              context,
              icon: Icons.person,
              label: "مواطن",
              description: "الدخول كمواطن لحجز الخبز ومعرفة الرصيد.",
              color: theme.colorScheme.primary,
              type: "citizen",
            ),
            const SizedBox(height: 24),
            _buildUserCard(
              context,
              icon: Icons.store,
              label: "صاحب مخبز",
              description: "الدخول لمتابعة الإنتاج والمخزون والتقييم.",
              color: theme.colorScheme.secondary,
              type: "bakery",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required String type,
  }) {
    return GestureDetector(
      onTap: () => _selectUserType(context, type),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20),
          ],
        ),
      ),
    );
  }
}
