// Data classes & serialization

import 'package:flutter/material.dart';

enum TodoCategory {
  work('Work', Colors.blue),
  personal('Personal', Colors.purple),
  study('Study', Colors.orange);

  final String label;
  final MaterialColor color;
  const TodoCategory(this.label, this.color);
}

@immutable
class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final TodoCategory category;

  const TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.category = TodoCategory.personal,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    TodoCategory? category,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'isCompleted': isCompleted,
      'category': category.name,
    };
    if (dueDate != null) {
      map['dueDate'] = dueDate!.toIso8601String();
    }
    // Only send ID if updating an existing record
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  factory TodoItem.fromMap(Map<dynamic, dynamic> map) {
  return TodoItem(
    id: map['id'].toString(),
    title: (map['title'] ?? '') as String,
    isCompleted: (map['isCompleted'] ?? map['completed'] ?? false) as bool,
    dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate'] as String) : null,
    category: TodoCategory.values.firstWhere(
      (c) => c.name == map['category'],
      orElse: () => TodoCategory.personal,
    ),
  );
}
}