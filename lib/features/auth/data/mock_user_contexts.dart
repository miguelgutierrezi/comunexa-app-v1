import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/data/access_context_mapper.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';

export 'package:comunexa/features/auth/data/access_context_mapper.dart'
    show AccessContextMapper;

/// Nombre de display para seeds demo (tests / Figma).
String mockUserDisplayNameForEmail(String email) {
  final normalized = email.trim().toLowerCase();
  if (normalized.contains('maria')) return 'María López';
  return 'Carlos Méndez';
}

/// Alias de [AccessContextMapper.applyLastUsedHighlight] para tests legacy.
List<UserAccessContext> applyLastUsedHighlight(
  List<UserAccessContext> contexts,
  String? lastUsedId,
) =>
    AccessContextMapper.applyLastUsedHighlight(contexts, lastUsedId);

/// Showcase Figma — un solo contexto (no usar en flujo productivo).
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
  mockSingleContext,
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
