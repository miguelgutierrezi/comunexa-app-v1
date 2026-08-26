import 'package:comunexa/features/auth/data/fake_access_context_seed.dart';
import 'package:comunexa/features/auth/domain/access_context.dart';
import 'package:comunexa/features/auth/domain/access_context_repository.dart';

/// Membresías en memoria para tests (paridad con seeds demo / Figma).
class FakeAccessContextRepository implements AccessContextRepository {
  FakeAccessContextRepository({
    Map<String, List<AccessContext>>? contextsByProfileId,
    this.resolveForProfile,
  }) : _contextsByProfileId = contextsByProfileId != null
            ? Map<String, List<AccessContext>>.from(contextsByProfileId)
            : {};

  final Map<String, List<AccessContext>> _contextsByProfileId;
  final List<AccessContext> Function(String profileId)? resolveForProfile;

  void seedProfile(String profileId, List<AccessContext> contexts) {
    _contextsByProfileId[profileId] = List<AccessContext>.from(contexts);
  }

  List<AccessContext> _contextsFor(String profileId) {
    final seeded = _contextsByProfileId[profileId];
    if (seeded != null) return List<AccessContext>.from(seeded);
    if (resolveForProfile != null) {
      return List<AccessContext>.from(resolveForProfile!(profileId));
    }
    return FakeAccessContextSeed.contextsForProfileId(profileId);
  }

  @override
  Future<List<AccessContext>> getAvailableContexts(String profileId) async {
    return _contextsFor(profileId);
  }

  @override
  Future<AccessContext?> validateContext(
    String profileId,
    String membershipId,
  ) async {
    for (final context in _contextsFor(profileId)) {
      if (context.membershipId == membershipId) return context;
    }
    return null;
  }

  @override
  Future<Set<String>> getEffectivePermissions(String membershipId) async {
    for (final contexts in _contextsByProfileId.values) {
      for (final context in contexts) {
        if (context.membershipId == membershipId) {
          return Set<String>.from(context.permissionCodes);
        }
      }
    }
    for (final context in FakeAccessContextSeed.multiple) {
      if (context.membershipId == membershipId) {
        return Set<String>.from(context.permissionCodes);
      }
    }
    if (FakeAccessContextSeed.single.membershipId == membershipId) {
      return Set<String>.from(FakeAccessContextSeed.single.permissionCodes);
    }
    return {};
  }
}
