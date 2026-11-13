import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email accepts valid and rejects invalid addresses', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@tld'), isNotNull);
    });

    test('fullName needs at least 3 characters', () {
      expect(Validators.fullName('Jo'), isNotNull);
      expect(Validators.fullName('Joe'), isNull);
      expect(Validators.fullName('   '), isNotNull);
    });

    test('newPassword needs length, a letter and a number', () {
      expect(Validators.newPassword('abc'), isNotNull);
      expect(Validators.newPassword('abcdef'), isNotNull);
      expect(Validators.newPassword('123456'), isNotNull);
      expect(Validators.newPassword('abc123'), isNull);
    });

    test('confirmPassword must match the original', () {
      final original = TextEditingController(text: 'abc123');
      final validator = Validators.confirmPassword(original);
      expect(validator('abc123'), isNull);
      expect(validator('different'), isNotNull);
      expect(validator(''), isNotNull);
      original.dispose();
    });

    test('optionalPhone allows empty or exactly 10 digits', () {
      expect(Validators.optionalPhone(''), isNull);
      expect(Validators.optionalPhone('9876543210'), isNull);
      expect(Validators.optionalPhone('12345'), isNotNull);
    });
  });
}
