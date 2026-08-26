import 'package:comunexa/core/config/env.dart';
import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/core/session/session_storage.dart';
import 'package:comunexa/features/auth/data/auth_repository_provider.dart';
import 'package:comunexa/features/auth/data/fake_auth_repository.dart';
import 'package:comunexa/features/auth/domain/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySessionStorage storage;
  late FakeAuthRepository auth;

  setUpAll(() async {
    await Env.load();
  });

  setUp(() {
    storage = InMemorySessionStorage();
    auth = FakeAuthRepository();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        sessionStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
  }

  test('signInWithPassword con un contexto persiste solo contextId', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final destination =
        await container.read(sessionProvider.notifier).signInWithPassword(
              email: 'demo:single@test.com',
              password: 'password123',
            );

    expect(destination, PostLoginDestination.home);
    final session = container.read(sessionProvider).value!;
    expect(session.email, 'demo:single@test.com');
    expect(session.activeContext?.propertyName, 'Torres del Parque');
    expect(await storage.readLastContextId(), 'ctx-torres-resident');
  });

  test('signInWithPassword multirrol sin preferencia pide selector', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final destination =
        await container.read(sessionProvider.notifier).signInWithPassword(
              email: 'demo:multi@test.com',
              password: 'password123',
            );

    expect(destination, PostLoginDestination.contextSelect);
    final session = container.read(sessionProvider).value!;
    expect(session.needsContextSelection, isTrue);
    expect(session.activeContext, isNull);
    // No se escribe contextId hasta que el usuario elige.
    expect(await storage.readLastContextId(), isNull);
  });

  test('selectContext persiste únicamente el contextId', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).signInWithPassword(
          email: 'demo:multi@test.com',
          password: 'password123',
        );
    await container
        .read(sessionProvider.notifier)
        .selectContext('ctx-atalia-admin');

    final session = container.read(sessionProvider).value!;
    expect(session.activeContext?.propertyName, 'Conjunto Residencial Atalia');
    expect(session.lastUsedContextId, 'ctx-atalia-admin');
    expect(await storage.readLastContextId(), 'ctx-atalia-admin');
  });

  test('restore con lastContextId válido entra con contexto activo', () async {
    await storage.writeLastContextId('ctx-serena-reception');
    auth.seedSession(
      const AuthUser(
        id: 'test-multi',
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    final container = createContainer();
    addTearDown(container.dispose);

    final session = await container.read(sessionProvider.future);
    expect(session.hasActiveContext, isTrue);
    expect(session.activeContext?.propertyName, 'Hotel Boutique Serena');
    expect(session.needsContextSelection, isFalse);
  });

  test('restore multirrol sin lastContextId pide selector', () async {
    auth.seedSession(
      const AuthUser(
        id: 'test-multi',
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
      ),
    );

    final container = createContainer();
    addTearDown(container.dispose);

    final session = await container.read(sessionProvider.future);
    expect(session.needsContextSelection, isTrue);
    expect(
      session.availableContexts.firstWhere((c) => c.isLastUsed).id,
      'ctx-torres-resident',
    );
  });

  test('signOut limpia Auth pero no usa storage como autoridad', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).signInWithPassword(
          email: 'demo:single@test.com',
          password: 'password123',
        );
    expect(await storage.readLastContextId(), 'ctx-torres-resident');

    await container.read(sessionProvider.notifier).signOut();

    expect(container.read(sessionProvider).value, SessionState.empty);
    expect(auth.currentUser, isNull);
    // Hint UX puede permanecer; la sesión en memoria queda vacía.
    expect(await storage.readLastContextId(), 'ctx-torres-resident');
  });

  test('sendPasswordResetEmail delega al repositorio', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container
        .read(sessionProvider.notifier)
        .sendPasswordResetEmail('user@test.com');
  });
}
