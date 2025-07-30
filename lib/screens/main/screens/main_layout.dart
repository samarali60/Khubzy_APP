import 'package:flutter/material.dart';
import 'package:khubzy/screens/balance/screens/citizen_balance_screen.dart';
import 'package:khubzy/screens/main/provider/bottom_nav_provider.dart';
import 'package:khubzy/screens/home/screens/citizen_home_screen.dart';
import 'package:khubzy/screens/orders/screens/orders_screen.dart';
import 'package:khubzy/screens/profile/screen/profile_screen.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

    final pages = const [
      CitizenHomeScreen(),
     OrdersScreen(),
      CitizenBalanceScreen(),
     ProfileScreen(), 
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
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "الرصيد"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "البروفايل"),
        ],
      ),
    );
  }
}
