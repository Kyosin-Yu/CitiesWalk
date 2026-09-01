import 'package:citieswalk/core/localization/localized_material.dart';

import '../../../app/theme/app_colors.dart';
import '../business_logic/entities/place_review.dart';
import '../business_logic/entities/review_destination.dart';
import '../business_logic/providers/reviews_provider.dart';

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
  const ReviewsScreen({
    super.key,
    required this.destination,
    required this.reviewsProvider,
    this.onClose,
  });

  final ReviewDestination destination;
  final ReviewsProvider reviewsProvider;
  final VoidCallback? onClose;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final ReviewDestination _destination;
  late final ReviewsProvider _reviewsProvider;
  PlaceReview? _selectedReview;
  _ReviewPage _page = _ReviewPage.list;
  bool _mostRecent = true;
  int? _ratingFilter;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _reviewsProvider = widget.reviewsProvider;
  }

  void _showPage(_ReviewPage page, {PlaceReview? review}) {
    setState(() {
      _page = page;
      _selectedReview = review;
    });
  }

  Future<void> _saveNewReview(
    int rating,
    String comment,
    bool isAnonymous,
  ) async {
    if (await _reviewsProvider.submitReview(
      rating: rating,
      comment: comment,
      isAnonymous: isAnonymous,
    )) {
      _showPage(_ReviewPage.submitted);
    } else {
      _showProviderError();
    }
  }

  Future<void> _saveEdit(int rating, String comment, bool isAnonymous) async {
    if (await _reviewsProvider.updateMyReview(
      rating: rating,
      comment: comment,
      isAnonymous: isAnonymous,
    )) {
      _showPage(_ReviewPage.mine);
    } else {
      _showProviderError();
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
            currentUserId: _reviewsProvider.currentUserId,
            isLoading: _reviewsProvider.isLoading,
            errorMessage: _reviewsProvider.errorMessage,
            onRetry: _reviewsProvider.loadReviews,
            mostRecent: _mostRecent,
            onSortChanged: (value) => setState(() => _mostRecent = value),
            ratingFilter: _ratingFilter,
            onRatingFilterChanged: (value) =>
                setState(() => _ratingFilter = value),
            onReviewTap: (review) =>
                _showPage(_ReviewPage.detail, review: review),
            onWrite: () {
              _reviewsProvider.beginDraft();
              _showPage(_ReviewPage.write);
            },
            onMyReviews: () => _showPage(_ReviewPage.mine),
            onBack: widget.onClose ?? () => Navigator.of(context).maybePop(),
          ),
          _ReviewPage.detail => _ReviewDetailPage(
            destination: _destination,
            review: _selectedReview!,
            isUpdatingHelpful: _reviewsProvider.isUpdatingHelpful(
              _selectedReview!.id,
            ),
            onBack: () => _showPage(_ReviewPage.list),
            onHelpful: () => _toggleHelpful(_selectedReview!),
          ),
          _ReviewPage.write => _ReviewEditorPage(
            title: 'Write a Review',
            destination: _destination,
            onCancel: () => _showPage(_ReviewPage.list),
            onSave: _saveNewReview,
            photos: _reviewsProvider.draftPhotos,
            isPickingPhotos: _reviewsProvider.isSelectingPhotos,
            isSaving: _reviewsProvider.isSaving,
            onAddPhotos: _addDraftPhotos,
            onRemovePhoto: _reviewsProvider.removeDraftPhoto,
          ),
          _ReviewPage.submitted => _SubmittedPage(
            destination: _destination,
            onBackToReviews: () => _showPage(_ReviewPage.list),
          ),
          _ReviewPage.mine => _MyReviewsPage(
            review: _reviewsProvider.myReview,
            canEdit: _reviewsProvider.canEditMyReview,
            onBack: () => _showPage(_ReviewPage.list),
            onEdit: () {
              _reviewsProvider.beginDraft(
                _reviewsProvider.myReview?.photos ?? const [],
              );
              _showPage(_ReviewPage.edit);
            },
            onDelete: _confirmDelete,
          ),
          _ReviewPage.edit => _ReviewEditorPage(
            title: 'Edit Review',
            destination: _destination,
            initialReview: _reviewsProvider.myReview,
            onCancel: () => _showPage(_ReviewPage.mine),
            onSave: _saveEdit,
            photos: _reviewsProvider.draftPhotos,
            isPickingPhotos: _reviewsProvider.isSelectingPhotos,
            isSaving: _reviewsProvider.isSaving,
            onAddPhotos: _addDraftPhotos,
            onRemovePhoto: _reviewsProvider.removeDraftPhoto,
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
      final deleted = await _reviewsProvider.deleteMyReview();
      if (!mounted) return;
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted.')),
        );
        _showPage(_ReviewPage.list);
        return;
      }
      if (_reviewsProvider.errorMessage == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_reviewsProvider.errorMessage!)));
    }
  }

  Future<void> _addDraftPhotos() async {
    await _reviewsProvider.addDraftPhotos();
    if (!mounted || _reviewsProvider.errorMessage == null) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_reviewsProvider.errorMessage!)));
  }

  void _showProviderError() {
    final errorMessage = _reviewsProvider.errorMessage;
    if (!mounted || errorMessage == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _toggleHelpful(PlaceReview review) async {
    if (review.userId == _reviewsProvider.currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot mark your own review.')),
      );
      return;
    }
    final updated = await _reviewsProvider.toggleHelpful(review.id);
    if (!mounted) return;
    if (updated == null) {
      _showProviderError();
      return;
    }
    setState(() => _selectedReview = updated);
  }
}

