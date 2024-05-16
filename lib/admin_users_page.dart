import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_user_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  Future<void> _toggleAdminStatus(String userId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .update({'admin': !currentStatus});
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('user').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.requireData;

            return ListView.builder(
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                final user = data.docs[index];
                final userData = user.data() as Map<String, dynamic>;
                final bool isAdmin = userData.containsKey('admin')
                    ? userData['admin'] as bool
                    : false;
                final bool isOnline = userData.containsKey('isOnline')
                    ? userData['isOnline'] as bool
                    : false;

                return ListTile(
                  title: Text(userData['username']),
                  subtitle: Text(isOnline ? 'En ligne' : 'Hors ligne'),
                  trailing: Switch(
                    value: isAdmin,
                    onChanged: (value) {
                      _toggleAdminStatus(user.id, isAdmin);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPage(
                          userId: user.id,
                          userData: userData,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
