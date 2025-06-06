import '../models/check_invoices.dart';
import 'db_provider.dart';

// CRUD operations for CheckInvoices
class CheckInvoicesCrud {
  
  // Create and insert a new CheckInvoice
  Future<CheckInvoices> createCheckInvoice(CheckInvoices checkInvoice) async {
    final db = await DBProvider.instance.database;
    final id = await db.insert('checkInvoices', checkInvoice.toMap());
    checkInvoice.id = id;
    return checkInvoice;
  }

  // Query all CheckInvoices
  Future<List<CheckInvoices>> getAllCheckInvoices() async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'checkInvoices',
      columns: ['id', 'checkId', 'invoiceId'],
      orderBy: 'id DESC',
    );
    return result.map((map) => CheckInvoices.fromMap(map)).toList();
  }

  // Query all invoices linked to a specific check
  Future<List<CheckInvoices>> getCheckInvoicesByCheck(int checkId) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'checkInvoices',
      columns: ['id', 'checkId', 'invoiceId'],
      where: 'checkId = ?',
      whereArgs: [checkId],
    );
    return result.map((map) => CheckInvoices.fromMap(map)).toList();
  }

  // Query all checks linked to a specific invoice
  Future<List<CheckInvoices>> getCheckInvoicesByInvoice(int invoiceId) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'checkInvoices',
      columns: ['id', 'checkId', 'invoiceId'],
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
    return result.map((map) => CheckInvoices.fromMap(map)).toList();
  }

  // Delete a CheckInvoice by its ID
  Future<int> deleteCheckInvoice(int checkId, int invoiceId) async {
    final db = await DBProvider.instance.database;
    return await db.delete(
      'checkInvoices',
      where: 'checkId = ? AND invoiceId = ?',
      whereArgs: [checkId, invoiceId],
    );
  }
}