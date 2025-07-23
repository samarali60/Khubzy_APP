import 'package:khubzy/screens/auth/screens/bakery_login_screen.dart';
import 'package:khubzy/screens/auth/screens/citizen_login_screen.dart';
import 'package:khubzy/screens/bakeries/screens/bakeries_screen.dart';
import 'package:khubzy/screens/balance/screens/balance_screen.dart';
import 'package:khubzy/screens/home/screens/citizen_home_screen.dart';
import 'package:khubzy/screens/main/screens/main_layout.dart';
import 'package:khubzy/screens/reservation/provider/screens/reservation_screen.dart';
import 'package:khubzy/screens/settings/screens/setting_screen.dart';
import 'package:khubzy/screens/splash/screens/splash_screen.dart';
import 'package:khubzy/screens/userTypeSelection/screens/user_type_selection.dart';

class AppRoutes {
  static const splash = '/splash';
  static const userTypeSelection = '/userTypeSelection';
  static const bakeryLogin = '/bakeryLogin';
  static const citizenLogin = '/citizenLogin';
  static const main = '/mainLayout';
  static const citizenHome = '/citizenHome';
  static const reservation = '/reservation';
  static const bakeries = '/bakeries';
  static const balance = '/balance';
  static const settings = '/settings';


  static final routes = {
    splash: (context) => const SplashScreen(),
    userTypeSelection: (context) => const UserTypeSelectionScreen(),
    bakeryLogin: (context) => const BakeryLoginScreen(),
    citizenLogin: (context) => const CitizenLoginScreen(),
    main: (context) => const MainLayout(),
    citizenHome: (context) => const CitizenHomeScreen(),
    reservation: (context) => const ReservationScreen(),
    bakeries: (context) => const BakeriesScreen(),
    balance: (context) => const BalanceScreen(),
    settings: (context) => const SettingsScreen(), 
   
    // باقي الشاشات
  };
}
