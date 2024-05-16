import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart'; // Importez le fichier de la page de connexion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Stocks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Utilisez LoginPage comme page d'accueil
    );
  }
}
