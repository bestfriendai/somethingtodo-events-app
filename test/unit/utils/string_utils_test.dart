import 'package:flutter_test/flutter_test.dart';
import 'package:somethingtodo/core/utils/string_utils.dart';

void main() {
  group('StringUtils', () {
    group('isNullOrEmpty', () {
      test('should return true for null', () {
        expect(StringUtils.isNullOrEmpty(null), isTrue);
      });

      test('should return true for empty string', () {
        expect(StringUtils.isNullOrEmpty(''), isTrue);
      });

      test('should return true for whitespace only string', () {
        expect(StringUtils.isNullOrEmpty('   '), isTrue);
      });

      test('should return false for non-empty string', () {
        expect(StringUtils.isNullOrEmpty('hello'), isFalse);
      });
    });

    group('isValidEmail', () {
      test('should return true for valid email', () {
        expect(StringUtils.isValidEmail('test@example.com'), isTrue);
        expect(StringUtils.isValidEmail('user.name@company.co.uk'), isTrue);
        expect(StringUtils.isValidEmail('first+last@domain.org'), isTrue);
      });

      test('should return false for invalid email', () {
        expect(StringUtils.isValidEmail(''), isFalse);
        expect(StringUtils.isValidEmail('not-an-email'), isFalse);
        expect(StringUtils.isValidEmail('@example.com'), isFalse);
        expect(StringUtils.isValidEmail('test@'), isFalse);
        expect(StringUtils.isValidEmail('test@.com'), isFalse);
      });
    });

    group('isValidPhone', () {
      test('should return true for valid phone numbers', () {
        expect(StringUtils.isValidPhone('+1234567890'), isTrue);
        expect(StringUtils.isValidPhone('123-456-7890'), isTrue);
        expect(StringUtils.isValidPhone('(123) 456-7890'), isTrue);
        expect(StringUtils.isValidPhone('123 456 7890'), isTrue);
      });

      test('should return false for invalid phone numbers', () {
        expect(StringUtils.isValidPhone(''), isFalse);
        expect(StringUtils.isValidPhone('abc'), isFalse);
        expect(StringUtils.isValidPhone('123'), isFalse); // too short
      });
    });

    group('capitalize', () {
      test('should capitalize first letter', () {
        expect(StringUtils.capitalize('hello'), equals('Hello'));
        expect(StringUtils.capitalize('WORLD'), equals('World'));
        expect(StringUtils.capitalize('flutter app'), equals('Flutter app'));
      });

      test('should handle edge cases', () {
        expect(StringUtils.capitalize(''), equals(''));
        expect(StringUtils.capitalize('a'), equals('A'));
        expect(StringUtils.capitalize('123'), equals('123'));
      });
    });

    group('capitalizeWords', () {
      test('should capitalize each word', () {
        expect(StringUtils.capitalizeWords('hello world'), equals('Hello World'));
        expect(StringUtils.capitalizeWords('the quick brown fox'), equals('The Quick Brown Fox'));
      });

      test('should handle edge cases', () {
        expect(StringUtils.capitalizeWords(''), equals(''));
        expect(StringUtils.capitalizeWords('single'), equals('Single'));
        expect(StringUtils.capitalizeWords('  spaced  words  '), equals('Spaced Words'));
      });
    });

    group('toSlug', () {
      test('should convert to slug format', () {
        expect(StringUtils.toSlug('Hello World'), equals('hello-world'));
        expect(StringUtils.toSlug('Test  Multiple   Spaces'), equals('test-multiple-spaces'));
        expect(StringUtils.toSlug('Special!@#Characters'), equals('special-characters'));
      });

      test('should handle edge cases', () {
        expect(StringUtils.toSlug(''), equals(''));
        expect(StringUtils.toSlug('already-slug'), equals('already-slug'));
        expect(StringUtils.toSlug('123 456'), equals('123-456'));
      });
    });

    group('truncate', () {
      test('should truncate long strings', () {
        expect(StringUtils.truncate('Hello World', 5), equals('Hello...'));
        expect(StringUtils.truncate('Short', 10), equals('Short'));
      });

      test('should use custom suffix', () {
        expect(StringUtils.truncate('Hello World', 5, suffix: '…'), equals('Hello…'));
        expect(StringUtils.truncate('Hello World', 5, suffix: ''), equals('Hello'));
      });

      test('should handle edge cases', () {
        expect(StringUtils.truncate('', 5), equals(''));
        expect(StringUtils.truncate('Hi', 2), equals('Hi'));
      });
    });

    group('removeWhitespace', () {
      test('should remove all whitespace', () {
        expect(StringUtils.removeWhitespace('hello world'), equals('helloworld'));
        expect(StringUtils.removeWhitespace('  spaced  text  '), equals('spacedtext'));
        expect(StringUtils.removeWhitespace('tab\there'), equals('tabhere'));
        expect(StringUtils.removeWhitespace('new\nline'), equals('newline'));
      });
    });

    group('formatPhoneNumber', () {
      test('should format 10 digit phone number', () {
        expect(StringUtils.formatPhoneNumber('1234567890'), equals('(123) 456-7890'));
        expect(StringUtils.formatPhoneNumber('123 456 7890'), equals('(123) 456-7890'));
      });

      test('should return original if not 10 digits', () {
        expect(StringUtils.formatPhoneNumber('12345'), equals('12345'));
        expect(StringUtils.formatPhoneNumber('12345678901'), equals('12345678901'));
      });
    });

    group('getInitials', () {
      test('should get initials from name', () {
        expect(StringUtils.getInitials('John Doe'), equals('JD'));
        expect(StringUtils.getInitials('Jane Smith Johnson'), equals('JJ'));
        expect(StringUtils.getInitials('Alice'), equals('A'));
      });

      test('should handle edge cases', () {
        expect(StringUtils.getInitials(''), equals(''));
        expect(StringUtils.getInitials(' '), equals(''));
      });
    });

    group('stripHtml', () {
      test('should remove HTML tags', () {
        expect(StringUtils.stripHtml('<p>Hello World</p>'), equals('Hello World'));
        expect(StringUtils.stripHtml('<div><b>Test</b></div>'), equals('Test'));
        expect(StringUtils.stripHtml('No tags here'), equals('No tags here'));
      });
    });
  });
}
