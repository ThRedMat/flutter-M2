import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageEstablishmentsPage extends StatefulWidget {
  @override
  _ManageEstablishmentsPageState createState() =>
      _ManageEstablishmentsPageState();
}

class _ManageEstablishmentsPageState extends State<ManageEstablishmentsPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  bool _isEditing = false;
  String? _currentEstablishmentId;

  Future<void> _addEstablishment() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await FirebaseFirestore.instance.collection('establishments').add({
          'name': _name,
          'address': _address,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Établissement ajouté avec succès')),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout: $e')),
        );
      }
    }
  }

  Future<void> _editEstablishment() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await FirebaseFirestore.instance
            .collection('establishments')
            .doc(_currentEstablishmentId)
            .update({
          'name': _name,
          'address': _address,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Établissement mis à jour avec succès')),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _isEditing = false;
      _currentEstablishmentId = null;
      _name = '';
      _address = '';
    });
  }

  void _startEditing(String id, String name, String address) {
    setState(() {
      _isEditing = true;
      _currentEstablishmentId = id;
      _name = name;
      _address = address;
    });
  }

  Future<void> _deleteEstablishment(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('establishments')
          .doc(id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Établissement supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer les établissements'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'établissement',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value ?? '';
                        },
                        initialValue: _name,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Adresse de l\'établissement',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une adresse';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _address = value ?? '';
                        },
                        initialValue: _address,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isEditing
                              ? _editEstablishment
                              : _addEstablishment,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: Text(
                            _isEditing ? 'Mettre à jour' : 'Ajouter',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('establishments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  }
                  final data = snapshot.requireData;

                  return ListView.builder(
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                      final establishment = data.docs[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          title: Text(
                            establishment['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(establishment['address']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _startEditing(
                                    establishment.id,
                                    establishment['name'],
                                    establishment['address'],
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteEstablishment(establishment.id);
                                },
                              ),
                            ],
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
