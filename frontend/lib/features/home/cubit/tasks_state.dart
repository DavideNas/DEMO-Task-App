part of 'tasks_cubit.dart';

sealed class TasksState {
  const TasksState();
}

final class TasksInitial extends TasksState {}

final class TasksLoading extends TasksState {}

final class TaskError extends TasksState {
  final String error;
  TaskError(this.error);
}

final class AddNewTaskSuccess extends TasksState {
  final TaskModel taskModel;
  const AddNewTaskSuccess(this.taskModel);
}

final class GetTasksSuccess extends TasksState {
  final List<TaskModel> tasks;
  const GetTasksSuccess(this.tasks);
}
