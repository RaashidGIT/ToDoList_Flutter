// Segmented buttons

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_provider.dart';

class TodoFilterBar extends ConsumerWidget {
  const TodoFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(todoFilterProvider);
    final (totalCount, activeCount, completedCount) = ref.watch(todoStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<TodoFilter>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: TodoFilter.all,
              label: Text('All ($totalCount)',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            ButtonSegment(
              value: TodoFilter.active,
              label: Text('Active ($activeCount)',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            ButtonSegment(
              value: TodoFilter.completed,
              label: Text('Done ($completedCount)',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
          selected: {activeFilter},
          onSelectionChanged: (selection) {
            ref.read(todoFilterProvider.notifier).state = selection.first;
          },
        ),
      ),
    );
  }
}