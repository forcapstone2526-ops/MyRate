import 'package:flutter/material.dart';
import 'store_owner_store_detail.dart';
import 'store_owner_menu_screen.dart'; // ✅ import your drawer file

class StoreOwnerDashboard extends StatelessWidget {
  const StoreOwnerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hardcoded data for wireframe visualization
    final String storeName = 'Name of the store';
    final String ownerName = 'Owner\'s Name';
    final double averageRating = 2.0;

    return Scaffold(
      // ✅ Attach the Drawer to the right side
      endDrawer: const AppDrawer(),

      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'My Rate',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        toolbarHeight: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 10.0),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: () {
                  // ✅ open the right drawer
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),

      body: Builder(
        builder: (context) {
          final screenHeight = MediaQuery.of(context).size.height;
          final cardHeight = screenHeight * 0.85 - 70;

          return Center(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
              child: Container(
                width: double.infinity,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Image, Name, Owner
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store image placeholder
                        Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.white,
                          child: const Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        // Store Name
                        Text(
                          storeName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Owner Name
                        Text(
                          ownerName,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 30.0),

                        // Rating and Score Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Stars
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < averageRating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 40,
                                );
                              }),
                            ),
                            // Numeric Rating
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom VIEW Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StoreOwnerStoreDetail(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: Colors.black54, width: 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'VIEW',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_right_alt, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
