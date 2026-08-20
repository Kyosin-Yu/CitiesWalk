import '../../business_logic/entities/place_review.dart';
import '../../business_logic/entities/review_destination.dart';

const reviewDestinations = <ReviewDestination>[
  ReviewDestination(
    id: 'petaling-street',
    name: 'Petaling Street (Chinatown)',
    category: 'Heritage walk',
  ),
  ReviewDestination(
    id: 'petronas-towers',
    name: 'Petronas Twin Towers',
    category: 'City attraction',
  ),
  ReviewDestination(
    id: 'central-market',
    name: 'Central Market',
    category: 'Cultural market',
  ),
];

final initialReviewsByDestination = <String, List<PlaceReview>>{
  'petaling-street': [
    PlaceReview(
      id: 'review-1',
      userId: 'seed-sarah',
      authorName: 'Sarah Lim',
      rating: 5,
      comment:
          'Absolutely electric atmosphere after sundown. The vendors start setting up around 5 PM and by 7 it is a full sensory experience.',
      createdAt: DateTime(2024, 7, 20),
    ),
    PlaceReview(
      id: 'review-2',
      userId: 'seed-jason',
      authorName: 'Jason Tan',
      rating: 4,
      comment: 'Come hungry and take your time exploring the food stalls.',
      createdAt: DateTime(2024, 7, 18),
    ),
    PlaceReview(
      id: 'review-3',
      userId: 'seed-nur',
      authorName: 'Nur Aina',
      rating: 4,
      comment: 'A lively place for local snacks, souvenirs, and evening walks.',
      createdAt: DateTime(2024, 7, 16),
    ),
  ],
  'petronas-towers': [
    PlaceReview(
      id: 'review-4',
      userId: 'seed-ravi',
      authorName: 'Ravi',
      rating: 5,
      comment:
          'Great city views and the station is within easy walking distance.',
      createdAt: DateTime(2026, 7, 26),
    ),
    PlaceReview(
      id: 'review-5',
      userId: 'seed-sofia',
      authorName: 'Sofia',
      rating: 4,
      comment: 'Book your visit early and enjoy the park around the towers.',
      createdAt: DateTime(2026, 7, 21),
    ),
  ],
  'central-market': [
    PlaceReview(
      id: 'review-6',
      userId: 'seed-hana',
      authorName: 'Hana',
      rating: 4,
      comment: 'A convenient stop for local crafts, snacks, and souvenirs.',
      createdAt: DateTime(2026, 7, 22),
    ),
  ],
};
