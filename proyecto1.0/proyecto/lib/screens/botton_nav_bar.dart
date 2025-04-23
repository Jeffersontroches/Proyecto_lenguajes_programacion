import 'package:flutter/material.dart';
import 'package:proyecto/pages/home_Page.dart';
import 'package:proyecto/pages/suscrito_Page.dart';
import 'package:proyecto/pages/profile_page.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;

  static final List<Widget> _pages = [
    HomePage(),
    SuscritoPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/images/puma.png', height: 30),
              const SizedBox(width: 10),
              const Text('HORAS VOAE'),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 202, 225, 255),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/puma.png', height: 30),
            const SizedBox(width: 10),
            const Text('HORAS VOAE'),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 202, 225, 255),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 26, 255),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_sharp),
            label: 'Mis inscripciones',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
