import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_user_page.dart';

class AdminUsersPage extends StatefulWidget {
  final bool isAdmin;
  final bool isEstablishmentAdmin;
  final String? establishmentId;

  const AdminUsersPage({
    Key? key,
    required this.isAdmin,
    required this.isEstablishmentAdmin,
    required this.establishmentId,
  }) : super(key: key);

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
    Query usersQuery = FirebaseFirestore.instance.collection('user');
    if (widget.isEstablishmentAdmin && !widget.isAdmin) {
      usersQuery = usersQuery.where('establishmentId',
          isEqualTo: widget.establishmentId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: usersQuery.snapshots(),
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
                final bool isAdmin = userData['admin'] ?? false;
                final bool isOnline = userData['isOnline'] ?? false;

                return ListTile(
                  title: Text(userData['username'] ?? 'Inconnu'),
                  subtitle: Row(
                    children: [
                      Icon(
                        isOnline ? Icons.circle : Icons.circle_outlined,
                        color: isOnline ? Colors.green : Colors.grey,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(isOnline ? 'En ligne' : 'Hors ligne'),
                    ],
                  ),
                  trailing: widget.isAdmin
                      ? Switch(
                          value: isAdmin,
                          onChanged: (value) {
                            _toggleAdminStatus(user.id, isAdmin);
                          },
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPage(
                          userId: user.id,
                          userData: userData,
                          isAdmin: widget.isAdmin,
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
