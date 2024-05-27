class Todo {
  final int id;
  final String title;
  final String createAt;
  final String? updatedAt;

  Todo(
      {required this.id,
      required this.title,
      required this.createAt,
      required this.updatedAt});

  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) => Todo(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      createAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at']).toString(),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['updated_at']).toString());
}
