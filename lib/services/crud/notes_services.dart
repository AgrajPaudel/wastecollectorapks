/*
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'crud_exceptions.dart';
import 'package:notetaker/extensions/list/filter.dart';

class Notesservice {
  //opening database needs to be asynchronous as it occurs after an event.
  Database? _db; //creates database

  DatabaseUser? _user;
  List<DatabaseNotes> _notes = [];
  Database? user;
  static final Notesservice _shared = Notesservice._sharedinstances();
  Notesservice._sharedinstances() {
    _streamcontroller = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _streamcontroller.sink.add(_notes);
      },
    );
  }
  factory Notesservice() => _shared;

  late final StreamController<List<DatabaseNotes>> _streamcontroller;
  Stream<List<DatabaseNotes>> get aallnotes =>
      _streamcontroller.stream.filter((note) {
        final currentuser = _user;
        if (currentuser != null) {
          return note.userId ==
              currentuser.id; //checks if id same, then returns
        } else {
          throw Usershouldbesetbeforereadingnotes();
        }
      }); //actual filtering.

  Future<DatabaseUser> GetorcreateUser({
    required String email,
    bool Setascurrentuser = true,
  }) async {
    try {
      print('create user');
      final user = await findUser(email: email);
      if (Setascurrentuser) {
        _user = user;
      }
      return user;
    } on UserdoesnotExist {
      final createduser = await CreateUser(email: email);
      if (Setascurrentuser) {
        _user = createduser;
      }
      return createduser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cachenotes() async {
    print('note cache');
    final aallnotes = await allnotes();
    _notes = aallnotes.toList();
    _streamcontroller.add(_notes);
    print(_notes); //from here notes is collected.
    print('1');
  }

  Future<DatabaseNotes> UpdateNotes({
    required DatabaseNotes notes,
    required String text,
  }) async {
    print('update notes');
    await Ensuredbisopen();
    final _db = _GetDatabaseorThrow();
    await getNote(id: notes.id); //it should exist

    final updatecount = await _db.update(
      notestable,
      {
        textcolumn: text,
        Syncwithcloudcolumn: 0,
      },
      where:
          'Id = ?', //shows where to update, else updates all the notes as per last entry.
      whereArgs: [notes.id],
    );
    if (updatecount == 0) {
      throw couldnotupdatenotes();
    } else {
      final updatednote = await getNote(id: notes.id);
      _notes.removeWhere((note) => note.id == updatednote.id);
      _notes.add(updatednote);
      _streamcontroller.add(_notes);
      return updatednote;
    }
  }

  Future<Iterable<DatabaseNotes>> allnotes() async {
    await Ensuredbisopen();
    print('all notes here');
    final _db = _GetDatabaseorThrow();
    final notes = await _db.query(
      notestable,
    );

    return notes.map((notesrow) => DatabaseNotes.fromRow(notesrow));
  }

  Future<DatabaseNotes> CreateNotes({
    required DatabaseUser owner,
  }) async {
    print('note created');
    await Ensuredbisopen();
    final _db = _GetDatabaseorThrow();
    final dbUser = await findUser(email: owner.email);
    if (dbUser != owner) {
      throw UserdoesnotExist();
    }
    const text = '';
    final notesid = await _db.insert(notestable, {
      userIdcolumn: owner.id,
      textcolumn: text,
      Syncwithcloudcolumn: 1,
    });

    final notes = DatabaseNotes(
      id: notesid,
      userId: owner.id,
      text: text,
      Syncwithcloud: true,
    );
    _notes.add(notes);
    _streamcontroller.add(_notes);
    return notes;
  }

  Future<void> deleteNotes({required int id}) async {
    print('note deleted');
    await Ensuredbisopen();
    final _db = _GetDatabaseorThrow();
    final deletenote = await _db.delete(
      notestable,
      where: 'Id=?',
      whereArgs: [id],
    );

    if (deletenote != 1) {
      throw couldnotdeletenote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _streamcontroller.add(_notes);
    }
  }

  Future<DatabaseUser> findUser({required String email}) async {
    print('found user');
    await Ensuredbisopen();
    final db = _GetDatabaseorThrow();
    final result = await db.query(
      usertable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      print('usr thrown');
      throw UserdoesnotExist();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<int> deletesallnotes() async {
    print('notes go poof');
    await Ensuredbisopen();
    final _db = _GetDatabaseorThrow();
    final deletion_number = await _db.delete(notestable);
    _notes = [];
    _streamcontroller.add(_notes);
    return deletion_number;
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await Ensuredbisopen();
    print('note caught');
    final _db = _GetDatabaseorThrow();
    final notes = await _db.query(
      notestable,
      limit: 1,
      where: 'Id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw couldnotfindnotes();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _streamcontroller.add(_notes);
      return note;
    }
  }

  Future<DatabaseUser> CreateUser({required String email}) async {
    await Ensuredbisopen();
    print('create user');
    final _db = _GetDatabaseorThrow();
    final result = await _db.query(
      usertable,
      limit: 1,
      where: 'email=?', //not nullable so it works
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserExists();
    }
    final userid = await _db.insert(usertable, {
      emailcolumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userid,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await Ensuredbisopen();
    print('poof user');
    final _db = _GetDatabaseorThrow();
    final deleteaccount = await _db.delete(
      usertable,
      where: 'email=?', //not nullable so it works
      whereArgs: [email.toLowerCase()],
    );

    if (deleteaccount != 1) {
      throw CouldnotdeleteAccount();
    }
  }

  Database _GetDatabaseorThrow() {
    final db = _db;
    if (db == null) {
      throw Databasenotopen();
    } else
      return db;
  }

  Future<void> close() async {
    print('close');
    final db = _db;
    if (db == null) {
      throw Databasenotopen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> Ensuredbisopen() async {
    try {
      print('open user');
      //for not opening over and over in hot reload
      await open();
    } on Databasealreadyopenexception {}
  }

  Future<void> open() async {
    print('open');
    if (_db != null) {
      throw Databasealreadyopenexception();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbpath = join(docsPath.path, dbname);
      final db = await openDatabase(dbpath);
      _db = db;

      await db.execute(createUsertable);
      await db.execute(CreateNotesTable);
      await _cachenotes();
    } on MissingPlatformDirectoryException {
      print('wait user');
      throw unabletogetdocumentsdirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(
      Map<String, Object?> map) //we only read database as hashtables
      : id = map[idcolumn] as int,
        email = map[emailcolumn] as String;

  @override
  String toString() =>
      'Person, Id = $id , $email'; //otherwise o/p comes only in console

  @override
  bool operator ==(covariant DatabaseUser other) =>
      id == other.id; //compares only database user instances

  @override
  int get hashCode => id.hashCode; //primary key hashing itself
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool Syncwithcloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.Syncwithcloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idcolumn] as int,
        userId = map[userIdcolumn] as int,
        text = map[textcolumn] as String,
        Syncwithcloud = (map[Syncwithcloudcolumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      ' Note, ID= $id, userId= $userId, Syncwithcloud= $Syncwithcloud , text= $text ';

  @override
  bool operator ==(covariant DatabaseNotes other) =>
      id == other.id; //compares only database user instances

  @override
  int get hashCode => id.hashCode;
}

const dbname = 'database2.db';
const notestable = 'notes';
const usertable = 'user';
const idcolumn = 'Id';
const emailcolumn = 'email';
const userIdcolumn = 'user_Id';
const textcolumn = 'text';
const Syncwithcloudcolumn = 'sync_with_cloud';
const createUsertable = '''
        CREATE TABLE IF NOT EXISTS "user" (
	"Id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
        ''';
const CreateNotesTable = '''
      CREATE TABLE IF NOT EXISTS "notes" (
	"Id"	INTEGER NOT NULL,
	"user_Id"	INTEGER NOT NULL,
	"text"	TEXT,
	"sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_Id") REFERENCES "user"("Id"),
	PRIMARY KEY("Id" AUTOINCREMENT)
);
      ''';

*/