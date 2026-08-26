import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/features/auth/data/access_context_repository_provider.dart';
import 'package:comunexa/features/auth/data/auth_repository_provider.dart';
import 'package:comunexa/features/auth/data/fake_access_context_repository.dart';
import 'package:comunexa/features/auth/data/fake_access_context_seed.dart';
import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySessionStorage storage;
  late FakeAuthRepository auth;
  late FakeAccessContextRepository access;

  setUp(() {
    storage = InMemorySessionStorage();
    auth = FakeAuthRepository();
    access = FakeAccessContextRepository();
  });

  tearDown(() {
    auth.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        sessionStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(auth),
        accessContextRepositoryProvider.overrideWithValue(access),
      ],
    );
  }

  test('passwordRecovery deja sesión en modo recovery', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(sessionProvider.future);

    auth.simulatePasswordRecovery(
      user: const AuthUser(
        id: 'u-recovery',
        email: 'recovery@test.com',
        displayName: 'Recovery User',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final session = container.read(sessionProvider).value;
    expect(session?.needsPasswordRecovery, isTrue);
    expect(session?.availableContexts, isEmpty);
  });

  test('updatePassword completa recovery y carga contextos', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    auth.simulatePasswordRecovery(
      user: AuthUser(
        id: FakeAccessContextSeed.profileIdForEmail('demo:single@test.com'),
        email: 'demo:single@test.com',
        displayName: 'Carlos Méndez',
      ),
    );
    await container.read(sessionProvider.future);

    final destination =
        await container.read(sessionProvider.notifier).updatePassword(
              'newpassword123',
            );

    expect(destination, PostLoginDestination.home);
    final session = container.read(sessionProvider).value!;
    expect(session.needsPasswordRecovery, isFalse);
    expect(session.hasActiveContext, isTrue);
  });

  test('signedOut remoto limpia sesión en memoria', () async {
    auth.seedSession(
      const AuthUser(
        id: 'u1',
        email: 'user@test.com',
        displayName: 'User',
      ),
    );

    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(sessionProvider.future);
    expect(container.read(sessionProvider).value?.isAuthenticated, isTrue);

    await auth.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(sessionProvider).value, SessionState.empty);
  });

  test('demo:recovery en login devuelve resetPassword', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final destination =
        await container.read(sessionProvider.notifier).signInWithPassword(
              email: 'demo:recovery@test.com',
              password: 'password123',
            );

    expect(destination, PostLoginDestination.resetPassword);
    expect(
      container.read(sessionProvider).value?.needsPasswordRecovery,
      isTrue,
    );
  });
}
