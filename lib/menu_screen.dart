import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_rate/main.dart';
import 'dart:io';
import 'customer_edit_profile_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name;
  String? _email;
  String? imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();

        final data = doc.data() ?? {};
        setState(() {
          _name = data['name'] ?? data['username'] ?? 'No name';
          _email = user.email ?? data['email'] ?? data['userEmail'] ?? 'No email';
          imageUrl = data['imageUrl'] ?? '';
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Error loading user: $e');
        setState(() {
          _name = 'Error loading name';
          _email = '';
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MyApp()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Menu',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 🔹 Profile Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: [
                        _isLoading
                            ? const CircularProgressIndicator(color: Color(0xFF6A1B9A))
                            : Column(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor:
                                        const Color.fromARGB(136, 21, 0, 255),
                                    backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                                        ? (imageUrl!.startsWith('http')
                                            ? NetworkImage(imageUrl!)
                                            : FileImage(File(imageUrl!)) as ImageProvider)
                                        : null,
                                    child: (imageUrl == null || imageUrl!.isEmpty)
                                        ? const Icon(Icons.person,
                                            size: 50, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _name ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _email ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 1, color: Colors.black12),

                  // 🔹 Settings Header
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 4),
                    child: Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // ✅ Edit Profile option
                  _buildMenuTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    subtitle: 'Update your name, photo, or info',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerEditProfileScreen(),
                        ),
                      );
                    },
                  ),

                  // ✅ Delete History fixed version
_buildMenuTile(
  icon: Icons.delete,
  title: 'Delete History',
  subtitle: 'Delete your rate and feedback history',
  onTap: () async {
    Navigator.pop(context); // close menu first

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;
    final historyRef = firestore
        .collection('customers')
        .doc(user.uid)
        .collection('history');

    try {
      final snapshot = await historyRef.get();

      if (snapshot.docs.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('No History Found'),
            content: const Text(
              'You have no rating history to delete.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      WriteBatch batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // ✅ SUCCESS POPUP DIALOG
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap OK
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 70,
              ),
              SizedBox(height: 15),
              Text(
                'History Deleted!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Your rating and feedback history has been deleted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // ❌ ERROR POPUP DIALOG
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Error'),
          content: Text(
            'Failed to delete history: $e',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  },
),




                  // 🔹 Support Us Header
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 4),
                    child: Text(
                      'Support Us',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  _buildMenuTile(
                    icon: Icons.info,
                    title: 'About Us',
                    subtitle: 'Learn more about us.',
                    onTap: () => Navigator.pop(context),
                  ),

                  _buildMenuTile(
                    icon: Icons.share,
                    title: 'Share',
                    subtitle: 'Share My Rate with others.',
                    onTap: () => Navigator.pop(context),
                  ),

                  _buildMenuTile(
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    subtitle: 'Learn our Terms and Conditions.',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 🔹 Logout button at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'LOG OUT',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => _handleLogout(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title,
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}
