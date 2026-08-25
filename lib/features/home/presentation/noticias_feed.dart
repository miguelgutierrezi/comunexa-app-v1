import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/home/data/mock_noticias.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Feed mobile “Novedades de la Comunidad” (Figma showcase).
class NoticiasFeed extends StatelessWidget {
  const NoticiasFeed({super.key, this.items = mockNoticias});

  final List<NoticiaItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            'NOVEDADES DE LA COMUNIDAD',
            style: TextStyle(
              color: isDark ? AppTheme.slate : AppTheme.slateLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.8,
            ),
          );
        }
        return NewsCard(item: items[index - 1]);
      },
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.item,
    this.dense = true,
  });

  final NoticiaItem item;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tags = item.tagColors(isDark);
    final titleSize = dense ? 15.0 : 16.0;
    final bodySize = dense ? 13.0 : 14.0;
    final bodyHeight = dense ? 18 / 13 : 20 / 14;
    final pad = dense ? 18.0 : 20.0;

    return Material(
      color: isDark ? AppTheme.cardDark : Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: item.accent),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize,
                      ),
                    ),
                    SizedBox(height: dense ? 6 : 8),
                    Text(
                      item.body,
                      style: TextStyle(
                        color: isDark ? AppTheme.slateLight : AppTheme.slate,
                        fontWeight: FontWeight.w400,
                        fontSize: bodySize,
                        height: bodyHeight,
                      ),
                    ),
                    SizedBox(height: dense ? 12 : 16),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tags.bg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.categoryLabel,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: tags.fg,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.timeLabel,
                          style: TextStyle(
                            color: isDark ? AppTheme.slate : AppTheme.slateLight,
                            fontWeight: FontWeight.w500,
                            fontSize: dense ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePlaceholderTab extends StatelessWidget {
  const HomePlaceholderTab({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              BrandAssets.iconSparkles,
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(
                isDark ? AppTheme.accentTeal : AppTheme.seedColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDark ? Colors.white : AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.slateLight : AppTheme.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
