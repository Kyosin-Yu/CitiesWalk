import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../business_logic/entities/place_review.dart';
import '../business_logic/entities/review_destination.dart';
import '../business_logic/providers/reviews_provider.dart';
import '../data/datasources/review_seed_data.dart';
import '../data/repositories/in_memory_review_repository.dart';

enum _ReviewPage { list, detail, write, submitted, mine, edit }

String ratingDescription(int rating) => switch (rating) {
  1 => 'Poor',
  2 => 'Fair',
  3 => 'Good',
  4 => 'Very Good',
  5 => 'Excellent',
  _ => '',
};

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, this.initialDestinationId});

  final String? initialDestinationId;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final ReviewDestination _destination;
  late final ReviewsProvider _reviewsProvider;
  PlaceReview? _selectedReview;
  _ReviewPage _page = _ReviewPage.list;
  bool _mostRecent = true;

  @override
  void initState() {
    super.initState();
    _destination = reviewDestinations.firstWhere(
      (item) => item.id == widget.initialDestinationId,
      orElse: () => reviewDestinations.first,
    );
    _reviewsProvider = ReviewsProvider(
      InMemoryReviewRepository(),
      _destination,
    );
  }

  @override
  void dispose() {
    _reviewsProvider.dispose();
    super.dispose();
  }

  void _showPage(_ReviewPage page, {PlaceReview? review}) {
    setState(() {
      _page = page;
      _selectedReview = review;
    });
  }

  void _saveNewReview(int rating, String comment) {
    if (_reviewsProvider.submitReview(rating: rating, comment: comment)) {
      _showPage(_ReviewPage.submitted);
    }
  }

  void _saveEdit(int rating, String comment) {
    if (_reviewsProvider.updateMyReview(rating: rating, comment: comment)) {
      _showPage(_ReviewPage.mine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _reviewsProvider,
      builder: (context, child) {
        final body = switch (_page) {
          _ReviewPage.list => _ReviewsListPage(
            destination: _destination,
            reviews: _reviewsProvider.reviews,
            mostRecent: _mostRecent,
            onSortChanged: (value) => setState(() => _mostRecent = value),
            onReviewTap: (review) =>
                _showPage(_ReviewPage.detail, review: review),
            onWrite: () => _showPage(_ReviewPage.write),
            onMyReviews: () => _showPage(_ReviewPage.mine),
          ),
          _ReviewPage.detail => _ReviewDetailPage(
            destination: _destination,
            review: _selectedReview!,
            onBack: () => _showPage(_ReviewPage.list),
          ),
          _ReviewPage.write => _ReviewEditorPage(
            title: 'Write a Review',
            destination: _destination,
            onCancel: () => _showPage(_ReviewPage.list),
            onSave: _saveNewReview,
          ),
          _ReviewPage.submitted => _SubmittedPage(
            destination: _destination,
            onBackToReviews: () => _showPage(_ReviewPage.list),
          ),
          _ReviewPage.mine => _MyReviewsPage(
            review: _reviewsProvider.myReview,
            onBack: () => _showPage(_ReviewPage.list),
            onEdit: () => _showPage(_ReviewPage.edit),
            onDelete: _confirmDelete,
          ),
          _ReviewPage.edit => _ReviewEditorPage(
            title: 'Edit Review',
            destination: _destination,
            initialReview: _reviewsProvider.myReview,
            onCancel: () => _showPage(_ReviewPage.mine),
            onSave: _saveEdit,
          ),
        };

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: body),
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFFECEC),
              child: Icon(Icons.delete_outline, color: AppColors.error),
            ),
            SizedBox(height: 14),
            Text('Delete Review?', textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'This review will be permanently removed and cannot be recovered.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE42B31),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _reviewsProvider.deleteMyReview();
    }
  }
}

class _ReviewsListPage extends StatelessWidget {
  const _ReviewsListPage({
    required this.destination,
    required this.reviews,
    required this.mostRecent,
    required this.onSortChanged,
    required this.onReviewTap,
    required this.onWrite,
    required this.onMyReviews,
  });

  final ReviewDestination destination;
  final List<PlaceReview> reviews;
  final bool mostRecent;
  final ValueChanged<bool> onSortChanged;
  final ValueChanged<PlaceReview> onReviewTap;
  final VoidCallback onWrite;
  final VoidCallback onMyReviews;

  @override
  Widget build(BuildContext context) {
    final sorted = List.of(reviews)
      ..sort(
        (a, b) => mostRecent
            ? b.createdAt.compareTo(a.createdAt)
            : b.rating.compareTo(a.rating),
      );
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            _HeroHeader(
              title: 'Reviews',
              subtitle: destination.name,
              actionLabel: 'My Reviews',
              onAction: onMyReviews,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const _DestinationImage(),
                  const SizedBox(height: 10),
                  _RatingSummary(reviews: reviews),
                  const SizedBox(height: 20),
                  _SortToggle(mostRecent: mostRecent, onChanged: onSortChanged),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${reviews.length} Reviews',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      const Text(
                        'Newest first',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...sorted.map(
                    (review) => _ReviewPreview(
                      review: review,
                      onTap: () => onReviewTap(review),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _BottomNav(onProfile: onMyReviews),
        ),
        Positioned(
          right: 26,
          bottom: 64,
          child: FloatingActionButton.extended(
            onPressed: onWrite,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add),
            label: const Text('Write a Review'),
          ),
        ),
      ],
    );
  }
}

