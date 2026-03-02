class StatsModel {
  final ListsStats lists;
  final ItemsStats items;
  final SharingStats sharing;
  final TimelineStats timeline;
  final SummaryStats summary;

  StatsModel({
    required this.lists,
    required this.items,
    required this.sharing,
    required this.timeline,
    required this.summary,
  });

  // Factory constructor depuis JSON
  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      lists: ListsStats.fromJson(json['lists'] as Map<String, dynamic>),
      items: ItemsStats.fromJson(json['items'] as Map<String, dynamic>),
      sharing: SharingStats.fromJson(json['sharing'] as Map<String, dynamic>),
      timeline: TimelineStats.fromJson(
        json['timeline'] as Map<String, dynamic>,
      ),
      summary: SummaryStats.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'lists': lists.toJson(),
      'items': items.toJson(),
      'sharing': sharing.toJson(),
      'timeline': timeline.toJson(),
      'summary': summary.toJson(),
    };
  }

  // Méthode copyWith
  StatsModel copyWith({
    ListsStats? lists,
    ItemsStats? items,
    SharingStats? sharing,
    TimelineStats? timeline,
    SummaryStats? summary,
  }) {
    return StatsModel(
      lists: lists ?? this.lists,
      items: items ?? this.items,
      sharing: sharing ?? this.sharing,
      timeline: timeline ?? this.timeline,
      summary: summary ?? this.summary,
    );
  }
}

// Statistiques des listes
class ListsStats {
  final int total;
  final int active;
  final int completed;
  final int simple;
  final int checklist;

  ListsStats({
    required this.total,
    required this.active,
    required this.completed,
    required this.simple,
    required this.checklist,
  });

  factory ListsStats.fromJson(Map<String, dynamic> json) {
    return ListsStats(
      total: json['total'] as int,
      active: json['active'] as int,
      completed: json['completed'] as int,
      simple: json['simple'] as int,
      checklist: json['checklist'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'completed': completed,
      'simple': simple,
      'checklist': checklist,
    };
  }

  ListsStats copyWith({
    int? total,
    int? active,
    int? completed,
    int? simple,
    int? checklist,
  }) {
    return ListsStats(
      total: total ?? this.total,
      active: active ?? this.active,
      completed: completed ?? this.completed,
      simple: simple ?? this.simple,
      checklist: checklist ?? this.checklist,
    );
  }
}

// Statistiques des items
class ItemsStats {
  final int total;
  final int completed;
  final int pending;
  final double completionRate;

  ItemsStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.completionRate,
  });

  factory ItemsStats.fromJson(Map<String, dynamic> json) {
    return ItemsStats(
      total: json['total'] as int,
      completed: json['completed'] as int,
      pending: json['pending'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'completion_rate': completionRate,
    };
  }

  ItemsStats copyWith({
    int? total,
    int? completed,
    int? pending,
    double? completionRate,
  }) {
    return ItemsStats(
      total: total ?? this.total,
      completed: completed ?? this.completed,
      pending: pending ?? this.pending,
      completionRate: completionRate ?? this.completionRate,
    );
  }
}

// Statistiques de partage
class SharingStats {
  final int listsSharedByMe;
  final int totalSharesSent;
  final int editPermissionsGranted;
  final int readPermissionsGranted;
  final int listsSharedWithMe;
  final int listsICanEdit;

  SharingStats({
    required this.listsSharedByMe,
    required this.totalSharesSent,
    required this.editPermissionsGranted,
    required this.readPermissionsGranted,
    required this.listsSharedWithMe,
    required this.listsICanEdit,
  });

