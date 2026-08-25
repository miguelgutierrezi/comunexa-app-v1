import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/home/presentation/widgets/property_context_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Densidad del property switcher en header
/// (mobile `#35:5` · tablet portrait `#74:5`).
enum HeaderPropertySwitcherDensity {
  mobile,
  tabletPortrait;

  double get symbolSize => this == mobile ? 22 : 24;
  double get labelGap => this == mobile ? 10 : 12;
}

/// Símbolo + nombre de propiedad + chevron en header post-login.
class HeaderPropertySwitcher extends ConsumerWidget {
  const HeaderPropertySwitcher({
    super.key,
    this.density = HeaderPropertySwitcherDensity.mobile,
  });

  final HeaderPropertySwitcherDensity density;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = ref.watch(activeContextProvider) ?? mockSingleContext;
    final contexts = ref.watch(availableContextsProvider);
    final canSwitch = contexts.length > 1;
    final titleColor = isDark ? Colors.white : AppTheme.ink;
    final chevronColor = isDark ? AppTheme.slateLight : AppTheme.slate;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          BrandAssets.symbolNav,
          width: density.symbolSize,
          height: density.symbolSize,
        ),
        SizedBox(width: density.labelGap),
        Flexible(
          child: Text(
            active.propertyName,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        if (canSwitch) ...[
          const SizedBox(width: 4),
          Transform.rotate(
            angle: 1.5708,
            child: SvgPicture.asset(
              BrandAssets.iconChevronRight,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(chevronColor, BlendMode.srcIn),
            ),
          ),
        ],
      ],
    );

    if (!canSwitch) return content;

    return MenuAnchor(
      style: MenuStyle(
        visualDensity: VisualDensity.compact,
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          isDark ? AppTheme.cardDark : Colors.white,
        ),
        elevation: WidgetStatePropertyAll(8),
      ),
      builder: (context, controller, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: content,
          ),
        );
      },
      menuChildren: [
        for (final ctx in contexts)
          PropertyContextMenuItem(
            access: ctx,
            selected: ctx.id == active.id,
            isDark: isDark,
            onTap: () async {
              if (ctx.id == active.id) return;
              await ref.read(sessionProvider.notifier).selectContext(ctx.id);
            },
          ),
      ],
    );
  }
}
