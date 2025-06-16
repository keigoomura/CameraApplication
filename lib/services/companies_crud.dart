// lib/services/companies_crud.dart

import '../models/companies.dart';
import 'db_provider.dart';

// CRUD operations for Companies
class CompaniesCrud {
  
  // Create and insert a new Company
  Future<Companies> createCompany(Companies company) async {
    final db = await DBProvider.instance.database;

    // Check if the company already exists, if it does, return the existing ID
    final existingCompany = await getCompanyByName(company.name);
    if (existingCompany != null) {
      company.id = existingCompany.id;
      return company;
    }
    else{
      final id = await db.insert('companies', company.toMap());
      company.id = id;
      return company;
    }
  }

  // Query all companies
  Future<List<Companies>> getAllCompanies() async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'companies',
      columns: ['id', 'name'],
      orderBy: 'name ASC',
    );
    return result.map((map) => Companies.fromMap(map)).toList();
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