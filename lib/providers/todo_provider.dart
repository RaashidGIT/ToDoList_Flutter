// State notifier & business logicimport 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../services/todo_api_service.dart';

enum TodoFilter { all, active, completed }

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);
final todoSearchQueryProvider = StateProvider<String>((ref) => '');
final todoApiServiceProvider = Provider((ref) => TodoApiService());

class TodoListNotifier extends AsyncNotifier<List<TodoItem>> {
  late final TodoApiService _api;

  @override
  Future<List<TodoItem>> build() async {
    _api = ref.watch(todoApiServiceProvider);
    return _api.fetchTodos();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _api.fetchTodos());
  }

  void insertAt(int index, TodoItem item) {
    final currentList = state.valueOrNull ?? [];
    final updated = List<TodoItem>.from(currentList);
    
    if (index >= 0 && index <= updated.length) {
      updated.insert(index, item);
    } else {
      updated.add(item);
    }
    
    state = AsyncData(updated);
  }

  Future<void> addTodo(
    String title, {
    DateTime? dueDate,
    TodoCategory category = TodoCategory.personal,
  }) async {
    final currentList = state.valueOrNull ?? [];
    final tempItem = TodoItem(
      id: '',
      title: title.trim(),
      dueDate: dueDate,
      category: category,
    );

    state = await AsyncValue.guard(() async {
      final savedItem = await _api.createTodo(tempItem);
      return [savedItem, ...currentList];
    });
  }

  Future<void> toggleTodo(String id) async {
    final currentList = state.valueOrNull ?? [];
    final target = currentList.firstWhere((t) => t.id == id);
    final updatedCompleted = !target.isCompleted;

    state = AsyncData([
      for (final item in currentList)
        if (item.id == id) item.copyWith(isCompleted: updatedCompleted) else item,
    ]);

    try {
      await _api.patchTodo(id, isCompleted: updatedCompleted);
    } catch (e, st) {
      state = AsyncData(currentList);
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteTodo(String id) async {
    final currentList = state.valueOrNull ?? [];
    final targetIndex = currentList.indexWhere((t) => t.id == id);
    if (targetIndex == -1) return;

    state = AsyncData(currentList.where((t) => t.id != id).toList());

    try {
      await _api.deleteTodo(id);
    } catch (e, st) {
      final rollback = List<TodoItem>.from(currentList);
      state = AsyncData(rollback);
      state = AsyncError(e, st);
    }
  }

  Future<void> undoDelete(int index, TodoItem item) async {
    final currentList = state.valueOrNull ?? [];
    final updated = List<TodoItem>.from(currentList);

    final safeIndex = index.clamp(0, updated.length);
    updated.insert(safeIndex, item);

    // Instant local UI restore
    state = AsyncData(updated);

    // Sync recreation to backend
    try {
      final recreated = await _api.createTodo(item);
      final synced = List<TodoItem>.from(state.valueOrNull ?? []);
      final targetIdx = synced.indexWhere((t) => t.id == item.id);
      if (targetIdx != -1) {
        synced[targetIdx] = recreated;
        state = AsyncData(synced);
      }
    } catch (e, st) {
      state = AsyncData(currentList);
      state = AsyncError(e, st);
    }
  }
} // <--- Notice: TodoListNotifier ends HERE now

final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<TodoItem>>(TodoListNotifier.new);

// Derived Provider: Filter + Search
final filteredTodoListProvider = Provider<AsyncValue<List<TodoItem>>>((ref) {
  final asyncTodos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  final query = ref.watch(todoSearchQueryProvider).toLowerCase().trim();

  return asyncTodos.whenData((todos) {
    return todos.where((todo) {
      final matchesFilter = switch (filter) {
        TodoFilter.all => true,
        TodoFilter.active => !todo.isCompleted,
        TodoFilter.completed => todo.isCompleted,
      };
      final matchesSearch = query.isEmpty || todo.title.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  });
});

// Derived Provider: Stats
final todoStatsProvider = Provider<(int total, int active, int completed)>((ref) {
  final todos = ref.watch(todoListProvider).valueOrNull ?? [];
  final active = todos.where((t) => !t.isCompleted).length;
  final completed = todos.where((t) => t.isCompleted).length;
  return (todos.length, active, completed);
});