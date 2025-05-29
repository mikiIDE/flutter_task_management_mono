import 'package:flutter/material.dart';
// 🎯 ここが重要！Melosのローカルパッケージimport
import 'package:task_data/task_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melos Task Management',
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
  final TaskRepository _repository = TaskRepository();

  @override
  void initState() {
    super.initState();
    // テスト用のタスクを追加
    _repository.addTask(Task(
      id: '1',
      title: 'Melosテスト',
      description: 'パッケージ間連携のテスト',
    ));
    _repository.addTask(Task(
      id: '2',
      title: 'Flutter学習',
      description: 'Udemy講座の続き',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _repository.getAllTasks();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Melos連携テスト'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Melosパッケージ間連携成功！ 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _repository.addTask(Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'テストタスク',
            description: 'プラスボタンで動的に追加されたタスク',
          ));
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}