import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../widgets/rating_stars.dart';

class ReviewFormPage extends ConsumerStatefulWidget {
  final int movieId;
  const ReviewFormPage({super.key, required this.movieId});

  @override
  ConsumerState<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends ConsumerState<ReviewFormPage> {
  int _currentRating = 0;
  final _reviewController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih rating bintang terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // SIMULASI PENGIRIMAN DATA (Nanti tinggal diganti dengan panggilan API)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review berhasil disimpan!'),
          backgroundColor: AppTheme.primary,
        ),
      );
      context.pop(); // Kembali ke halaman detail film
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Review Film'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rating',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: RatingStars(
                rating: _currentRating,
                size: 40,
                isInteractive: true,
                onRatingChanged: (rating) {
                  setState(() => _currentRating = rating);
                },
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Review (Opsional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _reviewController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tulis pendapatmu tentang film ini...',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('SIMPAN REVIEW'),
            ),
          ],
        ),
      ),
    );
  }
}