class _ReviewDetailPage extends StatelessWidget {
  const _ReviewDetailPage({
    required this.destination,
    required this.review,
    required this.onBack,
  });
  final ReviewDestination destination;
  final PlaceReview review;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _HeroHeader(
        title: 'Review Detail',
        subtitle: destination.name,
        showBack: true,
        onBack: onBack,
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _ReviewContentCard(review: review, expanded: true),
            const SizedBox(height: 10),
            const _PhotosCard(),
            const SizedBox(height: 10),
            const Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '♧  Mark Helpful (41)',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      '⚑  Report',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const _BottomNav(),
    ],
  );
}

class _SubmittedPage extends StatelessWidget {
  const _SubmittedPage({
    required this.destination,
    required this.onBackToReviews,
  });
  final ReviewDestination destination;
  final VoidCallback onBackToReviews;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _HeroHeader(title: 'Review Submitted'),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFDDF1E4),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.check, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 22),
              Text('Thank You!', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Your review of ${destination.name}\nhelps fellow walkers explore Kuala Lumpur with confidence.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '♧  Your review is now visible to fellow walkers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBackToReviews,
                  child: const Text('Back to Reviews'),
                ),
              ),
            ],
          ),
        ),
      ),
      const _BottomNav(),
    ],
  );
}

class _MyReviewsPage extends StatelessWidget {
  const _MyReviewsPage({
    required this.review,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });
  final PlaceReview? review;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _HeroHeader(
        title: 'My Reviews',
        subtitle: review == null ? 'No reviews written' : '1 review written',
        showBack: true,
        onBack: onBack,
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: review == null
              ? const Center(
                  child: Text(
                    'You have not written a review yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : _MyReviewCard(
                  review: review!,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
        ),
      ),
      const _BottomNav(selected: _NavItem.profile),
    ],
  );
}

class _ReviewEditorPage extends StatefulWidget {
  const _ReviewEditorPage({
    required this.title,
    required this.destination,
    required this.onCancel,
    required this.onSave,
    this.initialReview,
  });
  final String title;
  final ReviewDestination destination;
  final PlaceReview? initialReview;
  final VoidCallback onCancel;
  final void Function(int rating, String comment) onSave;
  @override
  State<_ReviewEditorPage> createState() => _ReviewEditorPageState();
}

class _ReviewEditorPageState extends State<_ReviewEditorPage> {
  late final TextEditingController _controller;
  late int _rating;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialReview?.comment ?? '',
    );
    _rating = widget.initialReview?.rating ?? 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _HeroHeader(title: widget.title, showBack: true, onBack: widget.onCancel),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFBA8B62),
                  child: Icon(Icons.location_city, color: Colors.white),
                ),
                title: const Text(
                  'EDITING REVIEW FOR',
                  style: TextStyle(fontSize: 9, color: AppColors.secondary),
                ),
                subtitle: Text(
                  widget.destination.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Rating',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          IconButton(
                            tooltip: 'Give $i stars',
                            onPressed: () => setState(() => _rating = i),
                            icon: Icon(
                              i <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFF59A00),
                              size: 31,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          ratingDescription(_rating),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFF59A00),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Your Review',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${_controller.text.length}/500',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _controller,
                      minLines: 5,
                      maxLines: 7,
                      maxLength: 500,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Share your experience...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const _PhotosCard(editable: true),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _rating > 0 && _controller.text.trim().isNotEmpty
                    ? () => widget.onSave(_rating, _controller.text.trim())
                    : null,
                child: Text(
                  widget.title == 'Edit Review'
                      ? 'Save Changes'
                      : 'Submit Review',
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.showBack = false,
    this.onBack,
  });
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showBack;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => Container(
    height: 136,
    padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showBack)
              IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
              ),
            const Text(
              '✦  CITIESWALK',
              style: TextStyle(
                color: Color(0xFF95D9AF),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            if (actionLabel != null)
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(actionLabel!),
              ),
          ],
        ),
        const Spacer(),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(color: Color(0xFF95D9AF), fontSize: 11),
          ),
      ],
    ),
  );
}

