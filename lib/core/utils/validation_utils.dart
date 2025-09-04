import '../constants/app_constants.dart';
import 'string_utils.dart';

/// Validation utility functions
class ValidationUtils {
  ValidationUtils._();

  /// Validate email address
  static String? validateEmail(String? value) {
    if (StringUtils.isNullOrEmpty(value)) {
      return 'Email is required';
    }
    if (!StringUtils.isValidEmail(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (StringUtils.isNullOrEmpty(value)) {
      return 'Password is required';
    }
    if (value!.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must be less than ${AppConstants.maxPasswordLength} characters';
    }
    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (StringUtils.isNullOrEmpty(value)) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (StringUtils.isNullOrEmpty(value)) {
      return 'Name is required';
    }
    if (value!.trim().length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return 'Name must be less than ${AppConstants.maxNameLength} characters';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (StringUtils.isNullOrEmpty(value)) {
      return 'Phone number is required';
    }
    if (!StringUtils.isValidPhone(value!)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (StringUtils.isNullOrEmpty(value)) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'Field',
  }) {
    if (StringUtils.isNullOrEmpty(value)) {
      return '$fieldName is required';
    }
    if (value!.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Field',
  }) {
    if (!StringUtils.isNullOrEmpty(value) && value!.trim().length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  /// Validate numeric value
  static String? validateNumeric(String? value, {String fieldName = 'Value'}) {
    if (StringUtils.isNullOrEmpty(value)) {
      return '$fieldName is required';
    }
    if (double.tryParse(value!) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  /// Validate integer value
  static String? validateInteger(String? value, {String fieldName = 'Value'}) {
    if (StringUtils.isNullOrEmpty(value)) {
      return '$fieldName is required';
    }
    if (int.tryParse(value!) == null) {
      return '$fieldName must be a whole number';
    }
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (StringUtils.isNullOrEmpty(value)) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value!)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validate date
  static String? validateDate(DateTime? date, {String fieldName = 'Date'}) {
    if (date == null) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate future date
  static String? validateFutureDate(
    DateTime? date, {
    String fieldName = 'Date',
  }) {
    if (date == null) {
      return '$fieldName is required';
    }
    if (date.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }
    return null;
  }

  /// Validate past date
  static String? validatePastDate(DateTime? date, {String fieldName = 'Date'}) {
    if (date == null) {
      return '$fieldName is required';
    }
    if (date.isAfter(DateTime.now())) {
      return '$fieldName must be in the past';
    }
    return null;
  }

  /// Validate age
  static String? validateAge(DateTime? birthDate, {int minAge = 18}) {
    if (birthDate == null) {
      return 'Birth date is required';
    }

    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    return null;
  }
}
