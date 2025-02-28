part of 'task_bloc.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class CreateTask extends TaskEvent {
  final String title;
  final int id;

  CreateTask(this.title,this.id);
}

class UpdateTask extends TaskEvent {
  final int taskId;
  final int userId;
  final String title;
  final bool completed;

  UpdateTask(this.taskId, this.title, this.completed,this.userId);
}


class DeleteTask extends TaskEvent {
  final int id;

  DeleteTask(this.id);
}
class FetchUsers extends TaskEvent {}
