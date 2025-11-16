import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Required for date formatting

class StoreOwnerRatingFeedback extends StatefulWidget {
  const StoreOwnerRatingFeedback({Key? key}) : super(key: key);

  @override
  State<StoreOwnerRatingFeedback> createState() => _StoreOwnerRatingFeedbackState();
}

class _StoreOwnerRatingFeedbackState extends State<StoreOwnerRatingFeedback> {
  DateTime? _selectedDate;

  // Dummy feedback data
  final List<Map<String, dynamic>> _feedbacks = [
    {
      'user': 'wahsahp',
      'date': DateTime(2025, 11, 1),
      'rating': 3,
      'comment': 'Pwede na, pangit nga lang service nila.',
    },
    {
      'user': 'Lou',
      'date': DateTime(2025, 10, 29),
      'rating': 1,
      'comment': 'ANG SUNGIT NI ATENG NAG TITINDA, ANG ASIM NAMAN TIGNAN.',
    },
    {
      'user': 'Monggee',
      'date': DateTime(2025, 10, 29),
      'rating': 2,
      'comment': 'Arf Arf!!😡',
    },
    {
      'user': 'wahsahp',
      'date': DateTime(2025, 11, 1),
      'rating': 3,
      'comment': 'Pwede na, pangit nga lang service nila.',
    },
    {
      'user': 'Lou',
      'date': DateTime(2025, 10, 29),
      'rating': 1,
      'comment': 'ANG SUNGIT NI ATENG NAG TITINDA, ANG ASIM NAMAN TIGNAN.',
    },
    {
      'user': 'Monggee',
      'date': DateTime(2025, 10, 29),
      'rating': 2,
      'comment': 'Arf Arf!!😡',
    },

        {
      'user': 'Monggee',
      'date': DateTime(2025, 04, 11),
      'rating': 2,
      'comment': 'Arf Arf!!😡',
    },

    {
      'user': 'wahsahp',
      'date': DateTime(2025, 09, 10),
      'rating': 3,
      'comment': 'Pwede na, pangit nga lang service nila.',
    },

  ];

  List<Map<String, dynamic>> _filteredFeedbacks = [];

  @override
  void initState() {
    super.initState();
    _filteredFeedbacks = List.from(_feedbacks);
    _filteredFeedbacks.sort((a, b) => b['date'].compareTo(a['date']));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Date',
      confirmText: 'FILTER',
      cancelText: 'SHOW ALL',
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final DateTime startOfDay = DateTime(picked.year, picked.month, picked.day);
        _filteredFeedbacks = _feedbacks.where((feedback) {
          final DateTime feedbackDate =
              DateTime(feedback['date'].year, feedback['date'].month, feedback['date'].day);
          return feedbackDate.isAtSameMomentAs(startOfDay);
        }).toList();
        _filteredFeedbacks.sort((a, b) => b['date'].compareTo(a['date']));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Filtered feedback from: ${DateFormat('yyyy-MM-dd').format(picked)}')),
      );
    } else {
      setState(() {
        _selectedDate = null;
        _filteredFeedbacks = List.from(_feedbacks);
        _filteredFeedbacks.sort((a, b) => b['date'].compareTo(a['date']));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Showing all feedback records.')),
      );
    }
  }

  Widget _buildFeedbackItem(Map<String, dynamic> feedback) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(feedback['date']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black54,
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        feedback['user'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color: index < feedback['rating'] ? Colors.amber : Colors.grey[300],
                        size: 14,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback['comment'],
                    style: const TextStyle(fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'My Rate',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        toolbarHeight: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.black, size: 30),
              onPressed: () => _selectDateRange(context),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Filtering: ${DateFormat('MMM d, yyyy').format(_selectedDate!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Expanded(
                  child: _filteredFeedbacks.isEmpty
                      ? const Center(
                          child: Text(
                            'No feedback found for this date.',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredFeedbacks.length,
                          itemBuilder: (context, index) {
                            return _buildFeedbackItem(_filteredFeedbacks[index]);
                          },
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
