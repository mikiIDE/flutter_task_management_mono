import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加
import 'dart:convert'; // JSON変換用
import '../models/task.dart';

class TaskRepository extends ChangeNotifier { // TaskRepositoryにChangeNotifierを継承させる
  final List<Task> _tasks = [];
  static const String _tasksKey = "tasks"; // 保存用のキー

  List<Task> getAllTasks() {
    return List.unmodifiable(_tasks);
  }


  // 🆕 アプリ起動時にデータを読み込む
  Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJsonString = prefs.getString(_tasksKey);

      if (tasksJsonString != null) {
        final List<dynamic> tasksJsonList = json.decode(tasksJsonString);
        _tasks.clear();
        _tasks.addAll(
          tasksJsonList.map((taskJson) => Task.fromJson(taskJson)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('タスクの読み込みでエラーが発生しました: $e');
    }
  }

  // 🆕 データを保存する
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJsonList = _tasks.map((task) => task.toJson()).toList();
      final tasksJsonString = json.encode(tasksJsonList);
      await prefs.setString(_tasksKey, tasksJsonString);
    } catch (e) {
      print('タスクの保存でエラーが発生しました: $e');
    }
  }


  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks(); // 追加時に保存
    notifyListeners(); // 変更を知らせるため追加
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks(); // 更新時に保存
      notifyListeners(); // 変更を知らせるため追加
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks(); // 削除時に保存
    notifyListeners(); // 変更を知らせるため追加
  }

  void toggleTaskCompletion(String taskId){
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if(index != -1){
      final task = _tasks[index];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      _tasks[index] = updatedTask;
      _saveTasks(); // 完了切替時に保存
      notifyListeners(); // 変更を知らせるため追加
    }
  }
}
