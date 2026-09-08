import 'package:dio/dio.dart';
import '../models/todo_item.dart';

class TodoApiService {
  static const String _baseUrl = 'https://6aa02e2e3e0d88d3d7e570f3.mockapi.io/api/v1';

  final Dio _dio;

  TodoApiService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  // GET: Read all tasks
  Future<List<TodoItem>> fetchTodos() async {
    try {
      final response = await _dio.get('/todos');
      final data = response.data as List;
      return data
          .map((json) => TodoItem.fromMap(Map<String, dynamic>.from(json as Map)))
          .toList();
    } on DioException catch (e) {
      print('GET FAILED: ${e.response?.statusCode} -> ${e.response?.data}');
      rethrow;
    }
  }

  // POST: Create a task
  Future<TodoItem> createTodo(TodoItem item) async {
    try {
      final response = await _dio.post('/todos', data: item.toMap());
      print('POST SUCCESS: ${response.statusCode} -> ${response.data}');
      return TodoItem.fromMap(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      print('POST FAILED: ${e.response?.statusCode} -> ${e.response?.data}');
      rethrow;
    }
  }

  // PUT: Update complete status
  Future<TodoItem> patchTodo(String id, {required bool isCompleted}) async {
    final response = await _dio.put(
      '/todos/$id',
      data: {'isCompleted': isCompleted},
    );
    return TodoItem.fromMap(Map<String, dynamic>.from(response.data as Map));
  }

  // DELETE: Remove task
  Future<void> deleteTodo(String id) async {
    await _dio.delete('/todos/$id');
  }
}