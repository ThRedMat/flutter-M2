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
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoadingCategories = true;
  String? _selectedEstablishment;
  List<String> _establishments = [];
  bool _isLoadingEstablishments = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadEstablishments();
  }

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

  Future<void> _loadEstablishments() async {
    setState(() {
      _isLoadingEstablishments = true;
    });

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('establishments').get();

    List<String> establishments =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();

    setState(() {
      _establishments = establishments;
      _isLoadingEstablishments = false;
    });
  }

  Future<void> addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedEstablishment == null) {
      return;
    }

    // Récupérer l'ID de l'établissement sélectionné
    DocumentSnapshot establishmentDoc = await FirebaseFirestore.instance
        .collection('establishments')
        .where('name', isEqualTo: _selectedEstablishment)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);

    await FirebaseFirestore.instance.collection('products').add({
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'category': _selectedCategory,
      'establishmentId': establishmentDoc.id,
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
              decoration: InputDecoration(
                labelText: 'Nom du produit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Prix du produit',
                suffixText: '€',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _isLoadingCategories
                ? Center(child: CircularProgressIndicator(color: Colors.teal))
                : DropdownButtonFormField<String>(
                    value: _categories.contains(_selectedCategory)
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
            SizedBox(height: 16),
            _isLoadingEstablishments
                ? Center(child: CircularProgressIndicator(color: Colors.teal))
                : DropdownButtonFormField<String>(
                    value: _establishments.contains(_selectedEstablishment)
                        ? _selectedEstablishment
                        : null,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedEstablishment = newValue!;
                      });
                    },
                    items: _establishments.map((String establishment) {
                      return DropdownMenuItem<String>(
                        value: establishment,
                        child: Text(establishment),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Établissement',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addProduct,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'Ajouter Produit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
