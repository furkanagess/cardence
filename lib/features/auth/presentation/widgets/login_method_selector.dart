import 'package:flutter/material.dart';

import '../bloc/login_event.dart';

class LoginMethodSelector extends StatelessWidget {
  const LoginMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final LoginMethod selected;
  final ValueChanged<LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _Segment(
              label: 'E-posta',
              icon: Icons.mail_outline_rounded,
              selected: selected == LoginMethod.email,
              onTap: () => onChanged(LoginMethod.email),
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _Segment(
              label: 'Telefon',
              icon: Icons.phone_android_rounded,
              selected: selected == LoginMethod.phone,
              onTap: () => onChanged(LoginMethod.phone),
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
