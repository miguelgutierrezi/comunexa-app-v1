import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';
import 'package:comunexa/features/home/data/mock_noticias.dart';
import 'package:comunexa/features/home/presentation/desktop_dashboard.dart';
import 'package:comunexa/features/home/presentation/home_bottom_nav.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:comunexa/features/home/presentation/widgets/property_context_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Formulario “Añadir noticia”
/// (móvil `#112:5`/`#112:86` · tablet port `#116:5`/`#116:92` · tablet land `#114:8`/`#114:107` ·
/// desktop `#112:217`/`#112:317`).
/// Stub UI: no persiste; “Publicar” muestra snackbar.
class AddNewsScreen extends ConsumerStatefulWidget {
  const AddNewsScreen({super.key});

  @override
  ConsumerState<AddNewsScreen> createState() => _AddNewsScreenState();
}

enum _AddNewsDensity { mobile, tabletPortrait, tabletLandscape, desktop }

class _AddNewsScreenState extends ConsumerState<AddNewsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  NoticiaCategory _category = NoticiaCategory.administracion;
  DateTime _publishDate = DateTime(2026, 8, 24);
  String? _attachmentName = 'comunicado.pdf';
  String? _selectedContextId;

  static const _fieldShadowLight = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  static const _fieldShadowDark = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 16,
    offset: Offset(0, 6),
    spreadRadius: -6,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  UserAccessContext get _activeContext {
    final active = ref.read(activeContextProvider);
    final contexts = ref.read(availableContextsProvider);
    if (_selectedContextId != null) {
      for (final ctx in contexts) {
        if (ctx.id == _selectedContextId) return ctx;
      }
    }
    return active ?? mockSingleContext;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _publishDate = picked);
    }
  }

  void _onPublish() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título para la noticia')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicar noticia — próximamente')),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  String _categoryLabel(NoticiaCategory category) => switch (category) {
        NoticiaCategory.administracion => 'Administración',
        NoticiaCategory.evento => 'Evento',
        NoticiaCategory.mantenimiento => 'Mantenimiento',
        NoticiaCategory.normativa => 'Normativa',
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (width >= HomeShellScreen.desktopBreakpoint) {
          return _buildSplit(context, DashboardLayout.desktop);
        }
        if (width >= HomeShellScreen.tabletLandscapeBreakpoint &&
            width >= height) {
          return _buildSplit(context, DashboardLayout.tabletLandscape);
        }
        if (width >= HomeShellScreen.tabletPortraitBreakpoint &&
            height > width) {
          return _buildStacked(context, _AddNewsDensity.tabletPortrait);
        }
        return _buildStacked(context, _AddNewsDensity.mobile);
      },
    );
  }

  Widget _buildStacked(BuildContext context, _AddNewsDensity density) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scrollPad = density == _AddNewsDensity.tabletPortrait
        ? const EdgeInsets.fromLTRB(40, 32, 40, 32)
        : const EdgeInsets.fromLTRB(20, 24, 20, 24);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.ink : AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StackedAddNewsHeader(
              isDark: isDark,
              density: density,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: scrollPad,
                child: _AddNewsFormFields(
                  isDark: isDark,
                  density: density,
                  titleController: _titleController,
                  bodyController: _bodyController,
                  category: _category,
                  publishDateLabel: _formatDate(_publishDate),
                  attachmentName: _attachmentName,
                  propertyName: _activeContext.propertyName,
                  contexts: ref.watch(availableContextsProvider),
                  selectedContextId: _activeContext.id,
                  onCategoryChanged: (c) => setState(() => _category = c),
                  onPropertySelected: (id) =>
                      setState(() => _selectedContextId = id),
                  onPickDate: _pickDate,
                  onAttachTap: () {
                    setState(() => _attachmentName ??= 'comunicado.pdf');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Adjuntos — próximamente')),
                    );
                  },
                  onRemoveAttachment: () =>
                      setState(() => _attachmentName = null),
                  onPublish: _onPublish,
                  categoryLabel: _categoryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplit(BuildContext context, DashboardLayout layout) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppTheme.ink : AppTheme.fieldLight;
    // Desktop dark `#112:317` / tablet dark: chrome `#111E2E`.
    final chromeBg = isDark ? AppTheme.fieldDark : Colors.white;
    final cardBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final density = layout == DashboardLayout.desktop
        ? _AddNewsDensity.desktop
        : _AddNewsDensity.tabletLandscape;

    return Scaffold(
      backgroundColor: pageBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: layout.addNewsSidebarWidth,
            child: HomeSplitSidebar(
              current: HomeTab.noticias,
              layout: layout,
              onChanged: (tab) => Navigator.of(context).pop(tab),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SplitAddNewsTopBar(
                  isDark: isDark,
                  layout: layout,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: layout.addNewsBodyPadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: layout.addNewsCardWidth,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: chromeBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardBorder),
                            boxShadow: switch ((isDark, density)) {
                              // Tablet dark `#114:107`
                              (true, _AddNewsDensity.tabletLandscape) => const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              (false, _) => const [
                                  BoxShadow(
                                    color: Color(0x080F172A),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              _ => null,
                            },
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(layout.addNewsCardPadding),
                            child: _AddNewsFormFields(
                              isDark: isDark,
                              density: density,
                              titleController: _titleController,
                              bodyController: _bodyController,
                              category: _category,
                              publishDateLabel: _formatDate(_publishDate),
                              attachmentName: _attachmentName,
                              propertyName: _activeContext.propertyName,
                              contexts: ref.watch(availableContextsProvider),
                              selectedContextId: _activeContext.id,
                              onCategoryChanged: (c) =>
                                  setState(() => _category = c),
                              onPropertySelected: (id) =>
                                  setState(() => _selectedContextId = id),
                              onPickDate: _pickDate,
                              onAttachTap: () {
                                setState(
                                  () => _attachmentName ??= 'comunicado.pdf',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Adjuntos — próximamente'),
                                  ),
                                );
                              },
                              onRemoveAttachment: () =>
                                  setState(() => _attachmentName = null),
                              onPublish: _onPublish,
                              categoryLabel: _categoryLabel,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddNewsFormFields extends StatelessWidget {
  const _AddNewsFormFields({
    required this.isDark,
    required this.density,
    required this.titleController,
    required this.bodyController,
    required this.category,
    required this.publishDateLabel,
    required this.attachmentName,
    required this.propertyName,
    required this.contexts,
    required this.selectedContextId,
    required this.onCategoryChanged,
    required this.onPropertySelected,
    required this.onPickDate,
    required this.onAttachTap,
    required this.onRemoveAttachment,
    required this.onPublish,
    required this.categoryLabel,
  });

  final bool isDark;
  final _AddNewsDensity density;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final NoticiaCategory category;
  final String publishDateLabel;
  final String? attachmentName;
  final String propertyName;
  final List<UserAccessContext> contexts;
  final String selectedContextId;
  final ValueChanged<NoticiaCategory> onCategoryChanged;
  final ValueChanged<String> onPropertySelected;
  final VoidCallback onPickDate;
  final VoidCallback onAttachTap;
  final VoidCallback onRemoveAttachment;
  final VoidCallback onPublish;
  final String Function(NoticiaCategory) categoryLabel;

  @override
  Widget build(BuildContext context) {
    final fieldFill = isDark ? AppTheme.slate800 : AppTheme.fieldLight;
    final labelColor = isDark ? AppTheme.slateLight : AppTheme.slate;
    final hintColor = isDark ? AppTheme.slate : AppTheme.slateLight;
    final textColor = isDark ? Colors.white : AppTheme.ink;
    final iconMuted = isDark ? AppTheme.slateLight : AppTheme.slate;
    // Tablet land: campos flat. Resto: sombra soft/elevada.
    final fieldShadows = density == _AddNewsDensity.tabletLandscape
        ? const <BoxShadow>[]
        : isDark
            ? const [_AddNewsScreenState._fieldShadowDark]
            : const [_AddNewsScreenState._fieldShadowLight];
    final formGap = density == _AddNewsDensity.tabletLandscape ? 20.0 : 24.0;
    final labelSize = density == _AddNewsDensity.tabletLandscape ? 12.0 : 13.0;
    final descriptionMin = switch (density) {
      _AddNewsDensity.desktop ||
      _AddNewsDensity.tabletPortrait =>
        160.0,
      _AddNewsDensity.mobile => 140.0,
      _AddNewsDensity.tabletLandscape => null,
    };
    final dropzoneLabel =
        density == _AddNewsDensity.desktop ||
                density == _AddNewsDensity.tabletLandscape
            ? 'Arrastra o selecciona archivos'
            : 'Selecciona archivos';
    final dropzonePad = density == _AddNewsDensity.desktop ? 20.0 : 16.0;
    final chipPad = density == _AddNewsDensity.mobile ? 14.0 : 16.0;
    // Tablet port light: calendar azul; dark `#116:92`: calendar teal.
    final calendarColor = density == _AddNewsDensity.tabletPortrait
        ? (isDark ? AppTheme.accentTeal : AppTheme.seedColor)
        : iconMuted;
    // Sombras CTA: tablet port dark = negra; land/light = azul; desktop/móvil dark = glow.
    final publishShadows = switch ((isDark, density)) {
      (true, _AddNewsDensity.tabletPortrait) => const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      (true, _AddNewsDensity.desktop) || (true, _AddNewsDensity.mobile) =>
        const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Color(0x3300B4A6),
            blurRadius: 18,
          ),
        ],
      _ => const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
    };

    Widget gap() => SizedBox(height: formGap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(text: 'Título', color: labelColor, fontSize: labelSize),
        const SizedBox(height: 8),
        _OutlinedField(
          fill: fieldFill,
          shadows: fieldShadows,
          child: TextField(
            controller: titleController,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Escribe un título claro y conciso...',
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        gap(),
        _FieldLabel(text: 'Edificio', color: labelColor, fontSize: labelSize),
        const SizedBox(height: 8),
        _PropertySelector(
          propertyName: propertyName,
          contexts: contexts,
          selectedId: selectedContextId,
          isDark: isDark,
          fill: fieldFill,
          shadows: fieldShadows,
          textColor: textColor,
          iconColor: iconMuted,
          onSelected: onPropertySelected,
        ),
        gap(),
        _FieldLabel(text: 'Categoría', color: labelColor, fontSize: labelSize),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in NoticiaCategory.values)
              _CategoryChip(
                label: categoryLabel(c),
                selected: c == category,
                isDark: isDark,
                density: density,
                horizontalPadding: chipPad,
                onTap: () => onCategoryChanged(c),
              ),
          ],
        ),
        gap(),
        _FieldLabel(
          text: 'Descripción',
          color: labelColor,
          fontSize: labelSize,
        ),
        const SizedBox(height: 8),
        _OutlinedField(
          fill: fieldFill,
          shadows: fieldShadows,
          minHeight: descriptionMin,
          child: TextField(
            controller: bodyController,
            maxLines: null,
            minLines: density == _AddNewsDensity.desktop ? 6 : 4,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Detalla toda la información importante para la comunidad...',
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        gap(),
        _FieldLabel(
          text: 'Fecha de publicación',
          color: labelColor,
          fontSize: labelSize,
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: fieldFill,
                borderRadius: BorderRadius.circular(12),
                boxShadow: fieldShadows,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        publishDateLabel,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ),
                    SvgPicture.asset(
                      BrandAssets.iconCalendar,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        calendarColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        gap(),
        _FieldLabel(
          text: 'Archivos adjuntos',
          color: labelColor,
          fontSize: labelSize,
        ),
        const SizedBox(height: 8),
        _AttachmentDropzone(
          isDark: isDark,
          fill: fieldFill,
          label: dropzoneLabel,
          padding: dropzonePad,
          onTap: onAttachTap,
        ),
        if (attachmentName != null) ...[
          const SizedBox(height: 12),
          _AttachmentRow(
            name: attachmentName!,
            isDark: isDark,
            density: density,
            onRemove: onRemoveAttachment,
          ),
        ],
        gap(),
        SizedBox(
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: publishShadows,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPublish,
                borderRadius: BorderRadius.circular(14),
                child: const Center(
                  child: Text(
                    'Publicar noticia',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StackedAddNewsHeader extends StatelessWidget {
  const _StackedAddNewsHeader({
    required this.isDark,
    required this.density,
    required this.onBack,
  });

  final bool isDark;
  final _AddNewsDensity density;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final hPad = density == _AddNewsDensity.tabletPortrait ? 24.0 : 20.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800 : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                BrandAssets.iconArrowLeft,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : AppTheme.ink,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Añadir noticia',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.ink,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _SplitAddNewsTopBar extends StatelessWidget {
  const _SplitAddNewsTopBar({
    required this.isDark,
    required this.layout,
    required this.onBack,
  });

  final bool isDark;
  final DashboardLayout layout;
  final VoidCallback onBack;

  static const _backFillDark = Color(0xFF162535);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: layout.topBarHPad,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.fieldDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: isDark ? _backFillDark : AppTheme.fieldLight,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: SvgPicture.asset(
                    BrandAssets.iconArrowLeft,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : AppTheme.ink,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Añadir noticia',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.ink,
              fontWeight: FontWeight.w700,
              fontSize: layout.titleSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    required this.color,
    this.fontSize = 13,
  });

  final String text;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _OutlinedField extends StatelessWidget {
  const _OutlinedField({
    required this.fill,
    required this.child,
    this.shadows = const [],
    this.minHeight,
  });

  final Color fill;
  final Widget child;
  final List<BoxShadow> shadows;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

class _PropertySelector extends StatelessWidget {
  const _PropertySelector({
    required this.propertyName,
    required this.contexts,
    required this.selectedId,
    required this.isDark,
    required this.fill,
    required this.shadows,
    required this.textColor,
    required this.iconColor,
    required this.onSelected,
  });

  final String propertyName;
  final List<UserAccessContext> contexts;
  final String selectedId;
  final bool isDark;
  final Color fill;
  final List<BoxShadow> shadows;
  final Color textColor;
  final Color iconColor;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final chevron = SvgPicture.asset(
      BrandAssets.iconChevronRight,
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );

    Widget row = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        boxShadow: shadows,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              propertyName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
          Transform.rotate(angle: 1.5708, child: chevron),
        ],
      ),
    );

    if (contexts.length <= 1) return row;

    return MenuAnchor(
      style: MenuStyle(
        visualDensity: VisualDensity.compact,
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          isDark ? AppTheme.slate800 : Colors.white,
        ),
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
            borderRadius: BorderRadius.circular(12),
            child: row,
          ),
        );
      },
      menuChildren: [
        for (final ctx in contexts)
          PropertyContextMenuItem(
            access: ctx,
            selected: ctx.id == selectedId,
            isDark: isDark,
            onTap: () => onSelected(ctx.id),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.density,
    required this.horizontalPadding,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final _AddNewsDensity density;
  final double horizontalPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      // Desktop dark: glow teal. Tablet port dark `#116:92`: sombra negra CTA.
      // Tablet land dark: azul light. Resto dark: sombra negra compacta.
      final List<BoxShadow> shadows;
      if (density == _AddNewsDensity.desktop && isDark) {
        shadows = const [
          BoxShadow(color: Color(0x3300B4A6), blurRadius: 18),
        ];
      } else if (density == _AddNewsDensity.tabletPortrait && isDark) {
        shadows = const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -8,
          ),
        ];
      } else if (isDark && density != _AddNewsDensity.tabletLandscape) {
        shadows = const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
            spreadRadius: -6,
          ),
        ];
      } else {
        shadows = const [
          BoxShadow(
            color: Color(0x262563EB),
            blurRadius: 16,
            offset: Offset(0, 6),
            spreadRadius: -6,
          ),
        ];
      }

      return GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: shadows,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: horizontalPadding >= 16 ? 13 : 12,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: isDark ? AppTheme.slate800 : AppTheme.fieldLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.slateLight : AppTheme.slate,
              fontWeight: FontWeight.w500,
              fontSize: horizontalPadding >= 16 ? 13 : 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentDropzone extends StatelessWidget {
  const _AttachmentDropzone({
    required this.isDark,
    required this.fill,
    required this.label,
    required this.padding,
    required this.onTap,
  });

  final bool isDark;
  final Color fill;
  final String label;
  final double padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppTheme.accentTeal : AppTheme.seedColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: accent,
            strokeWidth: 1.5,
            dash: 4,
            gap: 4,
            radius: 12,
          ),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  BrandAssets.iconUpload,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.name,
    required this.isDark,
    required this.density,
    required this.onRemove,
  });

  final String name;
  final bool isDark;
  final _AddNewsDensity density;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // Pill: móvil/desktop light. Radio 12: tablet port/land y cualquier dark.
    final usePill = !isDark &&
        (density == _AddNewsDensity.mobile ||
            density == _AddNewsDensity.desktop);
    final radius = usePill ? 999.0 : 12.0;
    final closeSize = density == _AddNewsDensity.mobile ? 10.0 : 12.0;
    final hPad = density == _AddNewsDensity.mobile ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800 : AppTheme.fieldLight,
        borderRadius: BorderRadius.circular(radius),
        // Tablet `#114:8`/`#114:107`: adjunto flat; otros dark llevan sombra.
        boxShadow: isDark && density != _AddNewsDensity.tabletLandscape
            ? const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                  spreadRadius: -6,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            BrandAssets.iconFile,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              isDark ? AppTheme.slateLight : AppTheme.ink,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.ink,
                fontWeight: density == _AddNewsDensity.mobile
                    ? FontWeight.w500
                    : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: Center(
                child: SvgPicture.asset(
                  BrandAssets.iconXCircle,
                  width: closeSize,
                  height: closeSize,
                  colorFilter: ColorFilter.mode(
                    isDark ? AppTheme.slateLight : AppTheme.slate,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
