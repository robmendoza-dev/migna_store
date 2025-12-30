import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/client/home_screen.dart'; // Importamos la nueva home

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MignaStoreApp());
}

class MignaStoreApp extends StatelessWidget {
  const MignaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migna Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,

        // --- AQUÍ ESTÁ LO NUEVO QUE NO PODÍAS AGREGAR ---
        // Esto define el estilo de la barra superior para TODA la app
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Fondo blanco limpio
          elevation: 0, // Sin sombra fea
          centerTitle: true, // Título centrado
          titleTextStyle: TextStyle(
            color: Colors.indigo, // Texto color índigo
            fontSize: 24, // Tamaño grande
            fontWeight: FontWeight.w900, // Letra muy gruesa (Bold)
            letterSpacing: 1.2, // Espacio entre letras
          ),
          iconTheme: IconThemeData(color: Colors.indigo), // Iconos (atrás, carrito) en índigo
        ),
        // ------------------------------------------------
      ),
      home: const HomeScreen(),
    );
  }
}