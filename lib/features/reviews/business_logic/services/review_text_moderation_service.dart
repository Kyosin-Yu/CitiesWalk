/// Applies the review module's client-side text policy before submission.
///
/// This is a usability guard only. Server-side checks must still be added if
/// the product later needs enforcement against modified or older app clients.
class ReviewTextModerationService {
  const ReviewTextModerationService();

  static final List<RegExp> _blockedPatterns = <RegExp>[
    RegExp(
      r'\b(?:asshole|bitch|bullshit|fuck|motherfucker|shit)\b',
      caseSensitive: false,
    ),
    RegExp(r'https?://|www\.', caseSensitive: false),
    RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b'),
    RegExp(r'\b(?:whatsapp|telegram)\b', caseSensitive: false),
    RegExp(
      r'\b(?:guaranteed\s+(?:profit|return)|crypto\s+giveaway|dm\s+me\s+for)\b',
      caseSensitive: false,
    ),
  ];

  /// Returns a user-facing message when [comment] violates the content policy.
  String? validate(String comment) {
    final trimmed = comment.trim();
    if (_blockedPatterns[0].hasMatch(trimmed)) {
      return 'Please remove offensive language from your review.';
    }
    if (_blockedPatterns[1].hasMatch(trimmed) ||
        _blockedPatterns[2].hasMatch(trimmed) ||
        _blockedPatterns[3].hasMatch(trimmed) ||
        _blockedPatterns[4].hasMatch(trimmed)) {
      return 'Reviews cannot include links, contact details, or promotional content.';
    }
    return null;
  }
}
