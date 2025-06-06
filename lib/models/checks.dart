// lib/models/checks.dart
import 'dart:convert';

// Model class with to/from Map and JSON
class Checks {
  int? id;
  String image;
  int number;
  int companyId;
  DateTime createdAt;

  Checks({
    this.id,
    required this.image,
    required this.number,
    required this.companyId,
    required this.createdAt,
  });

  // Create a Check from a sqflite Map
  factory Checks.fromMap(Map<String, dynamic> map) => Checks(
    id: map['id'] as int?,
    image: map['image'] as String,
    number: map['number'] as int,
    companyId: map['companyId'] as int,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
  
  // Convert a User to a Map for sqflite
  Map<String, dynamic> toMap() =>{
    'id': id,
    'image': image,
    'number': number,
    'companyId': companyId,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => jsonEncode(toMap());
}