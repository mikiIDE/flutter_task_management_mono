import 'package:flutter/material.dart';

class TaskForm extends StatefulWidget {
  // onSubmit = コールバック関数 → 何かが起こったら、この処理をして！という仕組み
  final Function(String title, String description) onSubmit;

  const TaskForm({super.key, required this.onSubmit});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  // メモリリーク（アプリが重たくなること）を避けるための掃除 = dispose
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _titleController.text,
        _descriptionController.text,
      );
      _titleController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop(); // ダイアログを閉じる
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("新しいタスクを追加"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "タスク名",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "タスク名を入力してください";
                }
                return null;
              },
            ),
            const SizedBox(height: 16,),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "説明",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "説明を入力してください";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("キャンセル"),
        ),
        ElevatedButton(onPressed: _submitForm,
            child: const Text("追加"),
        ),
      ],
    );
  }
}
