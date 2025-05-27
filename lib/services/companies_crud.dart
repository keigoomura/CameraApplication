import 'package:sqflite/sqflite.dart';
import '../models/companies.dart';
import 'db_provider.dart';

// CRUD operations for Checks
class CompaniesCrud {
  
  // Create and insert a new Company
  Future<Companies> createCompany(Companies company) async {
    final db = await DBProvider.instance.database;
    final id = await db.insert('companies', company.toMap());
    company.id = id;
    return company;
  }

  // Query a company by its ID
  Future<Companies?> getCompanyById(int id) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'companies',
      columns: ['id', 'name'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Companies.fromMap(result.first);
    }
    return null;
  }

  // Query a company by its name
  Future<Companies?> getCompanyByName(String name) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'companies',
      columns: ['id', 'name'],
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return Companies.fromMap(result.first);
    }
    return null;
  }

  // Delete a Company by its ID
  Future<int> deleteCompany(int id) async {
    final db = await DBProvider.instance.database;
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}