import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'camera.dart'; // Import CameraPage
import 'categorie.dart'; // Import CategoriesPage
import 'edit_product_page.dart'; // Import EditProductPage
import 'add_product.dart'; // Import AddProductPage
import 'login.dart'; // Import LoginPage

class MyHomePage extends StatefulWidget {
  final String title;
  final String username;

  const MyHomePage({Key? key, required this.title, required this.username})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userName = '';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.username)
        .get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        userName = userData['username'];
        profileImageUrl = userData.containsKey('profileImageUrl')
            ? userData['profileImageUrl']
            : null;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> deleteProduct(String id) async {
    // Implement deletion logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            const AssetImage('assets/zero-two-bot.jpg'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bonjour $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ajouter un produit depuis la caméra'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Ajouter une catégorie'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Ajouter un produit'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
              },
            ),
            Container(
              color: Colors.red,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await _signOut();
                },
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;

          // Sort the documents by product name
          final sortedDocs = data.docs
            ..sort((a, b) {
              return a['name'].compareTo(b['name']);
            });

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final product = sortedDocs[index];
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  deleteProduct(product.id);
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nom: ${product['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Prix: ${product['price']} €'),
                        Text('Quantité: ${product['quantity']}'),
                        Text('Catégorie: ${product['category']}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProductPage(productId: product.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
