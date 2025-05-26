// lib/models/invoices.dart
import 'dart:convert';

// Model class with to/from Map and JSON
class Invoices {
  int? id;
  int number;
  int companyId;

  Invoices({
    this.id,
    required this.number,
    required this.companyId,
  });

  // Create an Invoice from a sqflite Map
  factory Invoices.fromMap(Map<String, dynamic> map) => Invoices(
    id: map['id'] as int?,
    number: map['number'] as int,
    companyId: map['company_id'] as int,
  );
  
  // Convert an Invoice to a Map for sqflite
  Map<String, dynamic> toMap() =>{
    'id': id,
    'number': number,
    'company_id': companyId,
  };

  @override
  String toString() => jsonEncode(toMap());
}