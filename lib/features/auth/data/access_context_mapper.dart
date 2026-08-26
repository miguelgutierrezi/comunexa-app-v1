import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/domain/access_context.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';
import 'package:flutter/material.dart';

/// Mapea [AccessContext] (dominio) a [UserAccessContext] (presentación).
abstract final class AccessContextMapper {
  static UserAccessContext toUserAccessContext(
    AccessContext context, {
    bool isLastUsed = false,
  }) {
    final presentation = _presentationFor(context);
    return UserAccessContext(
      id: context.membershipId,
      propertyName: context.propertyName,
      roleLabel: presentation.roleLabel,
      sidebarRoleLabel: presentation.sidebarRoleLabel,
      iconAsset: presentation.iconAsset,
      accent: presentation.accent,
      isLastUsed: isLastUsed,
    );
  }

  static List<UserAccessContext> applyLastUsedHighlight(
    List<UserAccessContext> contexts,
    String? lastUsedId,
  ) {
    if (lastUsedId == null) return contexts;
    return [
      for (final context in contexts)
        UserAccessContext(
          id: context.id,
          propertyName: context.propertyName,
          roleLabel: context.roleLabel,
          sidebarRoleLabel: context.sidebarRoleLabel,
          iconAsset: context.iconAsset,
          accent: context.accent,
          isLastUsed: context.id == lastUsedId,
        ),
    ];
  }

  static _Presentation _presentationFor(AccessContext context) {
    final roleCode = context.roleCode;
    final propertyType = context.propertyType;

    if (roleCode == 'property_manager') {
      return _Presentation(
        roleLabel: 'Administrador',
        sidebarRoleLabel: 'Administrador',
        iconAsset: _iconForPropertyType(propertyType, fallback: BrandAssets.iconBuilding),
        accent: AppTheme.seedColor,
      );
    }

    if (roleCode == 'property_staff') {
      final isReception = propertyType == 'hotel';
      return _Presentation(
        roleLabel: isReception ? 'Recepcionista' : 'Staff',
        sidebarRoleLabel: isReception ? 'Recepcionista' : 'Staff',
        iconAsset: isReception ? BrandAssets.iconHotel : BrandAssets.iconBuilding,
        accent: isReception ? AppTheme.accentViolet : AppTheme.slate,
      );
    }

    // member — detalle de unidad vendrá de occupancies en un cutover posterior.
    return _Presentation(
      roleLabel: 'Residente · ${context.propertyName}',
      sidebarRoleLabel: 'Residente',
      iconAsset: _iconForPropertyType(propertyType, fallback: BrandAssets.iconHouse),
      accent: AppTheme.accentTeal,
    );
  }

  static String _iconForPropertyType(
    String propertyType, {
    required String fallback,
  }) {
    return switch (propertyType) {
      'hotel' => BrandAssets.iconHotel,
      'building' => BrandAssets.iconBuilding,
      'residential_complex' => BrandAssets.iconHouse,
      _ => fallback,
    };
  }
}

class _Presentation {
  const _Presentation({
    required this.roleLabel,
    required this.sidebarRoleLabel,
    required this.iconAsset,
    required this.accent,
  });

  final String roleLabel;
  final String sidebarRoleLabel;
  final String iconAsset;
  final Color accent;
}
