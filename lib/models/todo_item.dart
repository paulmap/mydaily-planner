class TodoItem {
  final int? id;
  final int listId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  TodoItem({
    this.id,
    required this.listId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      listId: map['list_id'],
      title: map['title'],
      isCompleted: map['is_completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  TodoItem copyWith({
    int? id,
    int? listId,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
