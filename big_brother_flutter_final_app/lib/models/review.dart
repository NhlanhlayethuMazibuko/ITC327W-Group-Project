class Review {
  const Review({required this.firstName, required this.rating, required this.comment});
  final String firstName, comment;
  final int rating;

  factory Review.fromMap(Map<String, dynamic> m) => Review(
        // reviews has no first_name column.
        firstName: 'Student',
        rating: (m['rating'] as num?)?.toInt() ?? 0,
        comment: (m['comment'] ?? '') as String,
      );
}
