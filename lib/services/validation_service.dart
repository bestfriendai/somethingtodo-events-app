class ValidationService {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

  static final RegExp _urlRegex = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  );

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value != null && value.isNotEmpty && !_urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    if (value.isBefore(DateTime.now())) {
      return 'Date cannot be in the past';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Min length validation
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  // Max length validation
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  // Number range validation
  static String? validateRange(num? value, num min, num max, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    if (value < min || value > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }
}
