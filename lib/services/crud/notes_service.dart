import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'crud_exceptions.dart';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const contentColumn = 'content';

const userTable = 'user';
const noteTable = 'note';

const dbName = 'notes.db';

const createUserTable = '''
  CREATE TABLE IF NOT EXISTS "user" (
    "id"	INTEGER NOT NULL,
    "email"	TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
''';
      
const createNoteTable = '''
  CREATE TABLE IF NOT EXISTS "note" (
    "id"	INTEGER NOT NULL,
    "user_id"	INTEGER NOT NULL,
    "content"	TEXT,
    FOREIGN KEY("user_id") REFERENCES "user"("id"),
    PRIMARY KEY("id" AUTOINCREMENT)
  );
  ''';

class NoteService {
  Database? _db;
  Database _getDatabaseThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  // USER CRUD
  Future<DBUser> createUser({required String email}) async {
    final db = _getDatabaseThrow();
    final results = await db.query(
      userTable, 
      limit: 1, 
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()]
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DBUser(id: userId, email: email);
  }

  Future<DBUser> getUser({required String email}) async {
    final db = _getDatabaseThrow();
    final results = await db.query(
      userTable, 
      limit: 1, 
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()]
    );
    if (results.isNotEmpty) {
      throw CouldNotFindUser();
    } else {
      return DBUser.fromRow(results.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseThrow();
    final deleteAccount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteAccount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  // NOTE CRUD
  Future<DBNote> createNote({required DBUser user}) async {
    final db = _getDatabaseThrow();
    // Make sure the user exists
    final dbUser = await getUser(email: user.email);
    if (dbUser != user) {
      throw CouldNotFindUser();
    }

    const content = '';
    //create note
    final noteId = await db.insert(noteTable, {
      userIdColumn: user.id,
      content: content,
    });

    return DBNote(id: noteId, userId: user.id, content: content);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseThrow();
    return await db.delete(noteTable);
  }

  Future<DBNote> getNote({required int id}) async {
    final db = _getDatabaseThrow();
    final results = await db.query(
      noteTable, 
      limit: 1, 
      where: 'id = ?', 
      whereArgs: [id]
    );
    if (results.isNotEmpty) {
      throw CouldNotFindNote();
    } else {
      return DBNote.fromRow(results.first);
    }
  }

  Future<Iterable<DBNote>> getAllNotes() async {
    final db = _getDatabaseThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DBNote.fromRow(noteRow));
  }

  Future<DBNote> updateNote({
    required DBNote note,
    required String content
  }) async {
    final db = _getDatabaseThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(noteTable, {
      contentColumn: content,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create users table
      await db.execute(createUserTable);
      // create notes table
      await db.execute(createNoteTable);

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

class DBUser {
  final int id;
  final String email;
  const DBUser({
    required this.id,
    required this.email
  });

  DBUser.fromRow(Map<String, Object?> map) : 
    id = map[idColumn] as int, 
    email = map[emailColumn] as String;
  
  @override
  String toString() => 'Person: id = $id, email = $email';

  @override
  bool operator==(covariant DBUser other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

class DBNote {
  final int id;
  final int userId;
  final String content;
  const DBNote({
    required this.id,
    required this.userId,
    required this.content,
  });

  DBNote.fromRow(Map<String, Object?> map) : 
  id = map[idColumn] as int, 
  userId = map[userIdColumn] as int, 
  content = map[contentColumn] as String;
  
  @override
  String toString() => 'Note: id = $id, userId = $userId';

  @override
  bool operator==(covariant DBNote other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}