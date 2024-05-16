import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = '';
  List<String> _categories = [];
  bool _isLoadingCategories = true;

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    List<String> categories =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();

    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory.isEmpty) {
      return;
    }
    await FirebaseFirestore.instance.collection('products').add({
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'category': _selectedCategory,
    });
    Navigator.pop(context); // Close the add product page after adding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un produit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du produit',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Prix du produit',
                suffixText: '€',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
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
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                  ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addProduct,
                child: Text('Ajouter Produit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
