class TodoList {
  final int? id;
  final String date;
  final DateTime createdAt;

  TodoList({
    this.id,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TodoList.fromMap(Map<String, dynamic> map) {
    return TodoList(
      id: map['id'],
      date: map['date'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  TodoList copyWith({
    int? id,
    String? date,
    DateTime? createdAt,
  }) {
    return TodoList(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
