import 'package:flutter_test/flutter_test.dart';
import 'package:somethingtodo/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(ValidationUtils.validateEmail('test@example.com'), isNull);
        expect(ValidationUtils.validateEmail('user.name+tag@company.co.uk'), isNull);
      });

      test('should return error for invalid email', () {
        expect(ValidationUtils.validateEmail(null), equals('Email is required'));
        expect(ValidationUtils.validateEmail(''), equals('Email is required'));
        expect(ValidationUtils.validateEmail('   '), equals('Email is required'));
        expect(ValidationUtils.validateEmail('invalid'), equals('Please enter a valid email address'));
        expect(ValidationUtils.validateEmail('@example.com'), equals('Please enter a valid email address'));
        expect(ValidationUtils.validateEmail('test@'), equals('Please enter a valid email address'));
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(ValidationUtils.validatePassword('password123'), isNull);
        expect(ValidationUtils.validatePassword('MySecureP@ssw0rd'), isNull);
      });

      test('should return error for invalid password', () {
        expect(ValidationUtils.validatePassword(null), equals('Password is required'));
        expect(ValidationUtils.validatePassword(''), equals('Password is required'));
        expect(ValidationUtils.validatePassword('12345'), contains('at least'));
        expect(ValidationUtils.validatePassword('a' * 130), contains('less than'));
      });
    });

    group('validateConfirmPassword', () {
      test('should return null when passwords match', () {
        expect(ValidationUtils.validateConfirmPassword('password123', 'password123'), isNull);
      });

      test('should return error when passwords don\'t match', () {
        expect(ValidationUtils.validateConfirmPassword(null, 'password'), equals('Please confirm your password'));
        expect(ValidationUtils.validateConfirmPassword('', 'password'), equals('Please confirm your password'));
        expect(ValidationUtils.validateConfirmPassword('password1', 'password2'), equals('Passwords do not match'));
      });
    });

    group('validateName', () {
      test('should return null for valid name', () {
        expect(ValidationUtils.validateName('John'), isNull);
        expect(ValidationUtils.validateName('John Doe'), isNull);
        expect(ValidationUtils.validateName('Jean-Claude Van Damme'), isNull);
      });

      test('should return error for invalid name', () {
        expect(ValidationUtils.validateName(null), equals('Name is required'));
        expect(ValidationUtils.validateName(''), equals('Name is required'));
        expect(ValidationUtils.validateName('J'), contains('at least'));
        expect(ValidationUtils.validateName('a' * 52), contains('less than'));
      });
    });

    group('validatePhone', () {
      test('should return null for valid phone', () {
        expect(ValidationUtils.validatePhone('+1234567890'), isNull);
        expect(ValidationUtils.validatePhone('123-456-7890'), isNull);
        expect(ValidationUtils.validatePhone('(123) 456-7890'), isNull);
      });

      test('should return error for invalid phone', () {
        expect(ValidationUtils.validatePhone(null), equals('Phone number is required'));
        expect(ValidationUtils.validatePhone(''), equals('Phone number is required'));
        expect(ValidationUtils.validatePhone('abc'), equals('Please enter a valid phone number'));
        expect(ValidationUtils.validatePhone('123'), equals('Please enter a valid phone number'));
      });
    });

    group('validateRequired', () {
      test('should return null for non-empty value', () {
        expect(ValidationUtils.validateRequired('value'), isNull);
        expect(ValidationUtils.validateRequired('  value  '), isNull);
      });

      test('should return error for empty value', () {
        expect(ValidationUtils.validateRequired(null), equals('Field is required'));
        expect(ValidationUtils.validateRequired(''), equals('Field is required'));
        expect(ValidationUtils.validateRequired('   '), equals('Field is required'));
        expect(ValidationUtils.validateRequired(null, fieldName: 'Username'), equals('Username is required'));
      });
    });

    group('validateMinLength', () {
      test('should return null for valid length', () {
        expect(ValidationUtils.validateMinLength('hello', 5), isNull);
        expect(ValidationUtils.validateMinLength('hello world', 5), isNull);
      });

      test('should return error for invalid length', () {
        expect(ValidationUtils.validateMinLength(null, 5), equals('Field is required'));
        expect(ValidationUtils.validateMinLength('', 5), equals('Field is required'));
        expect(ValidationUtils.validateMinLength('hi', 5), contains('at least 5 characters'));
        expect(ValidationUtils.validateMinLength('hi', 5, fieldName: 'Message'), 
               contains('Message must be at least 5 characters'));
      });
    });

    group('validateMaxLength', () {
      test('should return null for valid length', () {
        expect(ValidationUtils.validateMaxLength('hello', 10), isNull);
        expect(ValidationUtils.validateMaxLength('hi', 10), isNull);
        expect(ValidationUtils.validateMaxLength(null, 10), isNull);
      });

      test('should return error for invalid length', () {
        expect(ValidationUtils.validateMaxLength('hello world', 5), contains('less than 5 characters'));
        expect(ValidationUtils.validateMaxLength('hello world', 5, fieldName: 'Title'), 
               contains('Title must be less than 5 characters'));
      });
    });

    group('validateNumeric', () {
      test('should return null for numeric value', () {
        expect(ValidationUtils.validateNumeric('123'), isNull);
        expect(ValidationUtils.validateNumeric('123.45'), isNull);
        expect(ValidationUtils.validateNumeric('-123'), isNull);
      });

      test('should return error for non-numeric value', () {
        expect(ValidationUtils.validateNumeric(null), equals('Value is required'));
        expect(ValidationUtils.validateNumeric(''), equals('Value is required'));
        expect(ValidationUtils.validateNumeric('abc'), equals('Value must be a valid number'));
        expect(ValidationUtils.validateNumeric('12.34.56'), equals('Value must be a valid number'));
        expect(ValidationUtils.validateNumeric('abc', fieldName: 'Price'), 
               equals('Price must be a valid number'));
      });
    });

    group('validateInteger', () {
      test('should return null for integer value', () {
        expect(ValidationUtils.validateInteger('123'), isNull);
        expect(ValidationUtils.validateInteger('-456'), isNull);
        expect(ValidationUtils.validateInteger('0'), isNull);
      });

      test('should return error for non-integer value', () {
        expect(ValidationUtils.validateInteger(null), equals('Value is required'));
        expect(ValidationUtils.validateInteger(''), equals('Value is required'));
        expect(ValidationUtils.validateInteger('123.45'), equals('Value must be a whole number'));
        expect(ValidationUtils.validateInteger('abc'), equals('Value must be a whole number'));
        expect(ValidationUtils.validateInteger('12.5', fieldName: 'Quantity'), 
               equals('Quantity must be a whole number'));
      });
    });

    group('validateUrl', () {
      test('should return null for valid URL', () {
        expect(ValidationUtils.validateUrl('http://example.com'), isNull);
        expect(ValidationUtils.validateUrl('https://www.example.com'), isNull);
        expect(ValidationUtils.validateUrl('https://subdomain.example.co.uk'), isNull);
        expect(ValidationUtils.validateUrl('http://example.com:8080'), isNull);
        expect(ValidationUtils.validateUrl('https://example.com/path/to/page'), isNull);
      });

      test('should return error for invalid URL', () {
        expect(ValidationUtils.validateUrl(null), equals('URL is required'));
        expect(ValidationUtils.validateUrl(''), equals('URL is required'));
        expect(ValidationUtils.validateUrl('not a url'), equals('Please enter a valid URL'));
        expect(ValidationUtils.validateUrl('example'), equals('Please enter a valid URL'));
        expect(ValidationUtils.validateUrl('ftp://example.com'), equals('Please enter a valid URL'));
      });
    });

    group('validateDate', () {
      test('should return null for valid date', () {
        expect(ValidationUtils.validateDate(DateTime.now()), isNull);
        expect(ValidationUtils.validateDate(DateTime(2024, 1, 1)), isNull);
      });

      test('should return error for null date', () {
        expect(ValidationUtils.validateDate(null), equals('Date is required'));
        expect(ValidationUtils.validateDate(null, fieldName: 'Birthday'), equals('Birthday is required'));
      });
    });

    group('validateFutureDate', () {
      test('should return null for future date', () {
        final tomorrow = DateTime.now().add(Duration(days: 1));
        expect(ValidationUtils.validateFutureDate(tomorrow), isNull);
        
        final nextYear = DateTime.now().add(Duration(days: 365));
        expect(ValidationUtils.validateFutureDate(nextYear), isNull);
      });

      test('should return error for past date', () {
        expect(ValidationUtils.validateFutureDate(null), equals('Date is required'));
        
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        expect(ValidationUtils.validateFutureDate(yesterday), equals('Date must be in the future'));
        
        expect(ValidationUtils.validateFutureDate(yesterday, fieldName: 'Event date'), 
               equals('Event date must be in the future'));
      });
    });

    group('validatePastDate', () {
      test('should return null for past date', () {
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        expect(ValidationUtils.validatePastDate(yesterday), isNull);
        
        final lastYear = DateTime.now().subtract(Duration(days: 365));
        expect(ValidationUtils.validatePastDate(lastYear), isNull);
      });

      test('should return error for future date', () {
        expect(ValidationUtils.validatePastDate(null), equals('Date is required'));
        
        final tomorrow = DateTime.now().add(Duration(days: 1));
        expect(ValidationUtils.validatePastDate(tomorrow), equals('Date must be in the past'));
        
        expect(ValidationUtils.validatePastDate(tomorrow, fieldName: 'Birth date'), 
               equals('Birth date must be in the past'));
      });
    });

    group('validateAge', () {
      test('should return null for valid age', () {
        final twentyYearsOld = DateTime.now().subtract(Duration(days: 20 * 365));
        expect(ValidationUtils.validateAge(twentyYearsOld), isNull);
        
        final eighteenYearsOld = DateTime.now().subtract(Duration(days: 18 * 365 + 5));
        expect(ValidationUtils.validateAge(eighteenYearsOld), isNull);
      });

      test('should return error for underage', () {
        expect(ValidationUtils.validateAge(null), equals('Birth date is required'));
        
        final seventeenYearsOld = DateTime.now().subtract(Duration(days: 17 * 365));
        expect(ValidationUtils.validateAge(seventeenYearsOld), equals('You must be at least 18 years old'));
        
        final tenYearsOld = DateTime.now().subtract(Duration(days: 10 * 365));
        expect(ValidationUtils.validateAge(tenYearsOld, minAge: 13), 
               equals('You must be at least 13 years old'));
      });
    });
  });
}