class _ReviewsListPage extends StatelessWidget {
  const _ReviewsListPage({
    required this.destination,
    required this.reviews,
    required this.currentUserId,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.mostRecent,
    required this.onSortChanged,
    required this.ratingFilter,
    required this.onRatingFilterChanged,
    required this.onReviewTap,
    required this.onWrite,
    required this.onMyReviews,
    required this.onBack,
  });

  final ReviewDestination destination;
  final List<PlaceReview> reviews;
  final String currentUserId;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final bool mostRecent;
  final ValueChanged<bool> onSortChanged;
  final int? ratingFilter;
  final ValueChanged<int?> onRatingFilterChanged;
  final ValueChanged<PlaceReview> onReviewTap;
  final VoidCallback onWrite;
  final VoidCallback onMyReviews;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final visibleReviews = reviews
        .where(
          (review) => ratingFilter == null || review.rating == ratingFilter,
        )
        .toList();
    final sorted = List.of(visibleReviews)
      ..sort(
        (a, b) => mostRecent
            ? b.createdAt.compareTo(a.createdAt)
            : b.rating.compareTo(a.rating),
      );
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _HeroHeader(
              title: 'Reviews',
              subtitle: destination.name,
              actionLabel: 'My Reviews',
              onAction: onMyReviews,
              showBack: true,
              onBack: onBack,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _DestinationInfo(destination: destination),
                  const SizedBox(height: 10),
                  _RatingSummary(reviews: reviews),
                  const SizedBox(height: 20),
                  _SortToggle(mostRecent: mostRecent, onChanged: onSortChanged),
                  const SizedBox(height: 10),
                  _RatingFilterBar(
                    selectedRating: ratingFilter,
                    onChanged: onRatingFilterChanged,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${visibleReviews.length} ${visibleReviews.length == 1 ? 'Review' : 'Reviews'}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Text(
                        mostRecent ? 'Newest first' : 'Highest rated',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isLoading && reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (errorMessage != null && reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: onRetry,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    )
                  else if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 34,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 34,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No reviews yet.',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Be the first to share your experience!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else if (sorted.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No reviews match this rating yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...sorted.map(
                      (review) => _ReviewPreview(
                        review: review,
                        isCurrentUsersReview: review.userId == currentUserId,
                        onTap: () => onReviewTap(review),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 26,
          bottom: 24,
          child: FloatingActionButton.extended(
            onPressed: onWrite,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
    required this.isUpdatingHelpful,
    required this.onBack,
    required this.onHelpful,
  });
  final ReviewDestination destination;
  final PlaceReview review;
  final bool isUpdatingHelpful;
  final VoidCallback onBack;
  final VoidCallback onHelpful;

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
            _ReviewContentCard(review: review),
            const SizedBox(height: 10),
            _PhotosCard(photos: review.photos),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isUpdatingHelpful ? null : onHelpful,
                      icon: isUpdatingHelpful
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              review.isMarkedHelpful
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                            ),
                      label: Text(
                        isUpdatingHelpful
                            ? 'Updating...'
                            : '${review.isMarkedHelpful ? 'Helpful' : 'Mark Helpful'} (${review.helpfulCount})',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: review.isMarkedHelpful
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    ],
  );
}

class _MyReviewsPage extends StatelessWidget {
  const _MyReviewsPage({
    required this.review,
    required this.canEdit,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });
  final PlaceReview? review;
  final bool canEdit;
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
                  canEdit: canEdit,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
        ),
      ),
    ],
  );
}

