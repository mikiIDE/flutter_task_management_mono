import '../models/task.dart';

class TaskRepository {
  final List<Task> _tasks = [];

  List<Task> getAllTasks() {
    return List.unmodifiable(_tasks);
  }

  void addTask(Task task) {
    _tasks.add(task);
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
  }
}