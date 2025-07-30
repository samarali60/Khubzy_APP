import 'package:flutter/material.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/auth/provider/citizen_auth_provider.dart';
import 'package:provider/provider.dart';


class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: theme.colorScheme.primary, size: 48),
            const SizedBox(height: 16),
            Text("تسجيل الخروج", style: theme.textTheme.headlineLarge),
            const SizedBox(height: 12),
            Text(
              "هل أنت متأكد أنك تريد تسجيل الخروج؟",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("إلغاء"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.splash,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("خروج"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
