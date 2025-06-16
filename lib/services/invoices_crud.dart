// lib/services/invoices_crud.dart

import '../models/invoices.dart';
import 'db_provider.dart';

/// CRUD operations for Invoices
class InvoicesCrud {
  
  // Create and insert a new Invoice
  Future<Invoices> createInvoice(Invoices invoice) async {
    final db = await DBProvider.instance.database;
    final id = await db.insert('invoices', invoice.toMap());
    invoice.id = id;
    return invoice;
  }

  // Query all invoices
  Future<List<Invoices>> getAllInvoices() async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      columns: ['id', 'number', 'companyId', 'createdAt'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Invoices.fromMap(map)).toList();
  }

  // Query an invoice by its ID
  Future<Invoices?> getInvoiceById(int id) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      columns: ['id', 'number', 'companyId', 'createdAt'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Invoices.fromMap(result.first);
    }
    return null;
  }

  // Query all invoices for a specific company
  Future<List<Invoices>> getInvoicesByCompany(int companyId) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      columns: ['id', 'number', 'companyId', 'createdAt'],
      orderBy: 'createdAt DESC',
      where: 'companyId = ?',
      whereArgs: [companyId],
    );
    return result.map((map) => Invoices.fromMap(map)).toList();
  }

  // Query invoices by their number
  Future<List<Invoices>> getInvoicesByNumber(int number) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      columns: ['id', 'number', 'companyId', 'createdAt'],
      where: 'number = ?',
      whereArgs: [number],
    );
    return result.map((map) => Invoices.fromMap(map)).toList();
  }

  // Delete an Invoice by its ID
  Future<int> deleteInvoice(int id) async {
    final db = await DBProvider.instance.database;
    return await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}