class _ReviewEditorPage extends StatefulWidget {
  const _ReviewEditorPage({
    required this.title,
    required this.destination,
    required this.onCancel,
    required this.onSave,
    required this.photos,
    required this.isPickingPhotos,
    required this.isSaving,
    required this.onAddPhotos,
    required this.onRemovePhoto,
    this.initialReview,
  });
  final String title;
  final ReviewDestination destination;
  final PlaceReview? initialReview;
  final VoidCallback onCancel;
  final Future<void> Function(int rating, String comment, bool isAnonymous)
  onSave;
  final bool isSaving;
  final List<ReviewPhoto> photos;
  final bool isPickingPhotos;
  final Future<void> Function() onAddPhotos;
  final ValueChanged<ReviewPhoto> onRemovePhoto;
  @override
  State<_ReviewEditorPage> createState() => _ReviewEditorPageState();
}

class _ReviewEditorPageState extends State<_ReviewEditorPage> {
  late final TextEditingController _controller;
  late int _rating;
  late bool _isAnonymous;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialReview?.comment ?? '',
    );
    _rating = widget.initialReview?.rating ?? 0;
    _isAnonymous = widget.initialReview?.isAnonymous ?? false;
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
                          '${_controller.text.length}/${ReviewsProvider.maxReviewCharacters}',
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
                      maxLength: ReviewsProvider.maxReviewCharacters,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: context.tr('Share your experience...'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: SwitchListTile.adaptive(
                title: const Text(
                  'Post anonymously',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Your name will be hidden from other walkers.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value),
              ),
            ),
            const SizedBox(height: 10),
            _PhotosCard(
              editable: true,
              photos: widget.photos,
              isPicking: widget.isPickingPhotos,
              onAdd: widget.onAddPhotos,
              onRemove: widget.onRemovePhoto,
            ),
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
                onPressed:
                    _rating > 0 &&
                        _controller.text.trim().isNotEmpty &&
                        !widget.isSaving
                    ? () async => widget.onSave(
                        _rating,
                        _controller.text.trim(),
                        _isAnonymous,
                      )
                    : null,
                child: Text(
                  widget.isSaving
                      ? 'Saving...'
                      : widget.title == 'Edit Review'
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

class _DestinationInfo extends StatelessWidget {
  const _DestinationInfo({required this.destination});

  final ReviewDestination destination;

  @override
  Widget build(BuildContext context) {
    final category = destination.category.trim();
    final label = category.isEmpty
        ? _destinationArea(destination.name)
        : '${_destinationArea(destination.name)} · $category';
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 17,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

String _destinationArea(String destinationName) {
  final match = RegExp(r'\(([^)]+)\)').firstMatch(destinationName);
  return match?.group(1)?.trim() ?? destinationName;
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

class _RatingFilterBar extends StatelessWidget {
  const _RatingFilterBar({
    required this.selectedRating,
    required this.onChanged,
  });

  final int? selectedRating;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 34,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final rating = index == 0 ? null : 6 - index;
        final selected = rating == selectedRating;
        return ChoiceChip(
          label: Text(rating == null ? 'All' : '$rating ★'),
          selected: selected,
          onSelected: (_) => onChanged(rating),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        );
      },
    ),
  );
}

class _ReviewPreview extends StatelessWidget {
  const _ReviewPreview({
    required this.review,
    required this.isCurrentUsersReview,
    required this.onTap,
  });
  final PlaceReview review;
  final bool isCurrentUsersReview;
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
                    review.displayAuthorName.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.displayAuthorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (isCurrentUsersReview) ...[
                  const SizedBox(width: 6),
                  const _OwnReviewBadge(),
                ],
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
            if (review.photos.isNotEmpty) ...[
              const SizedBox(height: 10),
              Semantics(
                label: 'Photos attached to this review',
                child: SizedBox(
                  height: 80,
                  child: ListView.separated(
                    key: ValueKey('review-photo-strip-${review.id}'),
                    scrollDirection: Axis.horizontal,
                    itemCount: review.photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => SizedBox(
                      width: 100,
                      child: _PhotoTile(
                        photo: review.photos[index],
                        onPreview: () => _openPhotoPreview(
                          context,
                          review.photos,
                          index,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _ReviewContentCard extends StatelessWidget {
  const _ReviewContentCard({required this.review});
  final PlaceReview review;
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
                  review.displayAuthorName.substring(0, 1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.displayAuthorName,
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
            review.comment,
            style: const TextStyle(fontSize: 12, height: 1.55),
          ),
        ],
      ),
    ),
  );
}

class _OwnReviewBadge extends StatelessWidget {
  const _OwnReviewBadge();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      color: Color(0xFFE3F2E7),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Text(
        'Your review',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _MyReviewCard extends StatelessWidget {
  const _MyReviewCard({
    required this.review,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
  });
  final PlaceReview review;
  final bool canEdit;
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
        if (canEdit) ...[
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
        ] else
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Text(
              'This review can no longer be edited after 30 days.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
      ],
    ),
  );
}

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({
    this.editable = false,
    this.photos = const [],
    this.isPicking = false,
    this.onAdd,
    this.onRemove,
  });

  final bool editable;
  final List<ReviewPhoto> photos;
  final bool isPicking;
  final Future<void> Function()? onAdd;
  final ValueChanged<ReviewPhoto>? onRemove;

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
          if (editable) ...[
            OutlinedButton.icon(
              onPressed: isPicking ? null : onAdd,
              icon: isPicking
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(isPicking ? 'Adding photos...' : 'Add photos'),
            ),
            const SizedBox(height: 6),
            const Text(
              'You can select up to 5 JPEG, PNG, or WebP photos (5 MB each).',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
          if (photos.isEmpty && !editable)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No photos were added to this review.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            )
          else if (photos.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: editable ? 10 : 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: photos
                  .map(
                      (photo) => _PhotoTile(
                        photo: photo,
                        onRemove: editable ? () => onRemove?.call(photo) : null,
                        onPreview: editable
                            ? null
                            : () => _openPhotoPreview(
                                context,
                                photos,
                                photos.indexOf(photo),
                              ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    ),
  );
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, this.onRemove, this.onPreview});

  final ReviewPhoto photo;
  final VoidCallback? onRemove;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final canPreview = onPreview != null;
    return Semantics(
      button: canPreview,
      label: canPreview ? 'Open ${photo.name} in full screen' : photo.name,
      child: InkWell(
        key: ValueKey('review-photo-${photo.id}'),
        onTap: canPreview ? onPreview : null,
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildThumbnail(),
            ),
            if (canPreview)
              const Positioned(
                right: 5,
                bottom: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.zoom_in_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            if (onRemove != null)
              Positioned(
                top: 2,
                right: 2,
                child: IconButton.filledTonal(
                  tooltip: 'Remove ${photo.name}',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 15),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    const fallback = SizedBox(
      height: 80,
      width: 100,
      child: ColoredBox(
        color: Color(0xFFE3EFE7),
        child: Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
    final bytes = photo.bytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        height: 80,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    final signedUrl = photo.signedUrl;
    if (signedUrl != null) {
      return Image.network(
        signedUrl,
        height: 80,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return fallback;
  }
}

void _openPhotoPreview(
  BuildContext context,
  List<ReviewPhoto> photos,
  int initialIndex,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _ReviewPhotoPreviewPage(
        photos: photos,
        initialIndex: initialIndex,
      ),
    ),
  );
}

class _ReviewPhotoPreviewPage extends StatefulWidget {
  const _ReviewPhotoPreviewPage({
    required this.photos,
    required this.initialIndex,
  });

  final List<ReviewPhoto> photos;
  final int initialIndex;

  @override
  State<_ReviewPhotoPreviewPage> createState() =>
      _ReviewPhotoPreviewPageState();
}

class _ReviewPhotoPreviewPageState extends State<_ReviewPhotoPreviewPage> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _currentIndex = widget.initialIndex;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text('${_currentIndex + 1} of ${widget.photos.length}'),
    ),
    body: SafeArea(
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) => Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: _buildPreviewImage(widget.photos[index]),
          ),
        ),
      ),
    ),
  );

  Widget _buildPreviewImage(ReviewPhoto photo) {
    const fallback = SizedBox(
      height: 180,
      width: 240,
      child: ColoredBox(
        color: Color(0xFF28342B),
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white),
        ),
      ),
    );
    final bytes = photo.bytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    final signedUrl = photo.signedUrl;
    if (signedUrl != null) {
      return Image.network(
        signedUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return fallback;
  }
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

String _formatDate(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inDays < 1) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
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
