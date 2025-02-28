import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/domain/task_model.dart';
import 'package:task_management/domain/user_model.dart';
import 'package:task_management/infrastructure/local/database_helper.dart';
import 'package:task_management/infrastructure/repositories/task_repository.dart';
import 'package:task_management/presentation/bloc/task_state.dart';

part 'task_event.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  final DatabaseHelper dbHelper = DatabaseHelper.instance; // ✅ DatabaseHelper instance

  TaskBloc(this.taskRepository) : super(TaskState()) {
    on<LoadTasks>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        // ✅ Fetch tasks from API
        final apiTasks = await taskRepository.getTasks();

        // ✅ Clear old local tasks and insert new ones
        final db = await dbHelper.database;
        await db.delete('tasks');

        for (var task in apiTasks) {
          await dbHelper.insertTask(task);
        }

        // ✅ Load tasks from SQLite
        final localTasks = await dbHelper.fetchTasks();
        emit(state.copyWith(tasks: localTasks, isLoading: false));
      } catch (e) {
        emit(state.copyWith(error: e.toString(), isLoading: false));
      }
    });

    on<CreateTask>((event, emit) async {
      try {
        final newTask = await taskRepository.createTask(event.title, event.id); // ✅ API Call
        await dbHelper.insertTask(newTask); // ✅ Save to SQLite

        emit(state.copyWith(tasks: [...state.tasks, newTask]));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    on<UpdateTask>((event, emit) async {
      try {
        final updatedTask = await taskRepository.updateTask(event.taskId, event.title, event.completed,event.userId);
        await dbHelper.updateTask(updatedTask); // ✅ Update SQLite

        final updatedTasks = state.tasks.map((task) {
          return task.id == event.taskId ? updatedTask : task;
        }).toList();

        emit(state.copyWith(tasks: updatedTasks));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await taskRepository.deleteTask(event.id);
        await dbHelper.deleteTask(event.id);

        final updatedTasks = state.tasks.where((task) => task.id != event.id).toList();
        emit(state.copyWith(tasks: updatedTasks));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    on<FetchUsers>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        final users = await taskRepository.fetchUsers(); // ✅ Fetch users from API
        emit(state.copyWith(users: users, isLoading: false)); // ✅ Update only users
      } catch (e) {
        emit(state.copyWith(error: e.toString(), isLoading: false));
      }
    });
  }
}
