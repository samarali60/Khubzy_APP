import 'package:khubzy/screens/auth/screens/bakery_signup_screen.dart';
import 'package:khubzy/screens/auth/screens/bakery_login_screen.dart';
import 'package:khubzy/screens/auth/screens/citizen_login_screen.dart';
import 'package:khubzy/screens/auth/screens/citizen_signup_screen.dart';
import 'package:khubzy/screens/bakeries/screens/bakeries_screen.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_main_layout_screen.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_ordars_screen.dart';
import 'package:khubzy/screens/bakeries/screens/bakery_profile_screen.dart';
import 'package:khubzy/screens/bakeries/screens/dashboard_screen.dart';
import 'package:khubzy/screens/balance/screens/citizen_balance_screen.dart';
import 'package:khubzy/screens/home/screens/citizen_home_screen.dart';
import 'package:khubzy/screens/main/screens/main_layout.dart';
import 'package:khubzy/screens/profile/screen/profile_screen.dart';
import 'package:khubzy/screens/reservation/provider/screens/reservation_screen.dart';
import 'package:khubzy/screens/settings/screens/setting_screen.dart';
import 'package:khubzy/screens/splash/screens/splash_screen.dart';
import 'package:khubzy/screens/userTypeSelection/screens/user_type_selection.dart';

class AppRoutes {
  static const splash = '/splash';
  static const userTypeSelection = '/userTypeSelection';
   static const bakerySignUp = '/bakerySignUp';
  static const bakeryLogin = '/bakeryLogin';
  static const citizenSignUp = '/citizenSignUp';
    static const citizenLogin = '/citizenLogin';
  static const main = '/mainLayout';
  static const citizenHome = '/citizenHome';
  static const reservation = '/reservation';
  static const bakeries = '/bakeries';
  static const balance = '/balance';
  static const settings = '/settings';
  static const profile = '/profile';
  static const bakeryMainLayout = '/bakeryMainLayout';
  static const bakeryDashboard = '/bakeryDashboard';
  static const bakeryOrders = '/bakeryOrders';
  static const bakeryProfile = '/bakeryProfile';


  static final routes = {
    splash: (context) => const SplashScreen(),
    userTypeSelection: (context) => const UserTypeSelectionScreen(),
    bakerySignUp: (context) => const BakerySignupScreen(),
    bakeryLogin: (context) => const BakeryLoginScreen(),
    citizenSignUp: (context) => const CitizenSignUpScreen(),
    citizenLogin: (context) => const CitizenLoginScreen(),
    main: (context) => const MainLayout(),
    citizenHome: (context) => const CitizenHomeScreen(),
    reservation: (context) => const ReservationScreen(),
    bakeries: (context) => const BakeriesScreen(),
    balance: (context) => const CitizenBalanceScreen(),
    settings: (context) => const SettingsScreen(),
    profile: (context) => const ProfileScreen(), 
    bakeryDashboard: (context) => const BakeryDashboardScreen(),
    bakeryOrders: (context) => const BakeryOrdersScreen(),
    bakeryProfile: (context) => const BakeryProfileScreen(),
    bakeryMainLayout: (context) => const BakaryMainLayout(),
    // باقي الشاشات
  };
}
