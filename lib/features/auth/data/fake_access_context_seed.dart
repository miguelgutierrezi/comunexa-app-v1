import 'package:comunexa/features/auth/domain/access_context.dart';

/// Seeds de membresía para tests y showcase (no producción).
abstract final class FakeAccessContextSeed {
  static const single = AccessContext(
    membershipId: 'ctx-torres-resident',
    organizationId: 'org-torres',
    organizationName: 'Administración Torres',
    propertyId: 'prop-torres',
    propertyName: 'Torres del Parque',
    propertyType: 'residential_complex',
    roleCode: 'member',
    permissionCodes: {},
    brandingMode: 'co_branded',
    membershipStatus: 'active',
  );

  static const ataliaAdmin = AccessContext(
    membershipId: 'ctx-atalia-admin',
    organizationId: 'org-atalia',
    organizationName: 'Atalia Admin',
    propertyId: 'prop-atalia',
    propertyName: 'Conjunto Residencial Atalia',
    propertyType: 'residential_complex',
    roleCode: 'property_manager',
    permissionCodes: {'manage_members'},
    brandingMode: 'co_branded',
    membershipStatus: 'active',
  );

  static const serenaReception = AccessContext(
    membershipId: 'ctx-serena-reception',
    organizationId: 'org-serena',
    organizationName: 'Serena Hotels',
    propertyId: 'prop-serena',
    propertyName: 'Hotel Boutique Serena',
    propertyType: 'hotel',
    roleCode: 'property_staff',
    permissionCodes: {'view_expected_visits', 'register_visit_entry'},
    brandingMode: 'inherit',
    membershipStatus: 'active',
  );

  static const omegaCowner = AccessContext(
    membershipId: 'ctx-omega-cowner',
    organizationId: 'org-omega',
    organizationName: 'Omega Business Park',
    propertyId: 'prop-omega',
    propertyName: 'Parque Empresarial Omega',
    propertyType: 'building',
    roleCode: 'member',
    permissionCodes: {},
    brandingMode: 'co_branded',
    membershipStatus: 'active',
  );

  static const multiple = [single, ataliaAdmin, serenaReception, omegaCowner];

  /// Misma convención que [FakeAuthRepository] para resolver por perfil.
  static String profileIdForEmail(String email) =>
      'fake-${email.trim().toLowerCase().hashCode}';

  static List<AccessContext> contextsForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.startsWith('demo:noaccess')) {
      return const [];
    }
    if (normalized.startsWith('demo:single')) {
      return [single];
    }
    if (normalized.startsWith('demo:multi')) {
      return List<AccessContext>.from(multiple);
    }
    return [single];
  }

  static List<AccessContext> contextsForProfileId(String profileId) {
    for (final email in [
      'demo:noaccess@test.com',
      'demo:single@test.com',
      'demo:multi@test.com',
    ]) {
      if (profileIdForEmail(email) == profileId) {
        return contextsForEmail(email);
      }
    }
    return [single];
  }
}
