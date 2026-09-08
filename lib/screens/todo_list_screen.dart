// Main list view screen

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import 'widgets/add_todo_dialog.dart';
import 'widgets/todo_filter_bar.dart';
import 'widgets/todo_item_card.dart';
import 'widgets/todo_error_view.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddTodoDialog(),
    );
  }

  String _formatError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Check your network.';
        case DioExceptionType.badResponse:
          return 'Server error (${error.response?.statusCode}).';
        default:
          return 'Network connection failed.';
      }
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredTodoListProvider);

    ref.listen(todoListProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_formatError(next.error!)),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: () => ref.read(todoListProvider.notifier).refresh(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (val) =>
                    ref.read(todoSearchQueryProvider.notifier).state = val,
              )
            : const Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(todoSearchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(todoListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          const TodoFilterBar(),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => TodoErrorView(
                error: err,
                onRetry: () => ref.read(todoListProvider.notifier).refresh(),
              ),
              data: (todos) => todos.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching tasks found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(todoListProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        itemCount: todos.length,
                        itemBuilder: (context, index) => TodoItemCard(
                          item: todos[index],
                          index: index,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}