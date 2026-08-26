import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signInWithPassword acepta cualquier password por defecto', () async {
    final auth = FakeAuthRepository();
    final user = await auth.signInWithPassword(
      email: 'demo:single@test.com',
      password: 'any',
    );
    expect(user.email, 'demo:single@test.com');
    expect(auth.currentUser?.email, 'demo:single@test.com');
  });

  test('signInWithPassword rechaza password inválida si no acceptAny', () async {
    final auth = FakeAuthRepository(acceptAnyPassword: false);
    expect(
      () => auth.signInWithPassword(
        email: 'a@b.com',
        password: 'wrong',
      ),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.kind,
          'kind',
          AuthFailureKind.invalidCredentials,
        ),
      ),
    );
  });

  test('nextSignInFailure simula red', () async {
    final auth = FakeAuthRepository()
      ..nextSignInFailure = AuthFailureKind.network;
    expect(
      () => auth.signInWithPassword(email: 'a@b.com', password: 'x'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.kind,
          'kind',
          AuthFailureKind.network,
        ),
      ),
    );
  });

  test('sendPasswordResetEmail y signOut', () async {
    final auth = FakeAuthRepository();
    await auth.signInWithPassword(email: 'a@b.com', password: 'x');
    await auth.sendPasswordResetEmail('a@b.com');
    await auth.signOut();
    expect(auth.currentUser, isNull);
  });
}
