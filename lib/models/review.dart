class Review {
  const Review({required this.firstName, required this.rating, required this.comment});
  final String firstName, comment;
  final int rating;

  factory Review.fromMap(Map<String, dynamic> m) => Review(
        firstName: (m['first_name'] ?? 'Student') as String,
        rating: (m['rating'] as num?)?.toInt() ?? 0,
        comment: (m['comment'] ?? '') as String,
      );
}
