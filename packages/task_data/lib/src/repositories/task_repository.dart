// packages/task_data/lib/src/repositories/task_repository.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加
import 'dart:convert'; // JSON変換用
import '../models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskRepository extends AsyncNotifier<List<Task>> {
  // 状態管理をProvider→RiverPodに変更
  // final List<Task> _tasks = []; //state操作に変更のためコメントアウト
  static const String _tasksKey = "tasks"; // 保存用のキー

  @override
  Future<List<Task>> build() async {
    // 🆕 アプリ起動時にデータを読み込む
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJsonString = prefs.getString(_tasksKey);
      if (tasksJsonString != null) {
        final List<dynamic> tasksJsonList = json.decode(tasksJsonString);
        return tasksJsonList
            .map((taskJson) => Task.fromJson(taskJson))
            .toList();
      }
      return []; // データがない場合は空リストを返す
    } catch (e) {
      print('タスクの読み込みでエラーが発生しました: $e');
      return []; // エラーが発生した場合も空リストを返す
    }
  }

  // 🆕 データを保存する
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJsonList =
          state.value!
              .map((task) => task.toJson())
              .toList(); // stateに変更、非同期処理のため!を使用
      final tasksJsonString = json.encode(tasksJsonList);
      await prefs.setString(_tasksKey, tasksJsonString);
    } catch (e) {
      print('タスクの保存でエラーが発生しました: $e');
    }
  }

  void addTask(Task task) {
    // RiverPodが自動処理するためnotifyListeners()は削除
    state = AsyncValue.data(
      [...state.value!, task], // state.value!：現在のタスクリスト、task：新しいタスクを末尾に追加
    );
    _saveTasks(); // 追加時に保存
  }

  void updateTask(Task updatedTask) {
    state = AsyncValue.data(
      state.value!
          .map((task) => task.id == updatedTask.id ? updatedTask : task)
          .toList(),
    );
    _saveTasks(); // 更新時に保存
  }

  void deleteTask(String taskId) {
    state = AsyncValue.data(
      state.value!.where((task) => task.id != taskId).toList(),
    );
    _saveTasks(); // 削除時に保存
  }

  void toggleTaskCompletion(String taskId) {
    state = AsyncValue.data(
      state.value!
          .map((task) =>
              task.id == taskId ? task.copyWith(isCompleted: !task.isCompleted) : task)
          .toList(),
    );
    _saveTasks(); // 完了切替時に保存
  }
}

// TaskRepositoryを全体で使えるようにするProvider（RiverPodのProvider）
final taskRepositoryProvider = AsyncNotifierProvider<TaskRepository, List<Task>>(
  () => TaskRepository(),
);
