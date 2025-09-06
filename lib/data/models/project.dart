// File: data/models/project.dart (Enhanced version)
import 'package:flutter/foundation.dart';

enum DataType { numeric, categorical, boolean }

class ColumnConfig {
  final String name;
  final DataType dataType;
  final List<String>? categoryOptions; // For categorical data

  const ColumnConfig({
    required this.name,
    required this.dataType,
    this.categoryOptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dataType': dataType.toString(),
      'categoryOptions': categoryOptions,
    };
  }

  factory ColumnConfig.fromJson(Map<String, dynamic> json) {
    return ColumnConfig(
      name: json['name'],
      dataType: DataType.values.firstWhere(
        (e) => e.toString() == json['dataType'],
        orElse: () => DataType.categorical,
      ),
      categoryOptions: json['categoryOptions']?.cast<String>(),
    );
  }

  ColumnConfig copyWith({
    String? name,
    DataType? dataType,
    List<String>? categoryOptions,
  }) {
    return ColumnConfig(
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      categoryOptions: categoryOptions ?? this.categoryOptions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColumnConfig &&
        other.name == name &&
        other.dataType == dataType &&
        listEquals(other.categoryOptions, categoryOptions);
  }

  @override
  int get hashCode {
    return name.hashCode ^ dataType.hashCode ^ (categoryOptions?.hashCode ?? 0);
  }
}

class Project {
  final String id;
  final String name;
  final List<String> headers;
  final List<List<String>> data;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ColumnConfig> columnConfigs;

  const Project({
    required this.id,
    required this.name,
    required this.headers,
    required this.data,
    required this.createdAt,
    this.updatedAt,
    this.columnConfigs = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'headers': headers,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'columnConfigs': columnConfigs.map((c) => c.toJson()).toList(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      headers: List<String>.from(json['headers']),
      data: List<List<String>>.from(
        json['data'].map((row) => List<String>.from(row)),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      columnConfigs: json['columnConfigs'] != null
          ? List<ColumnConfig>.from(
              json['columnConfigs'].map((c) => ColumnConfig.fromJson(c)),
            )
          : [],
    );
  }

  Project copyWith({
    String? id,
    String? name,
    List<String>? headers,
    List<List<String>>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ColumnConfig>? columnConfigs,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      headers: headers ?? this.headers,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      columnConfigs: columnConfigs ?? this.columnConfigs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.name == name &&
        listEquals(other.headers, headers) &&
        listEquals(other.data, data) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.columnConfigs, columnConfigs);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        headers.hashCode ^
        data.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        columnConfigs.hashCode;
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, headers: $headers, createdAt: $createdAt)';
  }
}
