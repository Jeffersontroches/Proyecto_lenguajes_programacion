import 'package:flutter/material.dart';
import 'package:proyecto/models/Publicacion.dart';
import 'package:proyecto/pages/DetallePublicacionPage.dart';
import 'package:proyecto/pages/ListadoInscritosPage.dart';
import 'package:proyecto/pages/create_publicacion_page.dart';
import 'package:proyecto/pages/login_page.dart';
import 'package:proyecto/screens/botton_nav_bar.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => BottomNavScreen(),
  '/login': (context) => LoginPage(),
  '/publicacion': (context) => CreatePublicacionPage(),
  '/detallePublicacion': (context) {
    final publicacion =
        ModalRoute.of(context)!.settings.arguments as Publicaciones;
    return DetallePublicacionPage(publicacion: publicacion);
  },
  '/crearPublicacion': (context) {
    final publicacion =
        ModalRoute.of(context)!.settings.arguments as Publicaciones?;
    return CreatePublicacionPage(publicacion: publicacion);
  },
  '/listadoInscritos': (context) {
    final publicacionId = ModalRoute.of(context)!.settings.arguments as String;
    return ListadoInscritosPage(publicacionId: publicacionId);
  },
};
