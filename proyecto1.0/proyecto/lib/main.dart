import 'package:flutter/material.dart';
import 'package:proyecto/pages/create_publicacion_page.dart';
import 'package:proyecto/pages/login_page.dart';
import 'package:proyecto/screens/botton_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horas voae',
      initialRoute: '/',
      //home: LoginPage(),
      routes: {
        '/': (context) => BottomNavScreen(),
        '/login': (context) => LoginPage(),
        '/publicacion': (context) => CreatePublicacionPage(),
      },
    );
  }
}
