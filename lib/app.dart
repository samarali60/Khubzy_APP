
import 'package:flutter/material.dart';
import 'package:khubzy/routes/app_routes.dart';

class KhobzyApp extends StatelessWidget {
  const KhobzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خبزي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFBF2), // بيج فاتح
        primaryColor: const Color(0xFFD5A253), // ذهبي بني
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFD5A253),
          secondary: const Color(0xFF8C5E3C), // بني أغمق
        ),
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.brown),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD5A253),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD5A253),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFD5A253),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
      initialRoute: AppRoutes.main,
      routes: AppRoutes.routes,
    );
  }
}
