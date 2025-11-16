import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_dashboard_screen.dart';
import 'qr_scanner_screen.dart';
import 'rate_feedback_screen.dart';
import 'user_feedback_screen.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  Map<String, dynamic>? storeData;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .get();
      if (!doc.exists) return;

      setState(() {
        storeData = doc.data();
      });
    } catch (e) {
      print('Error loading store data: $e');
    }
  }

  List<Widget> _buildStarRating(double rating, {double size = 20.0}) {
    List<Widget> stars = [];
    double current = rating;
    for (int i = 0; i < 5; i++) {
      if (current >= 1) {
        stars.add(Icon(Icons.star, color: Colors.amber[400], size: size));
        current -= 1;
      } else if (current > 0) {
        stars.add(Icon(Icons.star_half, color: Colors.amber[400], size: size));
        current = 0;
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber[400], size: size));
      }
    }
    return stars;
  }

  void _handleBottomBarTap(int index) {
    if (storeData == null) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const QRScannerScreen()));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RateFeedbackScreen(
            storeName: storeData!['name'],
            storeId: widget.storeId,
          ),
        ),
      );
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('yyyy-MM-dd').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    if (storeData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.withOpacity(0.25),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Store Details',
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),

      // ✅ Gradient Fix Applied Here
      body: Container(
        width: double.infinity,
        height: double.infinity, // makes sure gradient fills the screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.withOpacity(0.25),
              Colors.purple.withOpacity(0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                children: [
                  // --- Store Card ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 25.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color.fromARGB(255, 131, 131, 131),
                            image: storeData!['imageUrl'] != null &&
                                    storeData!['imageUrl'].toString().isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(storeData!['imageUrl']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (storeData!['imageUrl'] == null ||
                                  storeData!['imageUrl'].toString().isEmpty)
                              ? const Icon(Icons.store,
                                  color: Colors.black45, size: 80)
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          storeData!['name'] ?? 'Store Name',
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ..._buildStarRating(
                                storeData!['rating']?.toDouble() ?? 0.0,
                                size: 22),
                            const SizedBox(width: 6),
                            Text(
                              (storeData!['rating']?.toDouble() ?? 0.0)
                                  .toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- User Feedback Section ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Feedback',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('ratings')
                              .where('storeId', isEqualTo: widget.storeId)
                              .orderBy('timestamp', descending: true)
                              .limit(3)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Text(
                                'No feedback yet.',
                                style: GoogleFonts.poppins(fontSize: 14),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            return Column(
                              children: docs.map((doc) {
                                final data =
                                    doc.data() as Map<String, dynamic>? ?? {};
                                final comment = data['feedback'] ?? '';
                                final rating = (data['rating'] is num)
                                    ? (data['rating'] as num).toDouble()
                                    : double.tryParse(
                                            data['rating']?.toString() ??
                                                '0.0') ??
                                        0.0;
                                final userName =
                                    data['userName'] ?? 'Anonymous';
                                final date =
                                    _formatDate(data['timestamp'] as Timestamp?);

                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(children: _buildStarRating(rating, size: 16)),
                                      const SizedBox(height: 3),
                                      Text(
                                        comment,
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        date,
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      UserFeedbackScreen(storeId: widget.storeId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('VIEW ALL',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // --- Bottom Nav Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        onTap: _handleBottomBarTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Rate Store'),
        ],
      ),
    );
  }
}
