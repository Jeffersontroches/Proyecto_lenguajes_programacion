import 'package:flutter/material.dart';
import 'package:proyecto/screens/botton_nav_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Bottom Nav Demo', home: BottomNavScreen());
  }
}
