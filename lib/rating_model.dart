// Retained for consistency, though currently unused

// Data model for a single rating/feedback history item
class RatingHistoryItem {
  final String storeName;
  final String storeImageUrl; 
  final double rating;
  final DateTime date;
  final String feedback; 

  // IMPORTANT: Removed 'const' from the constructor because DateTime is not constant.
  RatingHistoryItem({
    required this.storeName,
    required this.storeImageUrl,
    required this.rating,
    required this.date,
    this.feedback = '', 
  });
}

