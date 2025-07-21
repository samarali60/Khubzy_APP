import 'package:khubzy/screens/auth/screens/login_screen.dart';
import 'package:khubzy/screens/bakeries/screens/bakeries_screen.dart';
import 'package:khubzy/screens/balance/screens/balance_screen.dart';
import 'package:khubzy/screens/home/screens/home_screen.dart';
import 'package:khubzy/screens/main/screens/main_layout.dart';
import 'package:khubzy/screens/reservation/provider/screens/reservation_screen.dart';
import 'package:khubzy/screens/settings/screens/setting_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const main = '/main_layout';
  static const home = '/home';
  static const reservation = '/reservation';
  static const bakeries = '/bakeries';
  static const balance = '/balance';
  static const settings = '/settings';

  static final routes = {
    login: (context) => const LoginScreen(),
   main: (context) => const MainLayout(),
    home: (context) => const HomeScreen(),
    reservation: (context) => const ReservationScreen(),
    bakeries: (context) => const BakeriesScreen(),
    balance: (context) => const BalanceScreen(),
    settings: (context) => const SettingsScreen(), 
   
    // باقي الشاشات
  };
}
