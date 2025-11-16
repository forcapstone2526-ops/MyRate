import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ----------------------
// Feedback model
// ----------------------
class StoreFeedback {
  final String username;
  final String comment;
  final String date;
  final double rating;

  StoreFeedback({
    required this.username,
    required this.comment,
    required this.date,
    required this.rating,
  });
}

// ----------------------
// User Feedback Screen
// ----------------------
class UserFeedbackScreen extends StatelessWidget {
  final String storeId;

  const UserFeedbackScreen({super.key, required this.storeId});

  // ----------------------
  // Star builder
  // ----------------------
  List<Widget> _buildStarRating(double rating, {double size = 16.0}) {
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

  @override
  Widget build(BuildContext context) {
    // Real-time stream from 'ratings' collection
    final feedbackStream = FirebaseFirestore.instance
        .collection('ratings')
        .where('storeId', isEqualTo: storeId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('User Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: feedbackStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading feedback: ${snapshot.error}'));
          }

          final feedbacks = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            String dateStr = '';
            if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
              dateStr = (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0];
            } else if (data['date'] != null) {
              dateStr = data['date'];
            }

            return StoreFeedback(
              username: data['customerId'] ?? 'Anonymous',
              comment: data['feedback'] ?? '',
              date: dateStr,
              rating: (data['rating'] is num)
                  ? (data['rating'] as num).toDouble()
                  : double.tryParse(data['rating']?.toString() ?? '0.0') ?? 0.0,
            );
          }).toList() ?? [];

          if (feedbacks.isEmpty) {
            return const Center(child: Text('No feedback yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final f = feedbacks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(f.date,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: _buildStarRating(f.rating, size: 16)),
                    const SizedBox(height: 6),
                    Text(f.comment),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
