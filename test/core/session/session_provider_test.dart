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

  test('signInWithPassword con un contexto persiste sesión activa', () async {
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

    final snapshot = await storage.read();
    expect(snapshot?.activeContextId, 'ctx-torres-resident');
  });

  test('signInWithPassword multirrol deja sesión pendiente', () async {
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

    final snapshot = await storage.read();
    expect(snapshot?.email, 'demo:multi@test.com');
    expect(snapshot?.activeContextId, isNull);
    expect(snapshot?.lastUsedContextId, 'ctx-torres-resident');
  });

  test('selectContext persiste propiedad activa y último uso', () async {
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

    final snapshot = await storage.read();
    expect(snapshot?.activeContextId, 'ctx-atalia-admin');
    expect(snapshot?.lastUsedContextId, 'ctx-atalia-admin');
  });

  test('restore tras reinicio mantiene sesión activa', () async {
    await storage.write(
      const SessionSnapshot(
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
        activeContextId: 'ctx-serena-reception',
        lastUsedContextId: 'ctx-serena-reception',
      ),
    );
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

  test('restore multirrol sin activo pide selector', () async {
    await storage.write(
      const SessionSnapshot(
        email: 'demo:multi@test.com',
        displayName: 'Carlos Méndez',
        lastUsedContextId: 'ctx-omega-cowner',
      ),
    );
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
      'ctx-omega-cowner',
    );
  });

  test('signOut limpia almacenamiento y Auth', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).signInWithPassword(
          email: 'demo:single@test.com',
          password: 'password123',
        );
    await container.read(sessionProvider.notifier).signOut();

    expect(container.read(sessionProvider).value, SessionState.empty);
    expect(await storage.read(), isNull);
    expect(auth.currentUser, isNull);
  });

  test('sendPasswordResetEmail delega al repositorio', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container
        .read(sessionProvider.notifier)
        .sendPasswordResetEmail('user@test.com');
  });
}
