import 'package:flutter/material.dart';

/// Contexto operativo: propiedad + función (membresía contextual).
class UserAccessContext {
  const UserAccessContext({
    required this.id,
    required this.propertyName,
    required this.roleLabel,
    required this.sidebarRoleLabel,
    required this.iconAsset,
    required this.accent,
    this.isLastUsed = false,
  });

  final String id;
  final String propertyName;
  /// Rol completo (selector / property switcher).
  final String roleLabel;
  /// Rol abreviado para la user card del sidebar (`Residente - T. A`).
  final String sidebarRoleLabel;
  final String iconAsset;
  final Color accent;
  final bool isLastUsed;

  Color get iconBackground => accent.withValues(alpha: 0.1);
}
