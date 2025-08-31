class Project {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> headers;
  final List<List<String>> data;

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.headers,
    required this.data,
  });

  Project copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? headers,
    List<List<String>>? data,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      headers: headers ?? this.headers,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'headers': headers,
      'data': data,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      headers: List<String>.from(json['headers']),
      data: List<List<String>>.from(
        json['data'].map((row) => List<String>.from(row)),
      ),
    );
  }
}
