import 'dart:developer';

import 'package:championship/add_team.dart';
import 'package:championship/championship_database.dart';
import 'package:championship/custom_shared_prefs.dart';
import 'package:championship/edit_match_results.dart';
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

  // NOVO: Lista responsável por armazenar a classificação ordenada
  List<TeamRanking> _teamRankingList = [];

  Future<void> _getWinAndDrawValue() async {
    int winValue = await CustomSharedPrefs.getWinValue() ?? 0;
    _controllerWin.text = winValue.toString();
    int drawValue = await CustomSharedPrefs.getDrawValue() ?? 0;
    _controllerDraw.text = drawValue.toString();
  }

  // --- NOVA FUNÇÃO DE CÁLCULO ---
  Future<void> _calculateRanking() async {
    int winValue = await CustomSharedPrefs.getWinValue() ?? 0;
    int drawValue = await CustomSharedPrefs.getDrawValue() ?? 0;

    Map<int, int> teamPoints = {};
    Map<int, int> teamMatchesPlayed = {};

    // 1. Zera a pontuação e os jogos de todos os times
    for (var team in _teamList) {
      if (team.id != null) {
        teamPoints[team.id!] = 0;
        teamMatchesPlayed[team.id!] = 0;
      }
    }

    // 2. Analisa os resultados das partidas
    for (var match in _matchRoundsList) {
      if (match.team1Pts != null &&
          match.team2Pts != null &&
          match.team1 != null &&
          match.team2 != null) {
        int t1 = match.team1!;
        int t2 = match.team2!;

        // Incrementa um jogo jogado para ambos
        teamMatchesPlayed[t1] = (teamMatchesPlayed[t1] ?? 0) + 1;
        teamMatchesPlayed[t2] = (teamMatchesPlayed[t2] ?? 0) + 1;

        // Calcula a pontuação baseada na vitória ou empate
        if (match.team1Pts! > match.team2Pts!) {
          teamPoints[t1] = (teamPoints[t1] ?? 0) + winValue;
        } else if (match.team2Pts! > match.team1Pts!) {
          teamPoints[t2] = (teamPoints[t2] ?? 0) + winValue;
        } else {
          // Empate
          teamPoints[t1] = (teamPoints[t1] ?? 0) + drawValue;
          teamPoints[t2] = (teamPoints[t2] ?? 0) + drawValue;
        }
      }
    }

    // 3. Converte os mapas para a nossa Lista de TeamRanking
    _teamRankingList = _teamList.map((team) {
      return TeamRanking(
        team: team,
        pts: teamPoints[team.id] ?? 0,
        matchesPlayed: teamMatchesPlayed[team.id] ?? 0,
      );
    }).toList();

    // 4. ORDENAÇÃO: 1º Quem tem mais pontos, 2º Ordem Alfabética (se empatar em pontos)
    _teamRankingList.sort((a, b) {
      int ptsComparison = b.pts.compareTo(a.pts);
      if (ptsComparison != 0) {
        return ptsComparison;
      }
      return (a.team.name ?? '').compareTo(b.team.name ?? '');
    });
  }
  // ---------------------------------

  void _onTapEditMetrics() async {
    await _getWinAndDrawValue();
    if (!mounted) return;

    Navigator.pop(context);

    await showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: AlertDialog(
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
                const Text(
                  'Defina os pontos para cada resultado:',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 8),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
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

                  // NOVO: Recalcula a tabela imediatamente quando salvar novos valores de pontos!
                  await _calculateRanking();
                  setState(() {});
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

  // --- MANTENHA AS FUNÇÕES: _onTapAddTeam, _onTapEditMatchResults, _onShowOptionsBottomSheet, _onGenerateRaffle AQUI ---
  // (Elas são as mesmas que você me mandou)
  void _onTapAddTeam() {
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

  void _onTapEditMatchResults() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMatchResults(
          getMatchRoundsDB: _getMatchRoundsListDB,
          getTeamListDB: _getTeamListDB,
          saveMatchRoundsListDB: _saveMatchRoundsDB,
        ),
      ),
    ).then((_) async {
      await _loadScreen(); // O _loadScreen também recalcula a tabela agora!
    });
  }

  void _onShowOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 24,
              top: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Opções',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SettingsItem(
                  onTap: _onTapEditMetrics,
                  iconData: Icons.edit,
                  text: 'Editar métricas',
                ),
                const SizedBox(height: 12),
                SettingsItem(
                  onTap: _onTapAddTeam,
                  iconData: Icons.add,
                  text: 'Adicionar equipe',
                ),
                const SizedBox(height: 12),
                SettingsItem(
                  onTap: _onTapEditMatchResults,
                  iconData: Icons.edit_square,
                  text: 'Alterar resultado da(s) partida(s)',
                ),
              ],
            ),
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

        // NOVO: Quando um sorteio for gerado, recalcula a tabela (todos com 0 pontos)
        await _calculateRanking();

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
      return const LoadingScreen();
    } else {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RankingTable(
                // NOVO: Passamos a nossa lista ordenada em vez daquele map fake que existia antes!
                teamRankingList: _teamRankingList,
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

  // --- MANTENHA AS FUNÇÕES DE BANCO DE DADOS (GET, SAVE, DELETE) AQUI ---
  // (_getTeamListDB, _saveTeamDB, _deleteTeamDB, _getMatchRoundsListDB, _saveMatchRoundsDB, _deleteAllMatchRoundsDB)

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

  Future<int> _saveTeamDB(String teamNameToSave, {Team? team}) async {
    final db = await ChampionshipDatabase.instance.database;
    int result = 0;
    if (team == null) {
      result = await db.insert(
        ChampionshipDatabase.tableTeamName,
        {'name': teamNameToSave},
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } else {
      result = await db.update(
        ChampionshipDatabase.tableTeamName,
        {'name': teamNameToSave},
        where: 'id = ?',
        whereArgs: [team.id],
      );
    }
    return result;
  }

  Future<int> _deleteTeamDB({Team? team}) async {
    int result = 0;
    if (team != null) {
      final db = await ChampionshipDatabase.instance.database;
      result = await db.delete(
        ChampionshipDatabase.tableTeamName,
        where: 'id = ?',
        whereArgs: [team.id],
      );
    }
    return result;
  }

  Future<List<MatchRounds>> _getMatchRoundsListDB() async {
    final db = await ChampionshipDatabase.instance.database;
    final result = await db.query(ChampionshipDatabase.tableMatchRoundsName);
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
    await batch.commit();
  }

  Future<int> _deleteAllMatchRoundsDB() async {
    final db = await ChampionshipDatabase.instance.database;
    return db.delete(ChampionshipDatabase.tableMatchRoundsName);
  }

  // --------------------------------------------------------------------------

  Future<void> _loadScreen() async {
    _isLoading = true;
    if (!mounted) return;
    setState(() {});

    try {
      _teamList = await _getTeamListDB();
      _matchRoundsList = await _getMatchRoundsListDB();

      // NOVO: Chama a conta mágica aqui! Sempre que o app abrir ou uma tela fechar, a tabela é calculada.
      await _calculateRanking();
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao carregar os dados',
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
        title: const Text(
          'Championship',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _onShowOptionsBottomSheet,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Icon(Icons.more_vert, size: 30),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _getBody(),
    );
  }
}
