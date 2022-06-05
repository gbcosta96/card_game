import 'package:card_game/screens/home_page.dart';
import 'package:card_game/screens/login_page.dart';
import 'package:card_game/utils/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAhQVosHgVuUhGX8jqvvab-_mJwWyFTwXo",
      appId: "1:533559042921:web:01b357e355a896d758d3f8",
      messagingSenderId: "533559042921",
      projectId: "fodinha-2ff37",
    ),
  );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return GetMaterialApp(
      title: 'Fodinha',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: AppColors.letterRight,
        )
      ),
      home: const LoginPage(),
    );
  }
}
