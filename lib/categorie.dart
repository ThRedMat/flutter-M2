import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _categoryController = TextEditingController();
  late Stream<QuerySnapshot> _categoriesStream;

  @override
  void initState() {
    super.initState();
    // Chargez les catégories existantes lors de l'initialisation de la page
    _categoriesStream =
        FirebaseFirestore.instance.collection('categories').snapshots();
  }

  Future<void> addCategory(String categoryName) async {
    if (categoryName.isEmpty) {
      // Vérifiez si le champ est vide
      return;
    }
    try {
      // Ajoutez la catégorie à la base de données Firestore
      await FirebaseFirestore.instance.collection('categories').add({
        'name': categoryName,
      });
      // Effacez le texte du contrôleur après l'ajout
      _categoryController.clear();
      // Affichez un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catégorie ajoutée avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Gérez les erreurs éventuelles
      print('Erreur lors de l\'ajout de la catégorie: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout de la catégorie'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> updateCategory(String categoryId, String newName) async {
    try {
      // Mettez à jour le nom de la catégorie dans la base de données Firestore
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .update({
        'name': newName,
      });
      // Affichez un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catégorie mise à jour avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Gérez les erreurs éventuelles
      print('Erreur lors de la mise à jour de la catégorie: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour de la catégorie'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des catégories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Nom de la catégorie',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Appel de la fonction pour ajouter la catégorie
                addCategory(_categoryController.text);
              },
              child: Text('Ajouter catégorie'),
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _categoriesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final categories = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Modifier la catégorie'),
                              content: TextField(
                                controller: TextEditingController(
                                    text: category['name']),
                                onChanged: (value) {
                                  // Mettez à jour le texte du contrôleur lorsque l'utilisateur modifie la valeur
                                  _categoryController.text = value;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Nouveau nom',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Appel de la fonction pour mettre à jour la catégorie
                                    updateCategory(
                                        category.id, _categoryController.text);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Enregistrer'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
