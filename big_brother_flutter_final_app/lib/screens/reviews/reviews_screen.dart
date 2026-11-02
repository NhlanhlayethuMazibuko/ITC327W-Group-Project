import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _busy = false;
  String? _error;
  Key _key = UniqueKey();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_rating == 0) { setState(() => _error = 'Please choose a star rating.'); return; }
    setState(() { _busy = true; _error = null; });
    try {
      await ReviewService().submit(_rating, _comment.text);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewSubmittedScreen()));
      if (!mounted) return;
      setState(() { _rating = 0; _comment.clear(); _key = UniqueKey(); });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _stars(int value, {double size = 26, ValueChanged<int>? onTap}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            GestureDetector(
              onTap: onTap == null ? null : () => onTap(i),
              child: Icon(i <= value ? Icons.star : Icons.star_border, size: size, color: i <= value ? AppColors.orange : AppColors.border),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Review & Feed Back',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Rate your experience', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        _stars(_rating, size: 34, onTap: (v) => setState(() => _rating = v)),
        const SizedBox(height: 14),
        const Text('Your comment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(controller: _comment, maxLines: 4, maxLength: 500, decoration: const InputDecoration(hintText: 'Write your feed back here ...')),
        ErrorMessage(_error),
        Center(child: SizedBox(width: 200, child: AppButton(label: 'Submit Review', loading: _busy, onPressed: _submit))),
        const SizedBox(height: 18),
        const Text('Previous Reviews', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        LoadView<List<Review>>(
          key: _key,
          loader: ReviewService().previous,
          builder: (context, list, _) => list.isEmpty
              ? const EmptyState(icon: Icons.star_border, message: 'No reviews yet. Be the first!')
              : Column(children: [
                  for (final r in list)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        CircleAvatar(radius: 16, backgroundColor: AppColors.orange, child: Text(r.firstName.isEmpty ? '?' : r.firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.firstName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                          _stars(r.rating, size: 14),
                          if (r.comment.isNotEmpty) Text(r.comment, style: const TextStyle(fontSize: 10)),
                        ])),
                      ]),
                    ),
                ]),
        ),
      ]),
    );
  }
}

class ReviewSubmittedScreen extends StatelessWidget {
  const ReviewSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Review Submitted',
      showBack: false,
      child: SuccessView(
        message: "We've received your review. Your feedback helps us make student living better.",
        primaryLabel: 'Back to Reviews',
        onPrimary: () => Navigator.of(context).pop(),
      ),
    );
  }
}
