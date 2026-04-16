import 'package:collection/collection.dart';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/data/models/rating.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/buyer_rating_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuItemReviewsScreen extends StatefulWidget {
  final String dishId;
  final String orderId;
  final String dishName;

  const MenuItemReviewsScreen({
    super.key,
    required this.dishId,
    required this.orderId,
    required this.dishName,
  });

  @override
  State<MenuItemReviewsScreen> createState() => _MenuItemReviewsScreenState();
}

class _MenuItemReviewsScreenState extends State<MenuItemReviewsScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEditing = false;

  final ValueNotifier<bool> _showMinimizedBar = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerRatingProvider>().fetchDishRatings(widget.dishId);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 80 && !_showMinimizedBar.value) {
        _showMinimizedBar.value = true;
      } else if (_scrollController.offset <= 80 && _showMinimizedBar.value) {
        _showMinimizedBar.value = false;
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _showMinimizedBar.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitReview(BuyerRatingProvider provider) async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).dishReviews_rateDish),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final existingReview = provider.dishRatings.firstWhereOrNull(
      (r) => r.orderId == widget.orderId,
    );

    try {
      if (existingReview != null) {
        await provider.updateRating(
          ratingId: existingReview.id,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
      } else {
        await provider.createRating(
          dishId: widget.dishId,
          orderId: widget.orderId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        await provider.fetchDishRatings(widget.dishId, refresh: true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).recipe_reviewSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _startEditing(Rating review) {
    setState(() {
      _isEditing = true;
      _rating = review.rating;
      _commentController.text = review.comment ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _rating = 0;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<BuyerRatingProvider>(
          builder: (context, provider, _) {
            if (provider.isDetailLoading || provider.isDishLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final ratings =
                provider.dishRatings
                    .where((r) => r.dishId == widget.dishId)
                    .toList();

            final userReview = ratings.firstWhereOrNull(
              (r) => r.orderId == widget.orderId,
            );

            final hasUserReview = userReview != null;
            final showForm = !hasUserReview || _isEditing;

            final avgRating =
                ratings.isNotEmpty
                    ? ratings.map((r) => r.rating).reduce((a, b) => a + b) /
                        ratings.length
                    : 0.0;

            final otherReviews =
                ratings.where((r) => r.orderId != widget.orderId).toList();

            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      elevation: 0,
                      backgroundColor: AppConsts.backgroundColor,
                      foregroundColor: Colors.black,
                      title: Text(S.of(context).dishReviews_rateDish),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.dishName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${ratings.length} ${S.of(context).dishReviews_reviews})',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (showForm)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isEditing
                                            ? S
                                                .of(context)
                                                .dishReviews_yourReview
                                            : S
                                                .of(context)
                                                .dishReviews_rateDish,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (_isEditing)
                                        IconButton(
                                          onPressed: _cancelEditing,
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.grey,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (index) => IconButton(
                                        icon: Icon(
                                          index < _rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 32,
                                        ),
                                        onPressed:
                                            () => setState(
                                              () => _rating = index + 1,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _commentController,
                                    maxLines: 3,
                                    maxLength: 400,
                                    decoration: InputDecoration(
                                      labelText:
                                          S
                                              .of(context)
                                              .dishReviews_ratingCommentLabel,
                                      hintText:
                                          S
                                              .of(context)
                                              .dishReviews_ratingCommentHint,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed:
                                        _isSubmitting
                                            ? null
                                            : () => _submitReview(provider),
                                    child:
                                        _isSubmitting
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(
                                              _isEditing
                                                  ? S.of(context).userInfo_save
                                                  : S
                                                      .of(context)
                                                      .dishReviews_submitReview,
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),

                          child: _ReviewCard(
                            userReview!,
                            isUser: true,
                            onEdit: () => _startEditing(userReview),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8,
                        ),
                        child: Text(
                          S.of(context).dishReviews_reviews,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (otherReviews.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              S.of(context).noReviewsYet,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: _ReviewCard(
                              otherReviews[index],
                              isUser: false,
                            ),
                          ),
                          childCount: otherReviews.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showMinimizedBar,
                  builder: (context, show, _) {
                    if (!show || hasUserReview) return const SizedBox.shrink();
                    return Positioned(
                      top: MediaQuery.of(context).padding.top + kToolbarHeight,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _scrollToForm,
                        child: Container(
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.rate_review,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                S.of(context).dishReviews_rateDish,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.expand_less,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Rating review;
  final bool isUser;

  final VoidCallback? onEdit;

  const _ReviewCard(this.review, {this.isUser = false, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = review.buyerName;
    final rating = review.rating;
    final comment = review.comment ?? '';
    final createdAt = review.createdAt;
    final createdAtStr =
        '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      isUser ? AppConsts.accentColor : Colors.grey[300],
                  radius: 16,
                  child: Icon(
                    isUser ? Icons.person : Icons.person_outline,
                    color: isUser ? Colors.white : Colors.grey[600],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isUser ? S.of(context).dishReviews_yourReview : userName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                if (isUser && onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  )
                else
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),

            if (isUser && onEdit != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
              ),

            if (comment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(comment, style: theme.textTheme.bodyMedium),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                createdAtStr,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