  factory SharingStats.fromJson(Map<String, dynamic> json) {
    return SharingStats(
      listsSharedByMe: json['lists_shared_by_me'] as int,
      totalSharesSent: json['total_shares_sent'] as int,
      editPermissionsGranted: json['edit_permissions_granted'] as int,
      readPermissionsGranted: json['read_permissions_granted'] as int,
      listsSharedWithMe: json['lists_shared_with_me'] as int,
      listsICanEdit: json['lists_i_can_edit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lists_shared_by_me': listsSharedByMe,
      'total_shares_sent': totalSharesSent,
      'edit_permissions_granted': editPermissionsGranted,
      'read_permissions_granted': readPermissionsGranted,
      'lists_shared_with_me': listsSharedWithMe,
      'lists_i_can_edit': listsICanEdit,
    };
  }

  SharingStats copyWith({
    int? listsSharedByMe,
    int? totalSharesSent,
    int? editPermissionsGranted,
    int? readPermissionsGranted,
    int? listsSharedWithMe,
    int? listsICanEdit,
  }) {
    return SharingStats(
      listsSharedByMe: listsSharedByMe ?? this.listsSharedByMe,
      totalSharesSent: totalSharesSent ?? this.totalSharesSent,
      editPermissionsGranted:
          editPermissionsGranted ?? this.editPermissionsGranted,
      readPermissionsGranted:
          readPermissionsGranted ?? this.readPermissionsGranted,
      listsSharedWithMe: listsSharedWithMe ?? this.listsSharedWithMe,
      listsICanEdit: listsICanEdit ?? this.listsICanEdit,
    );
  }
}

// Statistiques temporelles
class TimelineStats {
  final List<DailyStat> daily;
  final List<MonthlyStat> monthly;

  TimelineStats({required this.daily, required this.monthly});

  factory TimelineStats.fromJson(Map<String, dynamic> json) {
    return TimelineStats(
      daily: (json['daily'] as List)
          .map((item) => DailyStat.fromJson(item as Map<String, dynamic>))
          .toList(),
      monthly: (json['monthly'] as List)
          .map((item) => MonthlyStat.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily': daily.map((item) => item.toJson()).toList(),
      'monthly': monthly.map((item) => item.toJson()).toList(),
    };
  }

  TimelineStats copyWith({List<DailyStat>? daily, List<MonthlyStat>? monthly}) {
    return TimelineStats(
      daily: daily ?? this.daily,
      monthly: monthly ?? this.monthly,
    );
  }
}

// Statistique journalière
class DailyStat {
  final DateTime date;
  final int listsCount;
  final int completedCount;

  DailyStat({
    required this.date,
    required this.listsCount,
    required this.completedCount,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: DateTime.parse(json['date'] as String),
      listsCount: json['lists_count'] as int,
      completedCount: json['completed_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T').first,
      'lists_count': listsCount,
      'completed_count': completedCount,
    };
  }

  DailyStat copyWith({DateTime? date, int? listsCount, int? completedCount}) {
    return DailyStat(
      date: date ?? this.date,
      listsCount: listsCount ?? this.listsCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}

// Statistique mensuelle
class MonthlyStat {
  final String month;
  final int listsCount;
  final int completedCount;

  MonthlyStat({
    required this.month,
    required this.listsCount,
    required this.completedCount,
  });

  factory MonthlyStat.fromJson(Map<String, dynamic> json) {
    return MonthlyStat(
      month: json['month'] as String,
      listsCount: json['lists_count'] as int,
      completedCount: json['completed_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'lists_count': listsCount,
      'completed_count': completedCount,
    };
  }

  MonthlyStat copyWith({String? month, int? listsCount, int? completedCount}) {
    return MonthlyStat(
      month: month ?? this.month,
      listsCount: listsCount ?? this.listsCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}

// Résumé des statistiques
class SummaryStats {
  final int totalLists;
  final int totalItems;
  final int totalCompletedItems;
  final double completionRate;
  final int totalShares;

  SummaryStats({
    required this.totalLists,
    required this.totalItems,
    required this.totalCompletedItems,
    required this.completionRate,
    required this.totalShares,
  });

  factory SummaryStats.fromJson(Map<String, dynamic> json) {
    return SummaryStats(
      totalLists: json['total_lists'] as int,
      totalItems: json['total_items'] as int,
      totalCompletedItems: json['total_completed_items'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      totalShares: json['total_shares'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_lists': totalLists,
      'total_items': totalItems,
      'total_completed_items': totalCompletedItems,
      'completion_rate': completionRate,
      'total_shares': totalShares,
    };
  }

  SummaryStats copyWith({
    int? totalLists,
    int? totalItems,
    int? totalCompletedItems,
    double? completionRate,
    int? totalShares,
  }) {
    return SummaryStats(
      totalLists: totalLists ?? this.totalLists,
      totalItems: totalItems ?? this.totalItems,
      totalCompletedItems: totalCompletedItems ?? this.totalCompletedItems,
      completionRate: completionRate ?? this.completionRate,
      totalShares: totalShares ?? this.totalShares,
    );
  }
}
