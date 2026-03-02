// Modèle pour la création/ modification de liste
class CreateListRequest {
  final String title;
  final String type;
  final String? description;
  final DateTime? dueDate;
  final String? dueTime;

  CreateListRequest({
    required this.title,
    required this.type,
    this.description,
    this.dueDate,
    this.dueTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'description': description,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'due_time': dueTime,
    };
  }
}

// Modèle pour la mise à jour de liste
class UpdateListRequest {
  final String? title;
  final String? description;
  final String? status;
  final DateTime? dueDate;
  final String? dueTime;

  UpdateListRequest({
    this.title,
    this.description,
    this.status,
    this.dueDate,
    this.dueTime,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (dueDate != null)
        'due_date': dueDate!.toIso8601String().split('T').first,
      if (dueTime != null) 'due_time': dueTime,
    };
  }
}

// Modèle pour la création d'item
class CreateItemRequest {
  final int listId;
  final String title;

  CreateItemRequest({required this.listId, required this.title});

  Map<String, dynamic> toJson() {
    return {'list_id': listId, 'title': title};
  }
}

// Modèle pour le partage de liste
class ShareListRequest {
  final int userId;
  final String permission;

  ShareListRequest({required this.userId, required this.permission});

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'permission': permission};
  }
}

// Modèle pour la recherche d'utilisateurs
class UserSearchResult {
  final int id;
  final String name;
  final String email;

  UserSearchResult({required this.id, required this.name, required this.email});

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
