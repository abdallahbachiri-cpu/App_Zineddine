import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuisinous/providers/buyer_rating_provider.dart';
import 'package:cuisinous/generated/l10n.dart';

class WriteReviewScreen extends StatefulWidget {
  final String dishId;
  final String orderId;
  final String dishName;

  const WriteReviewScreen({
    super.key,
    required this.dishId,
    required this.orderId,
    required this.dishName,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).dishReviews_rateDish)),

      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.dishName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _rating == 0
                      ? S.of(context).dishReviews_rateDish
                      : '$_rating/5',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 400,
                decoration: InputDecoration(
                  labelText: S.of(context).dishReviews_ratingCommentLabel,
                  hintText: S.of(context).dishReviews_ratingCommentHint,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    _isSubmitting || _rating == 0
                        ? null
                        : () async {
                          FocusScope.of(context).unfocus();

                          setState(() => _isSubmitting = true);
                          try {
                            await context
                                .read<BuyerRatingProvider>()
                                .createRating(
                                  dishId: widget.dishId,
                                  orderId: widget.orderId,
                                  rating: _rating,
                                  comment: _commentController.text.trim(),
                                );

                            if (mounted) {
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isSubmitting = false);
                          }
                        },
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(S.of(context).dishReviews_submitReview),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
