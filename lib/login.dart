import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart'; // Importe la bibliothèque de cryptographie
import 'my_home_page.dart'; // Importe MyHomePage depuis le fichier my_home_page.dart

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> createUser(
      String username, String email, String password) async {
    final users = FirebaseFirestore.instance.collection('user');
    final userDoc = users.doc(username);

    // Vérifie si l'utilisateur existe déjà
    final snapshot = await userDoc.get();
    if (snapshot.exists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('Cet utilisateur existe déjà.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        ),
      );
      return;
    }

    // Hasher le mot de passe avant de l'enregistrer
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    await userDoc.set({
      'username': username,
      'email': email,
      'password': hashedPassword, // Enregistre le mot de passe hashé
      'created_at': DateTime.now(),
    });
  }

  void _login() async {
    final usernameOrEmail = _usernameController.text;
    final password = _passwordController.text;

    if (usernameOrEmail.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text(
              'Le nom d\'utilisateur (ou l\'email) et le mot de passe sont requis.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        ),
      );
      return;
    }

    final users = FirebaseFirestore.instance.collection('user');
    final snapshot =
        await users.where('username', isEqualTo: usernameOrEmail).get();

    if (snapshot.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('L\'utilisateur n\'existe pas.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        ),
      );
      return;
    }

    final userData = snapshot.docs.first.data() as Map<String, dynamic>;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    if (userData['password'] != hashedPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('Mot de passe incorrect.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        ),
      );
      return;
    }

    // Connecté avec succès
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: 'Gestion des Produits en Stock',
          username: usernameOrEmail,
        ),
      ),
    );
  }

  void _createAccount() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text(
              'Le nom d\'utilisateur, l\'email et le mot de passe sont requis.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        ),
      );
      return;
    }

    await createUser(username, email, password);

    // Compte créé avec succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compte créé avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true, // Cache le texte pour le champ de mot de passe
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _createAccount,
                  child: const Text('Créer un compte'),
                ),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
