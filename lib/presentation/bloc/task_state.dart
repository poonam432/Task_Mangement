import 'package:task_management/domain/task_model.dart';
import 'package:task_management/domain/user_model.dart';

class TaskState {
  final List<Task> tasks;
  final List<User> users;
  final bool isLoading;
  final String? error;

  TaskState({
    this.tasks = const [],
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<Task>? tasks,
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
