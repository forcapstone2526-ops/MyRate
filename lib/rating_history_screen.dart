import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_dashboard_screen.dart';
import 'package:intl/intl.dart';

class RatingHistoryScreen extends StatefulWidget {
  const RatingHistoryScreen({super.key});

  @override
  State<RatingHistoryScreen> createState() => _RatingHistoryScreenState();
}

class _RatingHistoryScreenState extends State<RatingHistoryScreen> {
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _allRatings = [];
  List<Map<String, dynamic>> _filteredRatings = [];

  @override
  void initState() {
    super.initState();
    _listenToRatings();
  }

  /// ✅ Listen to current user's rating history in Firestore
  void _listenToRatings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> ratings = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        ratings.add({
          'storeName': data['storeName'] ?? 'Unknown Store',
          'rating': (data['rating'] is num)
              ? (data['rating'] as num).toDouble()
              : double.tryParse(data['rating']?.toString() ?? '0.0') ?? 0.0,
          'feedback': data['feedback'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'docId': doc.id, // Add docId to make deletion easier
        });
      }

      setState(() {
        _allRatings = ratings;
        _filteredRatings = List.from(ratings);
      });
    });
  }

  /// ✅ Filter ratings by date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      helpText: 'Select Date',
      confirmText: 'FILTER',
      cancelText: 'SHOW ALL',
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _applyFilter(picked);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Showing history on ${DateFormat('yyyy-MM-dd').format(picked)}')),
      );
    } else {
      setState(() {
        _selectedDate = null;
        _filteredRatings = List.from(_allRatings);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Showing all history.')),
      );
    }
  }

  void _applyFilter(DateTime selectedDate) {
    final DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    setState(() {
      _filteredRatings = _allRatings.where((item) {
        final DateTime itemDate = DateTime(
          item['timestamp'].year,
          item['timestamp'].month,
          item['timestamp'].day,
        );
        return itemDate.isAtSameMomentAs(startOfDay);
      }).toList();
    });
  }

  List<Widget> _buildStarRating(double rating, {double size = 18.0}) {
    List<Widget> stars = [];
    double currentRating = rating;
    for (int i = 0; i < 5; i++) {
      if (currentRating >= 1.0) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: size));
        currentRating -= 1.0;
      } else if (currentRating > 0.0) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
        currentRating = 0.0;
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber, size: size));
      }
    }
    return stars;
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final bool hasFeedback = (item['feedback'] as String).isNotEmpty;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: hasFeedback
              ? (isDarkMode ? Colors.grey[600]! : Colors.grey[500]!)
              : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          width: hasFeedback ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, size: 30, color: Colors.grey),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['storeName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: _buildStarRating(item['rating'])),
                          Text(
                            DateFormat('yyyy-MM-dd').format(item['timestamp']),
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasFeedback) ...[
              const Divider(height: 25, thickness: 0.5),
              const Text(
                'Feedback:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                '"${item['feedback']}"',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()),
      (Route<dynamic> route) => false,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          title: Text(
            'History',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_month, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () => _selectDate(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _filteredRatings.isEmpty
            ? Center(
                child: Text(
                  _selectedDate != null
                      ? 'No history found on ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}.'
                      : 'No history found yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredRatings.length,
                itemBuilder: (context, index) {
                  return _buildHistoryCard(_filteredRatings[index]);
                },
              ),
      ),
    );
  }
}
