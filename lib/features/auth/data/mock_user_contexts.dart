import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';

/// Resuelve contextos mock según el correo del bypass de login.
List<UserAccessContext> mockUserContextsForEmail(String email) {
  final normalized = email.trim().toLowerCase();
  if (normalized.startsWith('demo:single')) {
    return [mockSingleContext];
  }
  if (normalized.startsWith('demo:multi')) {
    return mockMultipleContexts;
  }
  // Bypass por defecto: un solo contexto → home directo.
  return [mockSingleContext];
}

String mockUserDisplayNameForEmail(String email) {
  final normalized = email.trim().toLowerCase();
  if (normalized.contains('maria')) return 'María López';
  return 'Carlos Méndez';
}

List<UserAccessContext> applyLastUsedHighlight(
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

const mockSingleContext = UserAccessContext(
  id: 'ctx-torres-resident',
  propertyName: 'Torres del Parque',
  roleLabel: 'Residente · Torre A, Apto 502',
  sidebarRoleLabel: 'Residente - T. A',
  iconAsset: BrandAssets.iconHouse,
  accent: AppTheme.accentTeal,
  isLastUsed: true,
);

/// Showcase Figma `#99:5` (multirrol).
const mockMultipleContexts = [
  UserAccessContext(
    id: 'ctx-torres-resident',
    propertyName: 'Torres del Parque',
    roleLabel: 'Residente · Torre A, Apto 502',
    sidebarRoleLabel: 'Residente - T. A',
    iconAsset: BrandAssets.iconHouse,
    accent: AppTheme.accentTeal,
    isLastUsed: true,
  ),
  UserAccessContext(
    id: 'ctx-atalia-admin',
    propertyName: 'Conjunto Residencial Atalia',
    roleLabel: 'Administrador',
    sidebarRoleLabel: 'Administrador',
    iconAsset: BrandAssets.iconBuilding,
    accent: AppTheme.seedColor,
  ),
  UserAccessContext(
    id: 'ctx-serena-reception',
    propertyName: 'Hotel Boutique Serena',
    roleLabel: 'Recepcionista',
    sidebarRoleLabel: 'Recepcionista',
    iconAsset: BrandAssets.iconHotel,
    accent: AppTheme.accentViolet,
  ),
  UserAccessContext(
    id: 'ctx-omega-cowner',
    propertyName: 'Parque Empresarial Omega',
    roleLabel: 'Co-propietario · Oficina 304',
    sidebarRoleLabel: 'Co-prop. · Of. 304',
    iconAsset: BrandAssets.iconBriefcase,
    accent: AppTheme.slate,
  ),
];
