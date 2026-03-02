class ItemModel {
  final int id;
  final int listId;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.listId,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  // Factory constructor depuis JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int,
      listId: json['list_id'] as int,
      title: json['title'] as String,
      isDone: (json['is_done'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'title': title,
      'is_done': isDone ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Méthode copyWith
  ItemModel copyWith({
    int? id,
    int? listId,
    String? title,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Pour faciliter le toggle
  ItemModel toggle() {
    return copyWith(isDone: !isDone);
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, title: $title, isDone: $isDone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
