import 'package:flutter/material.dart';
import 'package:khubzy/app.dart';
import 'package:khubzy/firebase/messaging_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:khubzy/screens/auth/provider/citizen_auth_provider.dart';
import 'package:khubzy/screens/auth/provider/baker_auth_provider.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:khubzy/screens/bakeries/providers/baker_provider.dart';
import 'package:khubzy/screens/main/provider/bottom_nav_provider.dart';
import 'package:khubzy/screens/userTypeSelection/provider/user_type_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // سيتم توليد هذا الملف تلقائياً في الخطوات الجاية

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   MessagingConfig.initFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(MessagingConfig.messageHandler);

  //await uploadUsersToFirebase(); //  مرة واحدة فقط
  //await uploadBakeriesToFirebase(); // مرة واحدة فقط
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => UserTypeProvider()),
       ChangeNotifierProvider(create: (_) => CitizenProvider()..loadCitizens()),
        ChangeNotifierProvider(create: (_) => BakeryAuthProvider()),
        ChangeNotifierProvider(create: (_) => BakeryProvider()),
        ChangeNotifierProvider(create: (_) => BakerProvider()),
      ],
      child: const KhobzyApp(),
    ),
  );
  
}
