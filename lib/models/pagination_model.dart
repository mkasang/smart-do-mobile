class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta pagination;

  PaginatedResponse({required this.items, required this.pagination});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      items: (json['lists'] as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total_items': totalItems,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }
}
