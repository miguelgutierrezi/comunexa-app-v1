import 'package:comunexa/core/config/env.dart';
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

  setUpAll(() async {
    await Env.load();
  });

  setUp(() {
    storage = InMemorySessionStorage();
    auth = FakeAuthRepository();
    access = FakeAccessContextRepository();
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
    access.seedProfile('test-multi', FakeAccessContextSeed.multiple);
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
    access.seedProfile('test-multi', FakeAccessContextSeed.multiple);
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

  test('signInWithPassword sin membresías devuelve noAccess', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final destination =
        await container.read(sessionProvider.notifier).signInWithPassword(
              email: 'demo:noaccess@test.com',
              password: 'password123',
            );

    expect(destination, PostLoginDestination.noAccess);
    final session = container.read(sessionProvider).value!;
    expect(session.authenticatedWithoutAccess, isTrue);
    expect(session.activeContext, isNull);
  });

  test('authenticated sin membresías queda sin acceso', () async {
    access.seedProfile('no-access', const []);
    auth.seedSession(
      const AuthUser(
        id: 'no-access',
        email: 'user@test.com',
        displayName: 'Usuario',
      ),
    );

    final container = createContainer();
    addTearDown(container.dispose);

    final session = await container.read(sessionProvider.future);
    expect(session.authenticatedWithoutAccess, isTrue);
    expect(session.hasActiveContext, isFalse);
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

  test('sin full_name no inventa nombre ficticio', () async {
    access.seedProfile('no-name', [FakeAccessContextSeed.single]);
    auth.seedSession(
      const AuthUser(
        id: 'no-name',
        email: 'e2e-noname@comunexa.local',
      ),
    );

    final container = createContainer();
    addTearDown(container.dispose);

    final session = await container.read(sessionProvider.future);
    expect(session.displayName, isNull);
    expect(session.hasActiveContext, isTrue);
  });

  test('sendPasswordResetEmail delega al repositorio', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container
        .read(sessionProvider.notifier)
        .sendPasswordResetEmail('user@test.com');
  });
}
