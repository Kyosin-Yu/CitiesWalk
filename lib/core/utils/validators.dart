class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
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
