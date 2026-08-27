import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../business_logic/entities/user_review.dart';
import '../business_logic/providers/my_reviews_provider.dart';
import '../business_logic/providers/reviews_provider.dart';
import '../business_logic/repositories/review_image_repository.dart';
import '../business_logic/repositories/review_repository.dart';
import 'reviews_screen.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({
    super.key,
    required this.repository,
    required this.imageRepository,
    required this.userId,
    required this.userName,
  });

  final ReviewRepository repository;
  final ReviewImageRepository imageRepository;
  final String userId;
  final String userName;

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  late final MyReviewsProvider _provider = MyReviewsProvider(
    widget.repository,
    widget.userId,
  )..load();

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Reviews')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            if (_provider.isLoading && _provider.reviews.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_provider.errorMessage != null && _provider.reviews.isEmpty) {
              return _MessageState(
                icon: Icons.cloud_off_outlined,
                message: _provider.errorMessage!,
                actionLabel: 'Try again',
                onAction: _provider.load,
              );
            }
            if (_provider.reviews.isEmpty) {
              return const _MessageState(
                icon: Icons.rate_review_outlined,
                message: 'You have not written any reviews yet.',
              );
            }
            return RefreshIndicator(
              onRefresh: _provider.load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _provider.reviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _UserReviewCard(
                  item: _provider.reviews[index],
                  onTap: () => _openDestination(_provider.reviews[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openDestination(UserReview item) async {
    final reviewsProvider = ReviewsProvider(
      widget.repository,
      widget.imageRepository,
      item.destination,
      currentUserId: widget.userId,
      currentUserName: widget.userName,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ReviewsScreen(
          destination: item.destination,
          reviewsProvider: reviewsProvider,
        ),
      ),
    );
    reviewsProvider.dispose();
    await _provider.load();
  }
}

class _UserReviewCard extends StatelessWidget {
  const _UserReviewCard({required this.item, required this.onTap});

  final UserReview item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.destination.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              Text(
                item.destination.category,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < item.review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 18,
                    color: const Color(0xFFF59A00),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.review.comment,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}
