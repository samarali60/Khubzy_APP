import 'package:flutter/material.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_orders_screen.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_profile_screen.dart';
import 'package:khubzy/screens/bakeries/screens/dashboard_screen.dart';
import 'package:khubzy/screens/main/provider/bottom_nav_provider.dart';
import 'package:provider/provider.dart';

class BakaryMainLayout extends StatelessWidget {
  const BakaryMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

    final pages = const [
      BakeryDashboardScreen(),
      BakeryOrdersScreen(),
     BakeryProfileScreen(), 
    ];

    return Scaffold(
      body: pages[navProvider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.currentIndex,
        onTap: navProvider.changeIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "الطلبات"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "البروفايل"),
        ],
      ),
    );
  }
}
