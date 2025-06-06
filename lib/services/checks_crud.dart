import '../models/checks.dart';
import 'db_provider.dart';

class ChecksCrud {

  // Create and insert a new Check
  Future<Checks> createCheck(Checks check) async {
    final db = await DBProvider.instance.database;
    final id = await db.insert('checks', check.toMap());
    check.id = id;
    return check;
  }

  // Query all checks
  Future<List<Checks>> getAllChecks() async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'checks',
      columns: ['id', 'image', 'number', 'companyId', 'createdAt'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Checks.fromMap(map)).toList();
  }

  // Query checks by their ID
  Future<Checks?> getCheckById(int id) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'checks',
      columns: ['id', 'image', 'number', 'companyId', 'createdAt'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Checks.fromMap(result.first);
    }
    return null;
  }

  // Query all checks for a specific company
  Future<List<Checks>> getChecksByCompany(int companyId) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'checks',
      columns: ['id', 'image', 'number', 'companyId', 'createdAt'],
      orderBy: 'createdAt DESC',
      where: 'companyId = ?',
      whereArgs: [companyId],
    );
    return result.map((map) => Checks.fromMap(map)).toList();
  }

  // Query checks by invoice number
  Future<List<Checks>> getChecksByNumber(int number) async {
    final db = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'checks',
      columns: ['id', 'image', 'number', 'companyId', 'createdAt'],
      where: 'number = ?',
      whereArgs: [number],
    );
    return result.map((map) => Checks.fromMap(map)).toList();
  }

  // Delete a Check by its ID
  Future<int> deleteCheck(int id) async {
    final db = await DBProvider.instance.database;
    return await db.delete(
      'checks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}