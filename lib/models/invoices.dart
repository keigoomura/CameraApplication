// lib/models/invoices.dart
import 'dart:convert';

// Model class with to/from Map and JSON
class Invoices {
  int? id;
  int number;
  int companyId;
  DateTime createdAt;

  Invoices({
    this.id,
    required this.number,
    required this.companyId,
    required this.createdAt,
  });

  // Create an Invoice from a sqflite Map
  factory Invoices.fromMap(Map<String, dynamic> map) => Invoices(
    id: map['id'] as int?,
    number: map['number'] as int,
    companyId: map['companyId'] as int,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
  
  // Convert an Invoice to a Map for sqflite
  Map<String, dynamic> toMap() =>{
    'id': id,
    'number': number,
    'companyId': companyId,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => jsonEncode(toMap());
}