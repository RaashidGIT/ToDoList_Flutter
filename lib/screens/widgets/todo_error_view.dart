// Retry/error display

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TodoErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const TodoErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  String _formatError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your network.';
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _formatError(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}