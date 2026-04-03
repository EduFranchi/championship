import 'dart:developer';

import 'package:championship/add_team.dart';
import 'package:championship/championship_database.dart';
import 'package:championship/custom_shared_prefs.dart';
import 'package:championship/loading_screen.dart';
import 'package:championship/match.dart';
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
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: AlertDialog(
            title: const Text(
              'Editar métricas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: double.infinity,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Valor vitória: ',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 10.5),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllerWin,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(5),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'Valor empate: ',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllerDraw,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(5),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
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
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
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
          onPressedSaveTeam: _onPressedSaveTeam,
        ),
      ),
    ).then((_) {
      //reload
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

  void _raffle() {
    // 1. Error prevention: Needs at least 2 teams to have a championship
    if (_teamList.length > 2) {
      // 2. Make a copy of the list and shuffle it to ensure randomness
      List<Team> shuffledTeams = List.from(_teamList)..shuffle();

      // 3. The algorithm requires an EVEN number of teams.
      // If it's odd, we add a "Bye" team (rest/folga).
      if (shuffledTeams.length % 2 != 0) {
        shuffledTeams.add(const Team(id: -1, name: 'Bye'));
      }

      int totalTeams = shuffledTeams.length;
      int totalRounds = totalTeams - 1;
      int matchesPerRound = totalTeams ~/ 2;

      List<MatchRounds> matches = [];
      int count = 0;
      // 4. Round-Robin logic
      for (int round = 0; round < totalRounds; round++) {
        for (int i = 0; i < matchesPerRound; i++) {
          Team homeTeam = shuffledTeams[i]; // Mandante
          Team awayTeam = shuffledTeams[totalTeams - 1 - i]; // Visitante

          // If neither team is the "Bye" team, we create the match
          if (homeTeam.id != -1 && awayTeam.id != -1) {
            count++;
            log('$count :: ${homeTeam.name} X ${awayTeam.name}');
            matches.add(
              MatchRounds(
                round: round + 1, // Rounds start at 1
                team1: homeTeam.id,
                team2: awayTeam.id,
              ),
            );
          }
        }

        // 5. Rotate the teams (except the first one, which stays fixed at index 0)
        Team lastTeam = shuffledTeams.removeLast();
        shuffledTeams.insert(1, lastTeam);
      }
      log('TOTAL: ${matches.length}');
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
              ElevatedButton(
                onPressed: _raffle,
                child: Text('Sortear'),
              ),
              const SizedBox(height: 30),
              Matches(),
            ],
          ),
        ),
      );
    }
  }

  Future<List<Team>> _getTeamListDB() async {
    final db = await ChampionshipDatabase.instance.database;

    final result = await db.query(
      ChampionshipDatabase.tableTeamName,
      orderBy: 'name ASC',
    );

    List<Team> list = [];
    for (Map<String, Object?> json in result) {
      list.add(Team.fromJson(json));
    }
    return list;
  }

  Future<int> _onPressedSaveTeam(
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
      result = await db.update(
        ChampionshipDatabase.tableTeamName,
        {
          'name': teamNameToSave,
        },
        where: 'id = ?',
        whereArgs: [team.id],
      );
    }
    return result;
  }

  Future<void> _loadScreen() async {
    _isLoading = true;
    if (!mounted) return;
    setState(() {});

    try {
      _teamList = await _getTeamListDB();
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
