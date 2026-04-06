import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChampionshipDatabase {
  // Cria a instância única (Singleton) da classe
  static final ChampionshipDatabase instance = ChampionshipDatabase._init();
  static Database? _database;
  static String tableTeamName = 'team';
  static String tableMatchRoundsName = 'match_rounds';

  ChampionshipDatabase._init();

  // Método para acessar o banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Se não existir, inicializa o banco
    _database = await _initDB('championship.db');
    return _database!;
  }

  // Inicializa a conexão com o arquivo do banco de dados
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // O SQLite, por padrão, vem com as Foreign Keys desativadas.
  // Precisamos ativá-las explicitamente.
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Método onde executamos o SQL para criar as tabelas
  static Future _createDB(Database db, int version) async {
    // 1. Criando a tabela 'team'
    await db.execute('''
      CREATE TABLE $tableTeamName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // 2. Criando a tabela 'match'
    // Obs: Em SQL, não usamos camelCase como no Dart,
    // mas mantive 'team1Pts' e 'team2Pts' como você pediu para manter a compatibilidade.
    await db.execute('''
      CREATE TABLE $tableMatchRoundsName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        round INTEGER NOT NULL,
        team1 INTEGER NOT NULL,
        team2 INTEGER NOT NULL,
        team1Pts INTEGER,
        team2Pts INTEGER,
        FOREIGN KEY (team1) REFERENCES team (id) ON DELETE CASCADE,
        FOREIGN KEY (team2) REFERENCES team (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await dropAllTables(db, newVersion: newVersion);
  }

  static Future dropAllTables(Database db, {int? newVersion}) async {
    // Apaga a tabela de partidas primeiro, pois ela depende da tabela de times
    await db.execute('DROP TABLE IF EXISTS $tableMatchRoundsName');

    // Apaga a tabela de times
    await db.execute('DROP TABLE IF EXISTS $tableTeamName');

    int version = newVersion ?? await db.getVersion();
    // Chama o método de criação para reconstruir as tabelas com a estrutura nova
    await _createDB(db, version);
  }

  // Fecha a conexão com o banco (geralmente usado quando o app é fechado)
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
