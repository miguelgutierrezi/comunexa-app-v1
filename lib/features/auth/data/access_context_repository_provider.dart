import 'package:comunexa/core/supabase/comunexa_supabase.dart';
import 'package:comunexa/features/auth/data/fake_access_context_repository.dart';
import 'package:comunexa/features/auth/data/supabase_access_context_repository.dart';
import 'package:comunexa/features/auth/domain/access_context.dart';
import 'package:comunexa/features/auth/domain/access_context_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accessContextRepositoryProvider = Provider<AccessContextRepository>(
  (ref) {
    if (!ComunexaSupabase.isInitialized) {
      return const UnconfiguredAccessContextRepository();
    }
    return SupabaseAccessContextRepository(ComunexaSupabase.client);
  },
);

/// Sin Supabase configurado: no hay membresías reales.
class UnconfiguredAccessContextRepository implements AccessContextRepository {
  const UnconfiguredAccessContextRepository();

  @override
  Future<List<AccessContext>> getAvailableContexts(String profileId) async =>
      const [];

  @override
  Future<AccessContext?> validateContext(
    String profileId,
    String membershipId,
  ) async =>
      null;

  @override
  Future<Set<String>> getEffectivePermissions(String membershipId) async =>
      {};
}

/// Provider de tests: fake en memoria con seeds demo.
final fakeAccessContextRepositoryProvider =
    Provider<FakeAccessContextRepository>(
  (ref) => FakeAccessContextRepository(),
);
