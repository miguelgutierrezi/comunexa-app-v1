/// Contexto operativo de acceso (membresía en propiedad).
class AccessContext {
  const AccessContext({
    required this.membershipId,
    required this.organizationId,
    required this.organizationName,
    required this.propertyId,
    required this.propertyName,
    required this.propertyType,
    required this.roleCode,
    required this.permissionCodes,
    required this.brandingMode,
    required this.membershipStatus,
  });

  final String membershipId;
  final String organizationId;
  final String organizationName;
  final String propertyId;
  final String propertyName;

  /// `building` | `residential_complex` | `hotel`
  final String propertyType;

  /// `property_manager` | `property_staff` | `member`
  final String roleCode;

  final Set<String> permissionCodes;

  /// `inherit` | `co_branded` | `white_label`
  final String brandingMode;

  /// `active` | `invited` | `suspended` | `ended`
  final String membershipStatus;
}
