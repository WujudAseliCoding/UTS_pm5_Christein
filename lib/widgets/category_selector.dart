import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';
import '../data/models/quiz_settings.dart';

/// Returns a short description for each category.
String categoryDescription(QuizCategory category) => switch (category) {
  QuizCategory.flutter => 'Widget, layout, lifecycle',
  QuizCategory.dart => 'Sintaks, async, OOP',
  QuizCategory.general => 'Sains, budaya, logika',
};

IconData categoryIcon(QuizCategory? category) => switch (category) {
  QuizCategory.flutter => Icons.flutter_dash_rounded,
  QuizCategory.dart => Icons.code_rounded,
  QuizCategory.general => Icons.public_rounded,
  null => Icons.auto_awesome_rounded,
};

/// Four selectable category cards, including a mixed quiz.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.countForCategory,
    this.enabled = true,
  });

  /// `null` means all categories.
  final QuizCategory? selected;
  final ValueChanged<QuizCategory?> onChanged;
  final int Function(QuizCategory? category) countForCategory;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final categories = <QuizCategory?>[null, ...QuizCategory.values];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < context.rs(340) ? 1 : 2;
        final gap = context.rs(10);
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final category in categories)
              SizedBox(
                width: width,
                child: _CategoryCard(
                  category: category,
                  count: countForCategory(category),
                  selected: selected == category,
                  enabled: enabled,
                  onTap: () => onChanged(category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final QuizCategory? category;
  final int count;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final label = category?.label ?? 'Campuran';
    final description = category == null
        ? 'Semua topik'
        : categoryDescription(category!);
    final radius = BorderRadius.circular(context.rs(16));

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$label, $description, $count soal',
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.all(context.rs(13)),
            decoration: BoxDecoration(
              color: selected ? palette.softPrimary : palette.optionSurface,
              borderRadius: radius,
              border: Border.all(
                color: selected ? scheme.primary : palette.optionBorder,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: context.rs(36),
                  height: context.rs(36),
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primary
                        : palette.softPrimary,
                    borderRadius: BorderRadius.circular(context.rs(11)),
                  ),
                  child: Icon(
                    categoryIcon(category),
                    size: context.rs(19),
                    color: selected ? scheme.onPrimary : scheme.primary,
                  ),
                ),
                SizedBox(width: context.rs(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: selected ? scheme.primary : null,
                        ),
                      ),
                      SizedBox(height: context.rs(2)),
                      Text(
                        '$description • $count',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.mutedText,
                          fontSize: context.rs(11.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: context.rs(18),
                    color: scheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
