import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final bool isAdmin;

  const EditUserPage(
      {Key? key,
      required this.userId,
      required this.userData,
      required this.isAdmin})
      : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late bool _isAdmin;
  late bool _isEstablishmentAdmin;
  String? _selectedEstablishment;
  List<Map<String, dynamic>> _establishments = [];
  bool _isLoadingEstablishments = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userData['email']);
    _usernameController =
        TextEditingController(text: widget.userData['username']);
    _isAdmin = widget.userData['admin'] ?? false;
    _isEstablishmentAdmin = widget.userData['isEstablishmentAdmin'] ?? false;
    _selectedEstablishment = widget.userData['establishmentId'];

    _loadEstablishments();
  }

  Future<void> _loadEstablishments() async {
    setState(() {
      _isLoadingEstablishments = true;
    });

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('establishments').get();

    List<Map<String, dynamic>> establishments = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
      };
    }).toList();

    setState(() {
      _establishments = establishments;
      _isLoadingEstablishments = false;

      // Find the name of the establishment assigned to the user
      if (_selectedEstablishment != null) {
        var assignedEstablishment = _establishments.firstWhere(
            (establishment) => establishment['id'] == _selectedEstablishment,
            orElse: () => {'name': null});
        _selectedEstablishment = assignedEstablishment['name'];
      }
    });
  }

  Future<void> _updateUser() async {
    DocumentSnapshot establishmentDoc = await FirebaseFirestore.instance
        .collection('establishments')
        .where('name', isEqualTo: _selectedEstablishment)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);

    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.userId)
        .update({
      'email': _emailController.text,
      'username': _usernameController.text,
      'admin': _isAdmin,
      'isEstablishmentAdmin': _isEstablishmentAdmin,
      'establishmentId': establishmentDoc.id,
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            if (widget.isAdmin)
              SwitchListTile(
                title: const Text('Admin'),
                value: _isAdmin,
                onChanged: (bool value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),
            SizedBox(height: 16),
            _isLoadingEstablishments
                ? Center(child: CircularProgressIndicator(color: Colors.teal))
                : DropdownButtonFormField<String>(
                    value: _selectedEstablishment,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedEstablishment = newValue!;
                      });
                    },
                    items: _establishments.map((establishment) {
                      return DropdownMenuItem<String>(
                        value: establishment['name'],
                        child: Text(establishment['name']),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Établissement',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
            SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Admin de l\'établissement'),
              value: _isEstablishmentAdmin,
              onChanged: (bool value) {
                setState(() {
                  _isEstablishmentAdmin = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUser,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
