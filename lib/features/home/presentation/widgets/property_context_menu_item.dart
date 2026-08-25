import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ítem del menú de cambio de propiedad/contexto (sidebar y header tablet).
class PropertyContextMenuItem extends StatelessWidget {
  const PropertyContextMenuItem({
    super.key,
    required this.access,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final UserAccessContext access;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : AppTheme.ink;
    final muted = isDark ? AppTheme.slateLight : AppTheme.slate;

    return MenuItemButton(
      onPressed: onTap,
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (selected) {
            return isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE);
          }
          return Colors.transparent;
        }),
      ),
      child: SizedBox(
        width: 200,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: access.iconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                access.iconAsset,
                width: 16,
                height: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    access.propertyName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    access.roleLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (selected)
              SvgPicture.asset(
                BrandAssets.iconCircleCheck,
                width: 16,
                height: 16,
              ),
          ],
        ),
      ),
    );
  }
}
