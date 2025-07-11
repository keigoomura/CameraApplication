// lib/services/db_provider.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../services/companies_crud.dart';
import '../services/checks_crud.dart';
import '../services/check_invoices_crud.dart';
import '../services/invoices_crud.dart';

// Database provider class
class DBProvider {
  DBProvider._();
  static final DBProvider instance = DBProvider._();
  final CompaniesCrud companies = CompaniesCrud();
  final ChecksCrud checks = ChecksCrud();
  final InvoicesCrud invoices = InvoicesCrud();
  final CheckInvoicesCrud checkInvoices = CheckInvoicesCrud();

  Database? _database;

  // Lazily open the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize and open the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'camera_app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create all tables in the database
  Future _onCreate(Database db, int version) async {
    // Create Companies table
    await db.execute('''
      CREATE TABLE companies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create Checks table
    await db.execute('''
      CREATE TABLE checks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image TEXT NOT NULL,
        number INTEGER NOT NULL,
        companyId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (companyId) REFERENCES companies(id)
      )
    ''');

    // Create Invoices table
    await db.execute('''
      CREATE TABLE invoices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER NOT NULL,
        companyId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (companyId) REFERENCES companies(id)
      )
    ''');

    // Create CheckInvoices tables
    await db.execute('''
      CREATE TABLE checkInvoices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checkId INTEGER NOT NULL,
        invoiceId INTEGER NOT NULL,
        FOREIGN KEY (checkId) REFERENCES checks(id),
        FOREIGN KEY (invoiceId) REFERENCES invoices(id)
      )
    ''');
  }

  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }
}