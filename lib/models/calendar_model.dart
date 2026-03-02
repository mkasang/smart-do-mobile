import 'package:smart_do/models/list_model.dart';

class CalendarData {
  final DateTime date;
  final CalendarStats stats;
  final List<CalendarList> lists;
  final Map<String, List<CalendarList>> groupedByHour;

  CalendarData({
    required this.date,
    required this.stats,
    required this.lists,
    required this.groupedByHour,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    final groupedByHourJson = json['grouped_by_hour'] as Map<String, dynamic>;

    return CalendarData(
      date: DateTime.parse(json['date'] as String),
      stats: CalendarStats.fromJson(json['stats'] as Map<String, dynamic>),
      lists: (json['lists'] as List)
          .map((item) => CalendarList.fromJson(item as Map<String, dynamic>))
          .toList(),
      groupedByHour: groupedByHourJson.map(
        (key, value) => MapEntry(
          key,
          (value as List)
              .map(
                (item) => CalendarList.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T').first,
      'stats': stats.toJson(),
      'lists': lists.map((item) => item.toJson()).toList(),
      'grouped_by_hour': groupedByHour.map(
        (key, value) =>
            MapEntry(key, value.map((item) => item.toJson()).toList()),
      ),
    };
  }
}

class CalendarStats {
  final int totalLists;
  final int personalLists;
  final int sharedLists;
  final int completedLists;
  final int activeLists;

  CalendarStats({
    required this.totalLists,
    required this.personalLists,
    required this.sharedLists,
    required this.completedLists,
    required this.activeLists,
  });

  factory CalendarStats.fromJson(Map<String, dynamic> json) {
    return CalendarStats(
      totalLists: json['total_lists'] as int,
      personalLists: json['personal_lists'] as int,
      sharedLists: json['shared_lists'] as int,
      completedLists: json['completed_lists'] as int,
      activeLists: json['active_lists'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_lists': totalLists,
      'personal_lists': personalLists,
      'shared_lists': sharedLists,
      'completed_lists': completedLists,
      'active_lists': activeLists,
    };
  }
}

class CalendarList {
  final int id;
  final String title;
  final String type;
  final String status;
  final String? dueTime;
  final String source;
  final String? permission;
  final String? ownerName;
  final int totalItems;
  final int completedItems;

  CalendarList({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.dueTime,
    required this.source,
    this.permission,
    this.ownerName,
    required this.totalItems,
    required this.completedItems,
  });

  factory CalendarList.fromJson(Map<String, dynamic> json) {
    return CalendarList(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      dueTime: json['due_time'] as String?,
      source: json['source'] as String,
      permission: json['permission'] as String?,
      ownerName: json['owner_name'] as String?,
      totalItems: json['total_items'] as int,
      completedItems: json['completed_items'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'status': status,
      'due_time': dueTime,
      'source': source,
      'permission': permission,
      'owner_name': ownerName,
      'total_items': totalItems,
      'completed_items': completedItems,
    };
  }

  bool get isPersonal => source == 'personal';
  bool get isShared => source == 'shared';
  bool get canEdit => permission == 'edit';

  double get progress {
    if (totalItems == 0) return 0;
    return completedItems / totalItems;
  }
}
