class Validators {
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    if (value.trim().length < 9) return 'Enter a valid phone number';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Value']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final n = num.tryParse(value.trim());
    if (n == null) return '$field must be a number';
    if (n < 0) return '$field must be positive';
    return null;
  }

  static String? minLength(String? value, int min, [String field = 'Field']) {
    if (value == null || value.length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }
}
