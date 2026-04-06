import 'dart:developer';

import 'package:championship/add_team.dart';
import 'package:championship/championship_database.dart';
import 'package:championship/custom_shared_prefs.dart';
import 'package:championship/loading_screen.dart';
import 'package:championship/match_rounds.dart';
import 'package:championship/matches.dart';
import 'package:championship/ranking_table.dart';
import 'package:championship/settings_item.dart';
import 'package:championship/team.dart';
import 'package:championship/team_ranking.dart';
import 'package:championship/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = true;

  final TextEditingController _controllerWin = TextEditingController();
  final TextEditingController _controllerDraw = TextEditingController();

  List<Team> _teamList = [];
  List<MatchRounds> _matchRoundsList = [];

  Future<void> _getWinAndDrawValue() async {
    int winValue = await CustomSharedPrefs.getWinValue() ?? 0;
    _controllerWin.text = winValue.toString();
    int drawValue = await CustomSharedPrefs.getDrawValue() ?? 0;
    _controllerDraw.text = drawValue.toString();
  }

  void _onTapEditMetrics() async {
    await _getWinAndDrawValue();
    if (!mounted) return;

    Navigator.pop(context);

    await showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {
            // Remove o foco do teclado se o usuário tocar fora dos campos
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: AlertDialog(
            // 1. Bordas arredondadas modernas para o Dialog inteiro
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            contentPadding: const EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
              bottom: 0,
            ),
            actionsPadding: const EdgeInsets.all(16),

            // Título
            title: const Text(
              'Editar Métricas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Subtítulo sutil para guiar o usuário
                const Text(
                  'Defina os pontos para cada resultado:',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // 3. Campo de Vitória (Largo, com rótulo e ícone)
                TextField(
                  controller: _controllerWin,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Valor da Vitória',
                    prefixIcon: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Campo de Empate
                TextField(
                  controller: _controllerDraw,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Valor do Empate',
                    prefixIcon: const Icon(
                      Icons.handshake,
                      color: Colors.blueGrey,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Um respiro antes dos botões
              ],
            ),

            // 5. Hierarquia de botões (Secundário vs Principal)
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.grey[600], // Cor discreta
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800], // Cor de destaque do app
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  await CustomSharedPrefs.setWinValue(
                    int.tryParse(_controllerWin.text) ?? 0,
                  );
                  await CustomSharedPrefs.setDrawValue(
                    int.tryParse(_controllerDraw.text) ?? 0,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTeam() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTeam(
          getTeamListDB: _getTeamListDB,
          saveTeamDB: _saveTeamDB,
          deleteTeamDB: _deleteTeamDB,
          deleteAllMatchRoundsDB: _deleteAllMatchRoundsDB,
        ),
      ),
    ).then((_) async {
      await _loadScreen();
    });
  }

  void _onPressedAction() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(5),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 220,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Opções',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SettingsItem(
                onTap: _onTapEditMetrics,
                iconData: Icons.edit,
                text: 'Editar métricas',
              ),
              const SizedBox(height: 5),
              SettingsItem(
                onTap: _addTeam,
                iconData: Icons.add,
                text: 'Adicionar equipe',
              ),
              const SizedBox(height: 5),
              SettingsItem(
                onTap: () {},
                iconData: Icons.edit_square,
                text: 'Alterar resultado da(s) partida(s)',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onGenerateRaffle() async {
    if (_teamList.length > 2) {
      _isLoading = true;
      if (!mounted) return;
      setState(() {});

      List<Team> shuffledTeams = List.from(_teamList)..shuffle();

      if (shuffledTeams.length % 2 != 0) {
        shuffledTeams.add(const Team(id: -1, name: 'Bye'));
      }

      int totalTeams = shuffledTeams.length;
      int totalRounds = totalTeams - 1;
      int matchesPerRound = totalTeams ~/ 2;

      List<MatchRounds> matchRoundsList = [];
      int count = 0;
      for (int round = 0; round < totalRounds; round++) {
        for (int i = 0; i < matchesPerRound; i++) {
          Team homeTeam = shuffledTeams[i];
          Team awayTeam = shuffledTeams[totalTeams - 1 - i];

          if (homeTeam.id != -1 && awayTeam.id != -1) {
            count++;
            log(
              '$count :: Rodada ${round + 1} :: ${homeTeam.name} X ${awayTeam.name}',
            );
            matchRoundsList.add(
              MatchRounds(
                round: round + 1,
                team1: homeTeam.id,
                team2: awayTeam.id,
              ),
            );
          }
        }

        Team lastTeam = shuffledTeams.removeLast();
        shuffledTeams.insert(1, lastTeam);
      }
      log('TOTAL: ${matchRoundsList.length}');

      try {
        await _saveMatchRoundsDB(matchRoundsList);
        _matchRoundsList = await _getMatchRoundsListDB();
        if (!mounted) return;
        setState(() {});
      } catch (e) {
        if (!mounted) return;
        UIUtils.showCustomToast(
          context,
          'Erro ao sortear partidas',
          Colors.white,
          Colors.red,
        );
      }

      _isLoading = false;
      if (!mounted) return;
      setState(() {});
    } else {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Adicione 2 ou mais equipes para sortear',
        Colors.white,
        Colors.blue,
      );
    }
  }

  Widget _getBody() {
    if (_isLoading) {
      return LoadingScreen();
    } else {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RankingTable(
                teamRankingList: _teamList
                    .map(
                      (e) => TeamRanking(team: e, pts: 0),
                    )
                    .toList(),
              ),
              const SizedBox(height: 30),
              Matches(
                onGenerateRaffle: _onGenerateRaffle,
                matchRoundsList: _matchRoundsList,
                teamList: _teamList,
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<List<Team>> _getTeamListDB() async {
    final db = await ChampionshipDatabase.instance.database;

    final result = await db
        .query(
          ChampionshipDatabase.tableTeamName,
          orderBy: 'name ASC',
        )
        .onError(
          (error, stackTrace) {
            throw Exception(error);
          },
        )
        .catchError(
          (error) {
            throw Exception(error);
          },
        );

    List<Team> list = [];
    for (Map<String, Object?> json in result) {
      list.add(Team.fromJson(json));
    }
    return list;
  }

  Future<int> _saveTeamDB(
    String teamNameToSave, {
    Team? team,
  }) async {
    final db = await ChampionshipDatabase.instance.database;
    int result = 0;
    if (team == null) {
      result = await db
          .insert(
            ChampionshipDatabase.tableTeamName,
            {
              'name': teamNameToSave,
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          )
          .onError(
            (error, stackTrace) {
              throw Exception(error);
            },
          )
          .catchError(
            (error) {
              throw Exception(error);
            },
          );
    } else {
      result = await db
          .update(
            ChampionshipDatabase.tableTeamName,
            {
              'name': teamNameToSave,
            },
            where: 'id = ?',
            whereArgs: [team.id],
          )
          .onError(
            (error, stackTrace) {
              throw Exception(error);
            },
          )
          .catchError(
            (error) {
              throw Exception(error);
            },
          );
    }
    return result;
  }

  Future<int> _deleteTeamDB({Team? team}) async {
    int result = 0;
    if (team != null) {
      final db = await ChampionshipDatabase.instance.database;

      result = await db
          .delete(
            ChampionshipDatabase.tableTeamName,
            where: 'id = ?',
            whereArgs: [team.id],
          )
          .onError(
            (error, stackTrace) {
              throw Exception(error);
            },
          )
          .catchError(
            (error) {
              throw Exception(error);
            },
          );
    }
    return result;
  }

  Future<List<MatchRounds>> _getMatchRoundsListDB() async {
    final db = await ChampionshipDatabase.instance.database;

    final result = await db
        .query(
          ChampionshipDatabase.tableMatchRoundsName,
        )
        .onError(
          (error, stackTrace) {
            throw Exception(error);
          },
        )
        .catchError(
          (error) {
            throw Exception(error);
          },
        );

    List<MatchRounds> list = [];
    for (Map<String, Object?> json in result) {
      list.add(MatchRounds.fromJson(json));
    }
    return list;
  }

  Future<void> _saveMatchRoundsDB(List<MatchRounds> matchRoundsList) async {
    final db = await ChampionshipDatabase.instance.database;
    Batch batch = db.batch();

    for (MatchRounds matchRounds in matchRoundsList) {
      if (matchRounds.id == null) {
        batch.insert(
          ChampionshipDatabase.tableMatchRoundsName,
          matchRounds.toJson(),
        );
      } else {
        batch.update(
          ChampionshipDatabase.tableMatchRoundsName,
          matchRounds.toJson(),
          where: 'id = ?',
          whereArgs: [matchRounds.id],
        );
      }
    }

    await batch
        .commit()
        .onError(
          (error, stackTrace) {
            throw Exception(error);
          },
        )
        .catchError(
          (error) {
            throw Exception(error);
          },
        );
  }

  Future<int> _deleteAllMatchRoundsDB() async {
    final db = await ChampionshipDatabase.instance.database;
    return db.delete(ChampionshipDatabase.tableMatchRoundsName);
  }

  Future<void> _loadScreen() async {
    _isLoading = true;
    if (!mounted) return;
    setState(() {});

    try {
      _teamList = await _getTeamListDB();
      _matchRoundsList = await _getMatchRoundsListDB();
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao carregar lista de equipe',
        Colors.white,
        Colors.red,
      );
    }

    _isLoading = false;
    if (!mounted) return;
    setState(() {});
  }

  void _init() async {
    await _loadScreen();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Championship',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _onPressedAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Icon(Icons.more_vert, size: 30),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _getBody(),
    );
  }
}
