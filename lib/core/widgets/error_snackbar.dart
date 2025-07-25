import 'package:flutter/material.dart';

class ErrorSnackBar {
  static void show(BuildContext context, String name) {
    final snackBar = SnackBar(
      content: Text(
            name,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
       
      backgroundColor:  const Color(0xFFF2013D), 
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
