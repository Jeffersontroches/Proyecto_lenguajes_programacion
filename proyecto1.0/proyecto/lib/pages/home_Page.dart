import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Horas voae'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: () async {
      //         await FirebaseAuth.instance.signOut();
      //         if (!context.mounted) return;
      //         Navigator.of(context).pushReplacementNamed('/login');
      //       },
      //     ),
      //   ],
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bienvenido a la aplicacion de horas voae',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
