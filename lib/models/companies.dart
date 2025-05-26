// lib/models/companies.dart
import 'dart:convert';

// Model class with to/from Map and JSON
class Companies {
  int? id;
  String name;

  Companies({
    this.id,
    required this.name,
  });

  // Create a Company from a sqflite Map
  factory Companies.fromMap(Map<String, dynamic> map) => Companies(
    id: map['id'] as int?,
    name: map['name'] as String,
  );
  
  // Convert a Company to a Map for sqflite
  Map<String, dynamic> toMap() =>{
    'id': id,
    'name': name,
  };

  @override
  String toString() => jsonEncode(toMap());
}