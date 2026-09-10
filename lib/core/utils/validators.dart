class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final email = value.trim();
    final parts = email.split('@');
    if (email.length > 254 || parts.length != 2) {
      return 'Enter a valid email address.';
    }
    final local = parts[0];
    final labels = parts[1].split('.');
    // Support ordinary unquoted addresses, including plus addressing.
    final localPattern = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+$");
    final domainLabelPattern = RegExp(
      r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$',
    );
    if (local.isEmpty ||
        local.length > 64 ||
        !localPattern.hasMatch(local) ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        local.contains('..') ||
        labels.length < 2 ||
        labels.any((label) => !domainLabelPattern.hasMatch(label)) ||
        !RegExp(r'^[A-Za-z]{2,63}$').hasMatch(labels.last)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) {
      return 'Username is required.';
    }
    if (username.length < 3 || username.length > 20) {
      return 'Username must be 3 to 20 characters.';
    }
    if (!RegExp(r'^[A-Za-z]').hasMatch(username)) {
      return 'Username must start with a letter.';
    }
    if (!RegExp(r'^[A-Za-z][A-Za-z0-9_]*$').hasMatch(username)) {
      return 'Use only letters, numbers, and underscores.';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone number is optional.
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,15}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number.';
    }

    return null;
  }
}
