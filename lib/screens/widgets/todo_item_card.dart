// List tile & dismissible card

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/todo_item.dart';
import '../../providers/todo_provider.dart';

class TodoItemCard extends ConsumerWidget {
  final TodoItem item;
  final int index;

  const TodoItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.redAccent,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          final deletedItem = item;
          final deletedIndex = index;

          // 1. Cache the notifier instance BEFORE the widget finishes disposing
          final notifier = ref.read(todoListProvider.notifier);

          // 2. Perform deletion
          notifier.deleteTodo(deletedItem.id);

          // 3. Show SnackBar using the cached notifier (NOT ref)
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${deletedItem.title}"'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  // Uses cached instance; does not touch ref after disposal
                  notifier.undoDelete(deletedIndex, deletedItem);
                },
              ),
            ),
          );
        },
        child: CheckboxListTile(
          value: item.isCompleted,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.category.color.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  item.category.label,
                  style: TextStyle(
                    color: item.category.color.shade900,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: item.dueDate != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 13,
                        color: item.dueDate!.isBefore(DateTime.now()) && !item.isCompleted
                            ? Colors.redAccent
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(item.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: item.dueDate!.isBefore(DateTime.now()) && !item.isCompleted
                              ? Colors.redAccent
                              : Colors.grey[600],
                          fontWeight: item.dueDate!.isBefore(DateTime.now()) && !item.isCompleted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          onChanged: (_) {
            ref.read(todoListProvider.notifier).toggleTodo(item.id);
          },
        ),
      ),
    );
  }
}