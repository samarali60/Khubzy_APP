import 'package:flutter/material.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/routes/app_routes.dart';
import 'package:khubzy/screens/auth/provider/citizen_auth_provider.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:khubzy/screens/bakeries/providers/baker_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Wait a brief moment for the splash screen to be visible
    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // If not logged in, go to the selection screen
    if (!isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.userTypeSelection);
      }
      return;
    }

    // If logged in, check the user type and navigate accordingly
    final userType = prefs.getString('user_type');

    if (userType == 'citizen') {
      _navigateToCitizenHome();
    } else if (userType == 'bakery') {
      _navigateToBakeryDashboard();
    } else {
      // Fallback in case user_type is somehow null
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.userTypeSelection);
      }
    }
  }

  void _navigateToCitizenHome() {
    // Pre-load necessary data if needed, but for now, just navigate
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  void _navigateToBakeryDashboard() {
    // Pre-load necessary data for the bakery provider before navigating
    final bakeryProvider = Provider.of<BakeryProvider>(context, listen: false);
    final bakerProvider = Provider.of<BakerProvider>(context, listen: false);
    final prefs = SharedPreferences.getInstance();

    // This can happen in the background, but it's good practice to init
    prefs.then((p) async {
      final bakerId = p.getString('baker_id');
      if (bakerId != null) {
        await bakeryProvider.loadBakeries();
        await bakerProvider.loadBakers();
        final bakery = bakeryProvider.getBakeryByOwner(bakerId);
        if (bakery != null) {
          bakeryProvider.loginBakery(
            nationalId: bakerId,
            bakeryName: bakery.bakeryName,
            location: bakery.location,
          );
        }
      }
    });

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.bakeryMainLayout);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Logo Image
            Image.asset(
              'assets/images/Kubzy.png',
            ),
            const SizedBox(height: 20),

            // ✅ App Name
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
            // ✅ Loading Indicator
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