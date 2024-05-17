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
  String? _selectedCategory;
  List<String> _categories = [];
  String? _selectedEstablishment;
  List<String> _establishments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCategories();
    await _loadEstablishments();
    await _loadProductDetails();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProductDetails() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _priceController.text = data['price']?.toString() ?? '';
        _quantityController.text = data['quantity']?.toString() ?? '';
        _selectedCategory = data['category'];

        // Récupérer le nom de l'établissement à partir de l'ID
        FirebaseFirestore.instance
            .collection('establishments')
            .doc(data['establishmentId'])
            .get()
            .then((establishmentDoc) {
          setState(() {
            _selectedEstablishment = establishmentDoc['name'];
          });
        });
      });
    }
  }

  Future<void> _loadCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    List<String> categories =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();

    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadEstablishments() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('establishments').get();

    List<String> establishments =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();

    setState(() {
      _establishments = establishments;
    });
  }

  Future<void> _updateProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedEstablishment == null) {
      return;
    }

    try {
      // Récupérer l'ID de l'établissement sélectionné
      DocumentSnapshot establishmentDoc = await FirebaseFirestore.instance
          .collection('establishments')
          .where('name', isEqualTo: _selectedEstablishment)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'category': _selectedCategory,
        'establishmentId': establishmentDoc.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit mis à jour avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du produit'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le produit'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
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
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value:
                              _establishments.contains(_selectedEstablishment)
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
                            prefixIcon: Icon(Icons.business),
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
