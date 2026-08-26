import 'package:comunexa/features/auth/domain/access_context.dart';

/// Membresías activas del perfil autenticado (fuente: Supabase / fake en tests).
abstract class AccessContextRepository {
  Future<List<AccessContext>> getAvailableContexts(String profileId);

  Future<AccessContext?> validateContext(
    String profileId,
    String membershipId,
  );

  Future<Set<String>> getEffectivePermissions(String membershipId);
}
