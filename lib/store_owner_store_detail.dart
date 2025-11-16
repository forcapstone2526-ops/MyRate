import 'package:flutter/material.dart';
// IMPORTANT: Add the import for the destination screen
import 'store_owner_rating_feedback.dart'; 
// Note: This original import is kept for context, though not strictly needed in this file:
// import 'package:your_project_name/store_owner_dashboard.dart'; 

class StoreOwnerStoreDetail extends StatelessWidget {
  const StoreOwnerStoreDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hardcoded data for wireframe visualization
    final String storeName = 'Name of the store';
    final String ownerName = 'Owner\'s Name';
    final double averageRating = 2.0;
    final int totalFeedbacks = 58; // Data for the indicator

    return Scaffold(
      appBar: AppBar(
        // Back button to navigate to StoreOwnerDashboard (uses Navigator.pop)
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
          child: IconButton(
            // Changed icon color to black to match the visual style of the detail screen image
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.pop(context); 
            },
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'My Rate', // Using 'My Rate' to match the detail screen image
            style: TextStyle(
              color: Colors.black, // Changed title color to black
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Changed AppBar background to white
        toolbarHeight: 70,
        actions: const [],
      ),
      
      body: Builder(
        builder: (context) {
          final screenHeight = MediaQuery.of(context).size.height;
          final cardHeight = screenHeight * 0.85 - 70; 

          return Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
              child: Container(
                width: double.infinity,
                height: cardHeight, 
                
                // Card styling with light gray background
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0), // Light gray background
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
                    // Top Section: Image, Name, Owner, Ratings
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store image placeholder with edit icon
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black, size: 24),
                                  onPressed: () {
                                    // TODO: Handle edit image functionality
                                  },
                                ),
                              ),
                            ),
                          ],
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
                        // Owner's Name
                        const SizedBox(height: 8.0),
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
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        
                        // Total Ratings Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Total ratings and feedbacks: $totalFeedbacks',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom Section: VIEW ALL RATINGS & FEEDBACKS Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // --- NAVIGATION CODE ADDED/UPDATED HERE ---
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StoreOwnerRatingFeedback(),
                            ),
                          );
                          // ------------------------------------------
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8D8AFF),
                                Color(0xFF6E4AFF),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 150.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Text(
                                'VIEW ALL RATINGS & FEEDBACKS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}