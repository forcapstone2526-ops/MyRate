import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_dashboard_screen.dart';

class RateFeedbackScreen extends StatefulWidget {
  final String storeName;
  final String storeId;

  const RateFeedbackScreen({
    super.key,
    required this.storeName,
    required this.storeId,
  });

  @override
  State<RateFeedbackScreen> createState() => _RateFeedbackScreenState();
}

class _RateFeedbackScreenState extends State<RateFeedbackScreen> {
  double _currentRating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();
  static const int _charLimit = 300;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Widget _buildStar(int starIndex) {
    if (_currentRating >= starIndex) {
      return const Icon(Icons.star, color: Colors.amber, size: 40);
    }
    if (_currentRating > (starIndex - 1) && _currentRating < starIndex) {
      if (_currentRating == starIndex - 0.5) {
        return const Icon(Icons.star_half, color: Colors.amber, size: 40);
      }
    }
    return const Icon(Icons.star_border, color: Colors.amber, size: 40);
  }

  void _handleUpdate(Offset localPosition, double width) {
    if (width == 0) return;
    double newRating = (localPosition.dx / width) * 5.0;
    newRating = newRating.clamp(0.0, 5.0);
    double snappedRating = (newRating * 2).roundToDouble() / 2;
    setState(() {
      _currentRating = snappedRating;
    });
  }

  void _showTopConfirmation(
      BuildContext context, String message, Color color, Duration duration) {
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(duration, () => overlayEntry.remove());
  }

  Future<void> _submitFeedback(BuildContext context) async {
    const Duration confirmationDuration = Duration(seconds: 3);

    if (_currentRating == 0.0) {
      _showTopConfirmation(
        context,
        '⚠️ Please select a star rating before submitting.',
        Colors.orange.shade700,
        const Duration(seconds: 2),
      );
      return;
    }

    final String feedbackText = _feedbackController.text.trim();
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    try {
      final storeDocRef = firestore.collection('stores').doc(widget.storeId);
      final storeSnapshot = await storeDocRef.get();
      if (!storeSnapshot.exists) throw 'Store not found!';

      final storeData = storeSnapshot.data()!;

      // ✅ Generate unique ratingId
      final String ratingId =
          'rating_${DateTime.now().millisecondsSinceEpoch}_${user?.uid ?? "anon"}';

      // ✅ Save to ratings collection
      await firestore.collection('ratings').doc(ratingId).set({
        'storeId': widget.storeId,
        'storeName': widget.storeName,
        'customerId': user?.uid ?? 'Anonymous',
        'feedback': feedbackText,
        'rating': _currentRating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ Update store rating average
      double totalRating = (storeData['totalRating'] is num)
          ? (storeData['totalRating'] as num).toDouble()
          : 0.0;
      int numRatings = (storeData['numRatings'] is int)
          ? storeData['numRatings'] as int
          : 0;

      totalRating += _currentRating;
      numRatings += 1;
      double newAverage = totalRating / numRatings;

      await storeDocRef.update({
        'totalRating': totalRating,
        'numRatings': numRatings,
        'rating': newAverage,
      });

      // ✅ ALSO save to user’s history collection
      if (user != null) {
        final userHistoryRef =
            firestore.collection('customers').doc(user.uid).collection('history');

        await userHistoryRef.add({
          'storeName': widget.storeName,
          'rating': _currentRating,
          'feedback': feedbackText,
          'ratingId': ratingId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // ✅ Confirmation message
      _showTopConfirmation(
        context,
        '💚 You gave ${_currentRating.toStringAsFixed(1)} stars! Thanks for rating ${widget.storeName}!',
        const Color.fromARGB(255, 35, 179, 66),
        confirmationDuration,
      );

      // ✅ Navigate back to dashboard after success
      Future.delayed(confirmationDuration, () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerDashboardScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      });
    } catch (e) {
      _showTopConfirmation(
        context,
        '❌ Error submitting feedback: $e',
        Colors.red,
        const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey starRowKey = GlobalKey();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF6E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Rate & Feedback',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🏪 Store Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEBD9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black54, width: 1),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 70,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // 🏪 Store Name
                Text(
                  widget.storeName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 30),

                // 🌟 Rating Section
                const Text(
                  'How would you rate us?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        final renderBox = starRowKey.currentContext
                            ?.findRenderObject() as RenderBox;
                        _handleUpdate(details.localPosition, renderBox.size.width);
                      },
                      onTapUp: (details) {
                        final renderBox = starRowKey.currentContext
                            ?.findRenderObject() as RenderBox;
                        _handleUpdate(details.localPosition, renderBox.size.width);
                      },
                      child: Row(
                        key: starRowKey,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                            child: _buildStar(index + 1),
                          );
                        }),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // 💬 Feedback Field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Feedback (Optional)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  maxLength: _charLimit,
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts here...',
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 35, 179, 66), width: 2),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),

                const SizedBox(height: 30),

                // 🟩 Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitFeedback(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 189, 230, 191),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side:
                            const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: const Text(
                      'SUBMIT FEEDBACK',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
