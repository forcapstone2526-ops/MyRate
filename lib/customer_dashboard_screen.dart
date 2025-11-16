import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store_detail_screen.dart';
import 'qr_scanner_screen.dart';
import 'rating_history_screen.dart';
import 'menu_screen.dart'; // your drawer widget

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _DashboardContent(),
      const QRScannerScreen(),
      const RatingHistoryScreen(),
    ];

    bool showAppBar = _selectedIndex == 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const SizedBox(),
              title: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Center(
                  child: Text(
                    'Dashboard',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 5),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon:
                            const Icon(Icons.menu, color: Color.fromARGB(255, 0, 0, 0), size: 30),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      );
                    },
                  ),
                ),
              ],
            )
          : null,
      endDrawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.withOpacity(0.3),
              Colors.purple.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 10,
      ),
    );
  }
}

// --- DASHBOARD CONTENT ---
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Stores',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('stores').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No stores available.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                final stores = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Store(
                    id: doc.id,
                    name: data['name'] ?? '',
                    imageUrl: data['imageUrl'] ?? '',
                    rating: (data['rating'] is num)
                        ? (data['rating'] as num).toDouble()
                        : double.tryParse(data['rating']?.toString() ?? '0.0') ?? 0.0,
                  );
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    return StoreCard(store: stores[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- STORE MODEL ---
class Store {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;

  Store({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
  });
}

// --- STORE CARD WITH FLOATING ANIMATION ---
class StoreCard extends StatefulWidget {
  final Store store;
  const StoreCard({super.key, required this.store});

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _hovering = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    double remaining = rating;
    for (int i = 0; i < 5; i++) {
      if (remaining >= 1.0) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
        remaining -= 1.0;
      } else if (remaining > 0) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
        remaining = 0;
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
      }
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailScreen(storeId: widget.store.id),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
            ),
            child: Card(
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.purple.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          image: widget.store.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.store.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.store.imageUrl.isEmpty
                            ? const Icon(Icons.store, color: Colors.black38)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.store.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                ..._buildStarRating(widget.store.rating),
                                const SizedBox(width: 6),
                                Text(
                                  widget.store.rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
