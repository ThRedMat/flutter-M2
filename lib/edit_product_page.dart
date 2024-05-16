import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductPage extends StatefulWidget {
  final String productId;

  const EditProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = '';
  List<String> _categories = []; // Liste des catégories disponibles

  @override
  void initState() {
    super.initState();
    // Récupérez les détails du produit à partir de son ID
    FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _nameController.text = documentSnapshot['name'];
          _priceController.text = documentSnapshot['price'].toString();
          // Vérifiez si le champ "quantity" existe avant de l'assigner
          if ((documentSnapshot.data() as Map).containsKey('quantity')) {
            _quantityController.text = documentSnapshot['quantity'].toString();
          }
          _selectedCategory = documentSnapshot['category'];
        });
      }
    });

    // Récupérez les catégories disponibles à partir de la collection "categories"
    FirebaseFirestore.instance
        .collection('categories')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _categories.add(doc['name']);
        });
      });
    });
  }

  Future<void> _updateProduct() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .update({
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'category': _selectedCategory,
    }).then((value) {
      // Affichez un message de succès ou naviguez vers une autre page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit mis à jour avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }).catchError((error) {
      // Gérez les erreurs
      print('Erreur lors de la mise à jour du produit: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le produit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom du produit',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Prix du produit',
                      prefixIcon: Icon(Icons.euro),
                      suffixText: '€',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantité',
                      prefixIcon: Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory.isNotEmpty &&
                            _categories.contains(_selectedCategory)
                        ? _selectedCategory
                        : null,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _updateProduct,
                          child: Text('Enregistrer'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
