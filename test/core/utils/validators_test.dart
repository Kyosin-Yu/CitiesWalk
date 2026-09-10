import 'package:citieswalk/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    for (final value in [
      'testing123@yahoo.com',
      'walker@gmail.com',
      'first.last+walk@my-domain.com.my',
      ' user_1@OUTLOOK.COM ',
      'walker@example.cm',
    ]) {
      test('accepts $value', () {
        expect(Validators.validateEmail(value), isNull);
      });
    }
    for (final value in [
      r'testing@$.cm',
      'user@foo_bar.com',
      'user@-domain.com',
      'user@domain-.com',
      'user@domain..com',
      'user@domain',
      'user@domain.123',
      'user@@domain.com',
      '.user@domain.com',
      'user.@domain.com',
      'us..er@domain.com',
      'us er@domain.com',
      'user@do main.com',
      '@domain.com',
      'user@',
      '${'a' * 65}@domain.com',
      'user@${'a' * 64}.com',
    ]) {
      test('rejects $value', () {
        expect(Validators.validateEmail(value), 'Enter a valid email address.');
      });
    }
    for (final value in <String?>[null, '', '   ']) {
      test('requires email for "$value"', () {
        expect(Validators.validateEmail(value), 'Email is required.');
      });
    }
  });

  group('registration username', () {
    for (final value in [
      'Abc',
      'walker_123',
      'A1234567890123456789',
      ' Walker_1 ',
    ]) {
      test('accepts "$value"', () {
        expect(Validators.validateUsername(value), isNull);
      });
    }
    for (final value in <String?>[null, '', '   ']) {
      test('requires a username for "$value"', () {
        expect(Validators.validateUsername(value), 'Username is required.');
      });
    }
    for (final value in ['Ab', 'A12345678901234567890']) {
      test('rejects invalid length "$value"', () {
        expect(
          Validators.validateUsername(value),
          'Username must be 3 to 20 characters.',
        );
      });
    }
    for (final value in ['1walker', '_walker']) {
      test('rejects non-letter start "$value"', () {
        expect(
          Validators.validateUsername(value),
          'Username must start with a letter.',
        );
      });
    }
    for (final value in [
      'John Doe',
      'walker-name',
      'walker.name',
      'walk@123',
      'Abé',
      'Ab\ncd',
    ]) {
      test('rejects unsupported characters "$value"', () {
        expect(
          Validators.validateUsername(value),
          'Use only letters, numbers, and underscores.',
        );
      });
    }
  });
}
