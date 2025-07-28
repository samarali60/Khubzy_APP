import 'package:flutter/material.dart';
import 'package:khubzy/screens/auth/provider/citizen_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('user_type');

    if (userType == 'citizen') {
      await _handleCitizenFlow();
    } else if (userType == 'bakery') {
      await _handleBakeryFlow();
    } else {
      // أول مرة يدخل التطبيق أو حذف الداتا
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, AppRoutes.userTypeSelection);
    }
  }

  Future<void> _handleCitizenFlow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final citizenProvider = Provider.of<CitizenProvider>(context, listen: false);

    await citizenProvider.loadCitizens();
    await authProvider.loadUserFromPrefs();

    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone');

    if (phone != null) {
      citizenProvider.setCurrentCitizenByPhone(phone);
    }

    await Future.delayed(const Duration(seconds: 3));

    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.userTypeSelection);
    }
  }

  Future<void> _handleBakeryFlow() async {
    final bakeryProvider = Provider.of<BakeryProvider>(context, listen: false);
    await bakeryProvider.loadBakeries();

    final prefs = await SharedPreferences.getInstance();
    final nationalId = prefs.getString('user_id');

    if (nationalId != null) {
      final bakery = bakeryProvider.getBakeryByOwner(nationalId);
      if (bakery != null) {
        bakeryProvider.loginBakery(
          nationalId: nationalId,
          bakeryName: bakery.bakeryName,
          location: bakery.location,
        );

        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacementNamed(context, AppRoutes.bakeryDashboard);
        return;
      }
    }

    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacementNamed(context, AppRoutes.userTypeSelection);
  }

@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ صورة الشعار
            Image.asset(
              'assets/images/Kubzy.png', // ضيفي صورة هنا
              // width: 120,
              // height: 120,
            ),

            const SizedBox(height: 20),

            // ✅ اسم التطبيق
            Text(
              'خبزي',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontSize: 32,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'خدمات الخبز الذكية للمواطن والمخبز',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // ✅ مؤشر التحميل
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
