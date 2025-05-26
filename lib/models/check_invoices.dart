// lib/models/check_invoices.dart
import 'dart:convert';

// Model class with to/from Map and JSON
class CheckInvoices {
  int checkId;
  int invoiceId;

  CheckInvoices({
    required this.checkId,
    required this.invoiceId,
  });

  // Create a CheckInvoice from a sqflite Map
  factory CheckInvoices.fromMap(Map<String, dynamic> map) => CheckInvoices(
    checkId: map['check_id'] as int,
    invoiceId: map['invoice_id'] as int,
  );
  
  // Convert a CheckInvoice to a Map for sqflite
  Map<String, dynamic> toMap() =>{
    'check_id': checkId,
    'invoice_id': invoiceId,
  };

  @override
  String toString() => jsonEncode(toMap());
}