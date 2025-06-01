import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // 追加
import '../models/task.dart';

class TaskRepository extends ChangeNotifier { // TaskRepositoryにChangeNotifierを継承させる
  final List<Task> _tasks = [];

  List<Task> getAllTasks() {
    return List.unmodifiable(_tasks);
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners(); // 🔥 追加
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners(); // 🔥 追加
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners(); // 🔥 追加
  }

  void toggleTaskCompletion(String taskId){
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if(index != -1){
      final task = _tasks[index];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      _tasks[index] = updatedTask;
      notifyListeners(); // 🔥 追加
    }
  }
}
