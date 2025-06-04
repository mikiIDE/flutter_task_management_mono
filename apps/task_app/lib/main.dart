// apps/task_app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:task_data/task_data.dart'; // 🎯 ここが重要！Melosのローカルパッケージimport
import 'package:ui_components/ui_components.dart'; // 正しいimport方法（src/ではなくパッケージ名で）
// import 'package:provider/provider.dart'; // データ永続化のため追加
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App w/ Melos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TaskTestPage(),
    );
  }
}

class TaskTestPage extends ConsumerStatefulWidget {
  const TaskTestPage({super.key});

  @override
  ConsumerState<TaskTestPage> createState() => _TaskTestPageState();
}

class _TaskTestPageState extends ConsumerState<TaskTestPage> {
  // final TaskRepository _repository = TaskRepository(); // 共有のTaskRepositoryを使うためコメントアウト

  @override
  Widget build(BuildContext context) {
    // final repository = context.read<TaskRepository>(); // ← context.readは１度だけ取得
    final asyncTasks = ref.watch(taskRepositoryProvider);

    return asyncTasks.when(
      data: (tasks) {
        final repository = ref.read(taskRepositoryProvider.notifier);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('タスク管理'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskStatsPage()),
                  );
                },
                icon: const Icon(Icons.bar_chart),
              ),
            ],
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '今日のタスク頑張るぞぃ！ 🎉',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      key: Key(task.id),
                      // 一意のキーが必要
                      direction: DismissDirection.endToStart,
                      // 右から左へのスワイプ
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        // 確認ダイアログを追加
                        final bool? shouldDelete = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("タスクを削除"),
                                content: Text("「${task.title}」を削除しますか？"),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text("キャンセル"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: const Text(
                                      "削除",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (shouldDelete == true) {
                          repository.deleteTask(task.id);
                          return true; // 削除実行
                        }
                        return false; // 削除キャンセル
                      },
                      child: TaskCard(
                        title: task.title,
                        description: task.description,
                        isCompleted: task.isCompleted,
                        onTap: () {
                          repository.toggleTaskCompletion(task.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => TaskForm(
                      // TaskFormへ変更
                      onSubmit: (title, description) {
                        repository.addTask(
                          Task(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            title: title,
                            description: description,
                          ),
                        );
                      },
                    ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(title: const Text('タスク管理')),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('タスク管理')),
            body: Center(child: Text('Error: $error')),
          ),
    );
  }
}

class TaskStatsPage extends ConsumerWidget {
  // final TaskRepository _repository = TaskRepository(); // 新しいインスタンス

  const TaskStatsPage({super.key}); // constはなくてもOK

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskRepositoryProvider);

    return asyncTasks.when(
      data: (tasks) {
        final completedTasks = tasks.where((task) => task.isCompleted).length;
        final totalTasks = tasks.length;

        return Scaffold(
      appBar: AppBar(title: const Text("タスク統計")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("総タスク数：$totalTasks", style: TextStyle(fontSize: 24)),
            Text("完了済み：$completedTasks", style: TextStyle(fontSize: 24)),
            Text(
              "未完了：${totalTasks - completedTasks}",
              style: TextStyle(fontSize: 24),
            ),
          ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('タスク統計')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('タスク統計')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
