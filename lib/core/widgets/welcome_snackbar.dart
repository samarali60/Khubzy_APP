import 'package:flutter/material.dart';

class WelcomeSnackbar {
  static void show(BuildContext context, String name) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.waving_hand_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'أهلًا بيك يا $name ',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFD5A253), 
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
