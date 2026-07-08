import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';

class NetworkGraphNodeStyle {
  const NetworkGraphNodeStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
    required this.size,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;
  final double size;

  static NetworkGraphNodeStyle forNode(
    GraphNode node, {
    required bool isDark,
    required bool isHighlighted,
    required bool isPathEndpoint,
  }) {
    if (isPathEndpoint) {
      return NetworkGraphNodeStyle(
        background: AppColors.primary,
        foreground: AppColors.textOnPrimary,
        border: node.isOwnCard ? AppColors.graphOwnCardAccent : AppColors.primaryLight,
        icon: node.isOwnCard ? Icons.person_pin_rounded : _iconFor(node.type),
        size: _sizeFor(node.degree) + 6,
      );
    }
    if (node.isOwnCard) {
      return NetworkGraphNodeStyle(
        background:
            isDark ? AppColors.primaryContainerDark : AppColors.primaryContainer,
        foreground: isDark
            ? AppColors.onPrimaryContainerDark
            : AppColors.onPrimaryContainer,
        border: AppColors.graphOwnCardAccent,
        icon: Icons.person_pin_rounded,
        size: 58,
      );
    }
    final base = _baseForType(node.type, isDark);
    if (isHighlighted) {
      return NetworkGraphNodeStyle(
        background: base.background.withValues(alpha: 0.92),
        foreground: base.foreground,
        border: AppColors.primary,
        icon: _iconFor(node.type),
        size: _sizeFor(node.degree) + 4,
      );
    }
    return base.copyWith(icon: _iconFor(node.type), size: _sizeFor(node.degree));
  }

  static NetworkGraphNodeStyle _baseForType(GraphNodeType type, bool isDark) {
    switch (type) {
      case GraphNodeType.user:
        return NetworkGraphNodeStyle(
          background:
              isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainer,
          foreground: isDark
              ? AppColors.textPrimaryDark
              : AppColors.onPrimaryContainer,
          border: isDark ? AppColors.outlineDark : AppColors.outlineVariant,
          icon: Icons.person_outline_rounded,
          size: 52,
        );
      case GraphNodeType.card:
        return NetworkGraphNodeStyle(
          background: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          foreground:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          border: isDark ? AppColors.primaryDarkTheme : AppColors.primaryLight,
          icon: Icons.badge_outlined,
          size: 56,
        );
      case GraphNodeType.company:
        return NetworkGraphNodeStyle(
          background: isDark
              ? AppColors.graphCompanyNodeDark
              : AppColors.graphCompanyNodeLight,
          foreground:
              isDark ? AppColors.textPrimaryDark : AppColors.secondary,
          border: isDark ? AppColors.outlineDark : AppColors.outline,
          icon: Icons.business_outlined,
          size: 48,
        );
      case GraphNodeType.event:
        return NetworkGraphNodeStyle(
          background: isDark
              ? AppColors.graphEventNodeDark
              : AppColors.graphEventNodeLight,
          foreground: AppColors.graphEventAccent,
          border: AppColors.graphEventAccent,
          icon: Icons.event_outlined,
          size: 50,
        );
      case GraphNodeType.organization:
      case GraphNodeType.organizationEvent:
        return NetworkGraphNodeStyle(
          background:
              isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          foreground:
              isDark ? AppColors.textPrimaryDark : AppColors.textSecondary,
          border: isDark ? AppColors.outlineDark : AppColors.outlineVariant,
          icon: Icons.apartment_outlined,
          size: 46,
        );
      case GraphNodeType.skill:
        return NetworkGraphNodeStyle(
          background:
              isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          foreground: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
          border: isDark ? AppColors.outlineDark : AppColors.outlineVariant,
          icon: Icons.auto_awesome_outlined,
          size: 44,
        );
      case GraphNodeType.location:
        return NetworkGraphNodeStyle(
          background:
              isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          foreground: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
          border: isDark ? AppColors.outlineDark : AppColors.outlineVariant,
          icon: Icons.place_outlined,
          size: 44,
        );
    }
  }

  static IconData _iconFor(GraphNodeType type) {
    switch (type) {
      case GraphNodeType.user:
        return Icons.person_outline_rounded;
      case GraphNodeType.card:
        return Icons.badge_outlined;
      case GraphNodeType.company:
        return Icons.business_outlined;
      case GraphNodeType.event:
        return Icons.event_outlined;
      case GraphNodeType.organization:
        return Icons.apartment_outlined;
      case GraphNodeType.organizationEvent:
        return Icons.groups_outlined;
      case GraphNodeType.skill:
        return Icons.auto_awesome_outlined;
      case GraphNodeType.location:
        return Icons.place_outlined;
    }
  }

  static double _sizeFor(int degree) =>
      (44 + (degree.clamp(0, 8) * 3)).toDouble().clamp(44, 68);

  NetworkGraphNodeStyle copyWith({
    Color? background,
    Color? foreground,
    Color? border,
    IconData? icon,
    double? size,
  }) {
    return NetworkGraphNodeStyle(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      icon: icon ?? this.icon,
      size: size ?? this.size,
    );
  }
}
