import 'package:comunexa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum NoticiaCategory {
  administracion,
  evento,
  mantenimiento,
  normativa,
}

class NoticiaItem {
  const NoticiaItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timeLabel,
    required this.accent,
  });

  final String id;
  final String title;
  final String body;
  final NoticiaCategory category;
  final String timeLabel;
  final Color accent;

  String get categoryLabel => switch (category) {
        NoticiaCategory.administracion => 'Administración',
        NoticiaCategory.evento => 'Evento',
        NoticiaCategory.mantenimiento => 'Mantenimiento',
        NoticiaCategory.normativa => 'Normativa',
      };

  ({Color bg, Color fg}) tagColors(bool isDark) => switch (category) {
        NoticiaCategory.administracion => isDark
            ? (bg: const Color(0xFF1E3A8A), fg: const Color(0xFF93C5FD))
            : (bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1E40AF)),
        NoticiaCategory.evento => isDark
            ? (bg: const Color(0xFF5B21B6), fg: const Color(0xFFC084FC))
            : (bg: const Color(0xFFF3E8FF), fg: const Color(0xFF6B21A8)),
        NoticiaCategory.mantenimiento => isDark
            ? (bg: const Color(0xFF78350F), fg: const Color(0xFFFCD34D))
            : (bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
        NoticiaCategory.normativa => isDark
            ? (bg: const Color(0xFF0C4A6E), fg: const Color(0xFF7DD3FC))
            : (bg: const Color(0xFFE0F2FE), fg: const Color(0xFF0369A1)),
      };
}

class ComunidadEvento {
  const ComunidadEvento({
    required this.monthLabel,
    required this.day,
    required this.title,
    required this.detail,
  });

  final String monthLabel;
  final String day;
  final String title;
  final String detail;
}

/// Contenido mock del showcase / dashboard Figma.
const List<NoticiaItem> mockNoticias = [
  NoticiaItem(
    id: '1',
    title: 'Mantenimiento del ascensor',
    body:
        'El ascensor del bloque A estará fuera de servicio el viernes 29 de agosto, de 8:00 a 14:00.',
    category: NoticiaCategory.administracion,
    timeLabel: 'Hace 2h',
    accent: AppTheme.seedColor,
  ),
  NoticiaItem(
    id: '2',
    title: 'Reunión de propietarios',
    body:
        'Se convoca reunión ordinaria el próximo martes 2 de septiembre a las 19:00 en el salón comunal.',
    category: NoticiaCategory.evento,
    timeLabel: 'Hace 5h',
    accent: AppTheme.accentViolet,
  ),
  NoticiaItem(
    id: '3',
    title: 'Fumigación de áreas comunes',
    body:
        'Se realizará fumigación preventiva este sábado. Se recomienda mantener ventanas cerradas.',
    category: NoticiaCategory.mantenimiento,
    timeLabel: 'Ayer',
    accent: AppTheme.accentTeal,
  ),
  NoticiaItem(
    id: '4',
    title: 'Nuevo reglamento de mascotas',
    body:
        'Estimados residentes, a partir del próximo mes entrará en vigencia el nuevo manual de convivencia...',
    category: NoticiaCategory.normativa,
    timeLabel: 'Hace 2 días',
    accent: Color(0xFF38BDF8),
  ),
];

const List<ComunidadEvento> mockEventos = [
  ComunidadEvento(
    monthLabel: 'SET',
    day: '02',
    title: 'Reunión General de Propietarios',
    detail: '19:00 - Salón Comunal',
  ),
  ComunidadEvento(
    monthLabel: 'SET',
    day: '05',
    title: 'Corte de Agua Programado',
    detail: '09:00 - Todo el edificio',
  ),
  ComunidadEvento(
    monthLabel: 'SET',
    day: '12',
    title: 'Feria de Emprendedores',
    detail: '10:00 - Terraza Principal',
  ),
];
