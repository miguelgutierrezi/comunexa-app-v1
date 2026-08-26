import 'package:comunexa/features/auth/domain/access_context.dart';
import 'package:comunexa/features/auth/domain/access_context_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAccessContextRepository implements AccessContextRepository {
  SupabaseAccessContextRepository(this._client);

  final SupabaseClient _client;

  static const _membershipSelect = '''
    id,
    role,
    status,
    organization_id,
    property_id,
    organizations!inner(id, name, active),
    properties!inner(id, name, property_type, branding_mode, active),
    permission_presets(
      permission_preset_permissions(
        permissions(code)
      )
    ),
    property_membership_permissions(
      permissions(code)
    )
  ''';

  @override
  Future<List<AccessContext>> getAvailableContexts(String profileId) async {
    final rows = await _queryMemberships(profileId);
    return rows.map(_mapRow).whereType<AccessContext>().toList();
  }

  @override
  Future<AccessContext?> validateContext(
    String profileId,
    String membershipId,
  ) async {
    final rows = await _client
        .from('property_memberships')
        .select(_membershipSelect)
        .eq('profile_id', profileId)
        .eq('id', membershipId)
        .eq('status', 'active')
        .maybeSingle();

    if (rows == null) return null;
    return _mapRow(rows);
  }

  @override
  Future<Set<String>> getEffectivePermissions(String membershipId) async {
    final row = await _client
        .from('property_memberships')
        .select(_membershipSelect)
        .eq('id', membershipId)
        .eq('status', 'active')
        .maybeSingle();

    if (row == null) return {};
    return _extractPermissionCodes(row);
  }

  Future<List<Map<String, dynamic>>> _queryMemberships(String profileId) async {
    final response = await _client
        .from('property_memberships')
        .select(_membershipSelect)
        .eq('profile_id', profileId)
        .eq('status', 'active');

    return (response as List)
        .cast<Map<String, dynamic>>();
  }

  AccessContext? _mapRow(Map<String, dynamic> row) {
    final org = row['organizations'] as Map<String, dynamic>?;
    final property = row['properties'] as Map<String, dynamic>?;
    if (org == null || property == null) return null;
    if (org['active'] != true || property['active'] != true) return null;

    return AccessContext(
      membershipId: row['id'] as String,
      organizationId: row['organization_id'] as String,
      organizationName: org['name'] as String,
      propertyId: row['property_id'] as String,
      propertyName: property['name'] as String,
      propertyType: property['property_type'] as String,
      roleCode: row['role'] as String,
      permissionCodes: _extractPermissionCodes(row),
      brandingMode: property['branding_mode'] as String,
      membershipStatus: row['status'] as String,
    );
  }

  Set<String> _extractPermissionCodes(Map<String, dynamic> row) {
    final codes = <String>{};

    final preset = row['permission_presets'];
    if (preset is Map<String, dynamic>) {
      final presetLinks =
          preset['permission_preset_permissions'] as List<dynamic>? ?? [];
      for (final link in presetLinks) {
        if (link is! Map<String, dynamic>) continue;
        final permission = link['permissions'];
        if (permission is Map<String, dynamic>) {
          final code = permission['code'];
          if (code is String) codes.add(code);
        }
      }
    }

    final explicit =
        row['property_membership_permissions'] as List<dynamic>? ?? [];
    for (final link in explicit) {
      if (link is! Map<String, dynamic>) continue;
      final permission = link['permissions'];
      if (permission is Map<String, dynamic>) {
        final code = permission['code'];
        if (code is String) codes.add(code);
      }
    }

    return codes;
  }
}
