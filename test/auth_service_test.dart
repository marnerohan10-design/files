import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopease/services/auth_service.dart';
import 'package:shopease/services/storage_service.dart';

void main() {
  late StorageService storage;
  late AuthService auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await StorageService.create();
    auth = AuthService(storage);
  });

  test('register then login works and the password is not stored in plain text', () async {
    await auth.register(name: 'Test User', email: 'Test@Example.com', password: 'secret123');

    expect(storage.readUsers().toString().contains('secret123'), isFalse);

    final user = await auth.login(
      email: 'test@example.com',
      password: 'secret123',
      remember: true,
    );
    expect(user.name, 'Test User');
    expect(auth.restoreSession()?.email, 'test@example.com');
  });

  test('wrong password and unknown email are rejected', () async {
    await auth.register(name: 'Test User', email: 'a@b.com', password: 'secret123');

    expect(
      () => auth.login(email: 'a@b.com', password: 'wrong', remember: true),
      throwsA(isA<AuthException>()),
    );
    expect(
      () => auth.login(email: 'nobody@b.com', password: 'secret123', remember: true),
      throwsA(isA<AuthException>()),
    );
  });

  test('duplicate email cannot register twice', () async {
    await auth.register(name: 'One', email: 'a@b.com', password: 'secret123');
    expect(
      () => auth.register(name: 'Two', email: 'A@B.com', password: 'secret456'),
      throwsA(isA<AuthException>()),
    );
  });

  test('session is cleared on logout and ignored when remember is off', () async {
    await auth.register(name: 'Test User', email: 'a@b.com', password: 'secret123');

    await auth.login(email: 'a@b.com', password: 'secret123', remember: true);
    await auth.logout();
    expect(auth.restoreSession(), isNull);

    await auth.login(email: 'a@b.com', password: 'secret123', remember: false);
    expect(auth.restoreSession(), isNull);
  });
}
