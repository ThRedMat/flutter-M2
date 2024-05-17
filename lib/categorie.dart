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
    _categoriesStream =
        FirebaseFirestore.instance.collection('categories').snapshots();
  }

  Future<void> addCategory(String categoryName) async {
    if (categoryName.isEmpty) {
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': categoryName,
      });
      _categoryController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catégorie ajoutée avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
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
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .update({
        'name': newName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catégorie mise à jour avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
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
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Nom de la catégorie',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        addCategory(_categoryController.text);
                      },
                      style: ElevatedButton.styleFrom(),
                      child: Text('Ajouter catégorie'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _categoriesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final categories = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
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
                                        updateCategory(category.id,
                                            _categoryController.text);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(),
                                      child: Text('Enregistrer'),
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
