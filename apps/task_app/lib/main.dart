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

class TaskTestPage extends StatefulWidget {
  const TaskTestPage({super.key});

  @override
  State<TaskTestPage> createState() => _TaskTestPageState();
}

class _TaskTestPageState extends State<TaskTestPage> {
  // final TaskRepository _repository = TaskRepository(); // 共有のTaskRepositoryを使うためコメントアウト
  bool _isLoading = true; // ローディング状態を管理

  @override
  void initState() {
    super.initState();
    //   起動時にデータを読み込む
    _loadInitialData();
  }

  // 初期データ読み込み処理
  Future<void> _loadInitialData() async {
    final repository = context.read<TaskRepository>();

    //   保存されたタスクを読み込み
    await repository.loadTasks();

    // もしタスクが何もなければ、サンプルタスクを追加
    if (repository.getAllTasks().isEmpty) {
      repository.addTask(
        Task(id: "1", title: "Melosテスト", description: "パッケージ間関連のテスト"),
      );
      repository.addTask(
        Task(id: "2", title: "Flutter学習", description: "Udemy講座の続き"),
      );
    }

    //   ローディング完了
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final repository = context.read<TaskRepository>(); // ← context.readは１度だけ取得
    final repository =
        context.watch<TaskRepository>(); // ← context.watchはデータの変更を自動再取得してくれる
    final tasks = repository.getAllTasks(); // ← _repository を repository に変更

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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(), // ローディング中の表示
              )
              : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '今日のタスク頑張るぞぃ！ 🎉',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: const Text("キャンセル"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
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
                              setState(() {}); // 画面を更新
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
                              setState(() {
                                //   画面を更新
                              });
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
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        description: description,
                      ),
                    );
                    setState(() {}); // 画面を更新
                  },
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskStatsPage extends StatelessWidget {
  // final TaskRepository _repository = TaskRepository(); // 新しいインスタンス

  const TaskStatsPage({super.key}); // constはなくてもOK

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TaskRepository>(); // 共有のRepositoryを使用する
    final tasks = repository.getAllTasks(); // ← _repositoryをrepositoryへ変更
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
  }
}
