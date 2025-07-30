
import 'package:flutter/material.dart';
import 'package:khubzy/core/widgets/logout_dialog.dart';

// ignore: camel_case_types
class logoutButton extends StatelessWidget {
  const logoutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => showDialog(context: context, builder:(context) => const LogoutDialog()),
          icon: const Icon(Icons.logout, size: 22),
          label: const Text(
            "تسجيل الخروج",
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.black26,
          ),
        ),
      ),
    );
  }
}
