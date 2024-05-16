import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditUserPage({Key? key, required this.userId, required this.userData})
      : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userData['email']);
    _usernameController =
        TextEditingController(text: widget.userData['username']);
    _isAdmin = widget.userData['admin'] ?? false;
  }

  Future<void> _updateUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.userId)
        .update({
      'email': _emailController.text,
      'username': _usernameController.text,
      'admin': _isAdmin,
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
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            SwitchListTile(
              title: const Text('Admin'),
              value: _isAdmin,
              onChanged: (bool value) {
                setState(() {
                  _isAdmin = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUser,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
