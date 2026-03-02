import 'package:smart_do/models/item_model.dart';
import 'package:smart_do/models/shared_list_model.dart';

class ListModel {
  final int id;
  final int userId;
  final String title;
  final String type; // 'simple' ou 'checklist'
  final String? description;
  final String status; // 'active' ou 'completed'
  final DateTime? dueDate;
  final String? dueTime;
  final DateTime createdAt;
  final String? ownerName;
  final int totalItems;
  final int completedItems;
  final List<ItemModel>? items;
  final List<SharedListModel>? sharedWith;

  ListModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.description,
    required this.status,
    this.dueDate,
    this.dueTime,
    required this.createdAt,
    this.ownerName,
    required this.totalItems,
    required this.completedItems,
    this.items,
    this.sharedWith,
  });

  // Factory constructor depuis JSON
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      dueTime: json['due_time'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      ownerName: json['owner_name'] as String?,
      totalItems: json['total_items'] as int? ?? 0,
      completedItems: json['completed_items'] as int? ?? 0,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => ItemModel.fromJson(item))
                .toList()
          : null,
      sharedWith: json['shared_with'] != null
          ? (json['shared_with'] as List)
                .map((share) => SharedListModel.fromJson(share))
                .toList()
          : null,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'type': type,
      'description': description,
      'status': status,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'due_time': dueTime,
      'created_at': createdAt.toIso8601String(),
      'owner_name': ownerName,
      'total_items': totalItems,
      'completed_items': completedItems,
      'items': items?.map((item) => item.toJson()).toList(),
      'shared_with': sharedWith?.map((share) => share.toJson()).toList(),
    };
  }

  // Méthode copyWith
  ListModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? type,
    String? description,
    String? status,
    DateTime? dueDate,
    String? dueTime,
    DateTime? createdAt,
    String? ownerName,
    int? totalItems,
    int? completedItems,
    List<ItemModel>? items,
    List<SharedListModel>? sharedWith,
  }) {
    return ListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      createdAt: createdAt ?? this.createdAt,
      ownerName: ownerName ?? this.ownerName,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
      items: items ?? this.items,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }

  // Propriétés calculées
  double get progress {
    if (totalItems == 0) return 0;
    return completedItems / totalItems;
  }

  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'active';
  bool get isChecklist => type == 'checklist';
  bool get isSimple => type == 'simple';

  String get formattedDueDate {
    if (dueDate == null) return 'Pas de date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    if (due == today) return "Aujourd'hui";
    if (due == today.add(const Duration(days: 1))) return "Demain";
    if (due == today.subtract(const Duration(days: 1))) return "Hier";

    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
