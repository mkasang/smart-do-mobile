class SharedListModel {
  final int id;
  final int sharedWithUserId;
  final String permission; // 'read' ou 'edit'
  final String sharedWithName;
  final String sharedWithEmail;
  final int? listId;
  final String? listTitle;
  final String? ownerName;
  final String? ownerEmail;
  final int? totalItems;
  final int? completedItems;

  SharedListModel({
    required this.id,
    required this.sharedWithUserId,
    required this.permission,
    required this.sharedWithName,
    required this.sharedWithEmail,
    this.listId,
    this.listTitle,
    this.ownerName,
    this.ownerEmail,
    this.totalItems,
    this.completedItems,
  });

  // Factory constructor depuis JSON (pour les partages sur une liste)
  factory SharedListModel.fromJson(Map<String, dynamic> json) {
    return SharedListModel(
      id: json['id'] as int,
      sharedWithUserId: json['shared_with_user_id'] as int,
      permission: json['permission'] as String,
      sharedWithName: json['shared_with_name'] as String,
      sharedWithEmail: json['shared_with_email'] as String,
      listId: json['list_id'] as int?,
      listTitle: json['list_title'] as String?,
      ownerName: json['owner_name'] as String?,
      ownerEmail: json['owner_email'] as String?,
      totalItems: json['total_items'] as int?,
      completedItems: json['completed_items'] as int?,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shared_with_user_id': sharedWithUserId,
      'permission': permission,
      'shared_with_name': sharedWithName,
      'shared_with_email': sharedWithEmail,
      'list_id': listId,
      'list_title': listTitle,
      'owner_name': ownerName,
      'owner_email': ownerEmail,
      'total_items': totalItems,
      'completed_items': completedItems,
    };
  }

  // Méthode copyWith
  SharedListModel copyWith({
    int? id,
    int? sharedWithUserId,
    String? permission,
    String? sharedWithName,
    String? sharedWithEmail,
    int? listId,
    String? listTitle,
    String? ownerName,
    String? ownerEmail,
    int? totalItems,
    int? completedItems,
  }) {
    return SharedListModel(
      id: id ?? this.id,
      sharedWithUserId: sharedWithUserId ?? this.sharedWithUserId,
      permission: permission ?? this.permission,
      sharedWithName: sharedWithName ?? this.sharedWithName,
      sharedWithEmail: sharedWithEmail ?? this.sharedWithEmail,
      listId: listId ?? this.listId,
      listTitle: listTitle ?? this.listTitle,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
    );
  }

  // Propriétés calculées
  bool get canEdit => permission == 'edit';
  bool get canOnlyRead => permission == 'read';

  double get progress {
    if (totalItems == null || totalItems == 0) return 0;
    return (completedItems ?? 0) / totalItems!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedListModel &&
        other.id == id &&
        other.sharedWithUserId == sharedWithUserId;
  }

  @override
  int get hashCode => id.hashCode ^ sharedWithUserId.hashCode;
}