class _DestinationImage extends StatelessWidget {
  const _DestinationImage();
  @override
  Widget build(BuildContext context) => Container(
    height: 87,
    alignment: Alignment.bottomLeft,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF203D57), Color(0xFFC68759)],
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Chip(
      label: Text('Heritage Walk', style: TextStyle(fontSize: 9)),
      visualDensity: VisualDensity.compact,
    ),
  );
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.reviews});

  final List<PlaceReview> reviews;

  @override
  Widget build(BuildContext context) {
    final totalRating = reviews.fold<int>(
      0,
      (total, review) => total + review.rating,
    );
    final average = reviews.isEmpty ? 0.0 : totalRating / reviews.length;
    final counts = List<int>.generate(
      5,
      (index) => reviews.where((review) => review.rating == 5 - index).length,
    );
    final largestCount = counts.fold<int>(
      1,
      (largest, count) => count > largest ? count : largest,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Avg. Rating',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  _Stars(rating: average.round(), size: 14),
                  Text(
                    '${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: List.generate(5, (index) {
                  final star = 5 - index;
                  final count = counts[index];
                  return Row(
                    children: [
                      Text('$star', style: const TextStyle(fontSize: 9)),
                      const Icon(Icons.star, color: Color(0xFFF59A00), size: 9),
                      const SizedBox(width: 5),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: count / largestCount,
                          minHeight: 4,
                          color: AppColors.accent,
                          backgroundColor: const Color(0xFFE5F1E9),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text('$count', style: const TextStyle(fontSize: 9)),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({required this.mostRecent, required this.onChanged});
  final bool mostRecent;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFFE4F3E9),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: [
        _SortButton(
          label: 'Most Recent',
          active: mostRecent,
          onTap: () => onChanged(true),
        ),
        _SortButton(
          label: 'Highest Rated',
          active: !mostRecent,
          onTap: () => onChanged(false),
        ),
      ],
    ),
  );
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: active ? AppColors.primary : Colors.transparent,
        foregroundColor: active ? Colors.white : AppColors.primary,
        minimumSize: const Size(0, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    ),
  );
}

class _ReviewPreview extends StatelessWidget {
  const _ReviewPreview({required this.review, required this.onTap});
  final PlaceReview review;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    review.authorName.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _Stars(rating: review.rating, size: 14),
            const SizedBox(height: 7),
            Text(
              review.comment,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReviewContentCard extends StatelessWidget {
  const _ReviewContentCard({required this.review, required this.expanded});
  final PlaceReview review;
  final bool expanded;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  review.authorName.substring(0, 1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.authorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _Stars(rating: review.rating, size: 14),
                ],
              ),
              const Spacer(),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            expanded
                ? '${review.comment} It is a full sensory experience — the sizzle of wok-fried Hokkien mee, the scent of incense drifting from the temple, hawkers calling out in Cantonese. Get there hungry. The char kway teow stall on the far end is legendary — 45-minute queue and worth every minute.'
                : review.comment,
            style: const TextStyle(fontSize: 12, height: 1.55),
          ),
        ],
      ),
    ),
  );
}

class _MyReviewCard extends StatelessWidget {
  const _MyReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });
  final PlaceReview review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Stars(rating: review.rating, size: 15),
              const SizedBox(width: 5),
              Text(
                '${review.rating}.0',
                style: const TextStyle(fontSize: 10, color: Color(0xFFF59A00)),
              ),
              const Spacer(),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(review.comment),
          ),
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text('Edit'),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 15),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({this.editable = false});
  final bool editable;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PHOTOS',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          if (editable)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(62, 48)),
            )
          else
            Row(
              children: [
                Expanded(child: _PhotoTile(color: const Color(0xFF795548))),
                const SizedBox(width: 8),
                Expanded(child: _PhotoTile(color: const Color(0xFFB26E42))),
              ],
            ),
        ],
      ),
    ),
  );
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(child: Icon(Icons.photo, color: Colors.white70)),
  );
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, required this.size});
  final int rating;
  final double size;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      5,
      (index) => Icon(
        index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
        size: size,
        color: const Color(0xFFF59A00),
      ),
    ),
  );
}

enum _NavItem { home, explore, journey, rewards, profile }

class _BottomNav extends StatelessWidget {
  const _BottomNav({this.selected = _NavItem.explore, this.onProfile});
  final _NavItem selected;
  final VoidCallback? onProfile;
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home', _NavItem.home),
      (Icons.explore_outlined, 'Explore', _NavItem.explore),
      (Icons.route_outlined, 'Journey', _NavItem.journey),
      (Icons.card_giftcard_outlined, 'Rewards', _NavItem.rewards),
      (Icons.person_outline, 'Profile', _NavItem.profile),
    ];
    return Container(
      height: 62,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final active = item.$3 == selected;
          return InkWell(
            onTap: item.$3 == _NavItem.profile ? onProfile : null,
            child: SizedBox(
              width: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.$1,
                    color: active ? AppColors.primary : const Color(0xFF9EB2BB),
                    size: 18,
                  ),
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 8,
                      color: active
                          ? AppColors.primary
                          : const Color(0xFF9EB2BB),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
