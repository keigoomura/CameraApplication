// lib/models/check_invoices.dart
import 'dart:convert';

// Model class with to/from Map and JSON
class CheckInvoices {
  int? id;
  int checkId;
  int invoiceId;

  CheckInvoices({
    this.id,
    required this.checkId,
    required this.invoiceId,
  });

  // Create a CheckInvoice from a sqflite Map
  factory CheckInvoices.fromMap(Map<String, dynamic> map) => CheckInvoices(
    id: map['id'] as int?,
    checkId: map['checkId'] as int,
    invoiceId: map['invoiceId'] as int,
  );
  
  // Convert a CheckInvoice to a Map for sqflite
  Map<String, dynamic> toMap() =>{
    'id': id,
    'checkId': checkId,
    'invoiceId': invoiceId,
  };

  @override
  String toString() => jsonEncode(toMap());
}