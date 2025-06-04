// packages/task_data/lib/src/models/task.dart
class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 一部だけ変更した新しいTaskを作成する（新しい値がなければ元の値を使う）
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSONに変換する（保存用）
  Map<String, dynamic> toJson(){
    return{
      "id": id,
      "title": title,
      "description": description,
      "isCompleted":isCompleted,
      "createdAt": createdAt.toIso8601String(), // DateTime → String へ変換
    };
  }

  // JSONからTaskを作成する（読み込み用）
  factory Task.fromJson(Map<String, dynamic> json){
    return Task(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      isCompleted: json["isCompleted"],
      createdAt: DateTime.parse(json["createdAt"]), // String → DateTime へ変換
    );
  }

  // デバッグ用
  @override
  String toString() {
    return 'Task(id: $id, title: $title, completed: $isCompleted)';
  }
}
