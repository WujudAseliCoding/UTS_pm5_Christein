import 'package:flutter/material.dart';

import '../core/utils/responsive.dart';
import 'empty_state.dart';

/// Quiz-length options that never exceed the number of questions in the
/// selected category.
class QuizLengthSelector extends StatelessWidget {
  const QuizLengthSelector({
    super.key,
    required this.selected,
    required this.maxCount,
    required this.onChanged,
    this.enabled = true,
  });

  final int selected;
  final int maxCount;
  final ValueChanged<int> onChanged;
  final bool enabled;

  static List<int> optionsFor(int maxCount) {
    final values = <int>{5, 10, 15, 20, 30}
        .where((value) => value < maxCount)
        .toList();
    values.add(maxCount);
    if (values.length > 4) {
      return <int>[values.first, 10, 15, maxCount]..sort();
    }
    return values..sort();
  }

  @override
  Widget build(BuildContext context) {
    final options = optionsFor(maxCount);
    return Wrap(
      spacing: context.rs(8),
      runSpacing: context.rs(8),
      children: <Widget>[
        for (final count in options)
          ChoicePill(
            label: count == maxCount ? 'Semua ($count)' : '$count soal',
            selected: selected == count,
            dense: true,
            onTap: enabled ? () => onChanged(count) : () {},
            semanticLabel:
                '${count == maxCount ? 'Semua' : count} pertanyaan',
          ),
      ],
    );
  }
}
