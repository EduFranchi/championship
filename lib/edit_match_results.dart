import 'package:championship/loading_screen.dart';
import 'package:championship/match_rounds.dart';
import 'package:championship/team.dart';
import 'package:championship/ui_utils.dart';
import 'package:championship/match_result_item.dart'; // <-- IMPORTANTE
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditMatchResults extends StatefulWidget {
  final Future<List<MatchRounds>> Function() getMatchRoundsDB;
  final Future<List<Team>> Function() getTeamListDB;
  final Future<void> Function(List<MatchRounds> matchRoundsList)
  saveMatchRoundsListDB;

  const EditMatchResults({
    super.key,
    required this.getMatchRoundsDB,
    required this.getTeamListDB,
    required this.saveMatchRoundsListDB,
  });

  @override
  State<EditMatchResults> createState() => _EditMatchResultsState();
}

class _EditMatchResultsState extends State<EditMatchResults> {
  bool _isLoading = true;

  List<MatchRounds> _matchList = [];
  List<Team> _teamList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    if (!mounted) return;
    setState(() {});

    try {
      final results = await Future.wait([
        widget.getMatchRoundsDB(),
        widget.getTeamListDB(),
      ]);

      _matchList = results[0] as List<MatchRounds>;
      _teamList = results[1] as List<Team>;
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao carregar os dados das partidas',
        Colors.white,
        Colors.red,
      );
    }

    _isLoading = false;
    if (!mounted) return;
    setState(() {});
  }

  String _getTeamName(int? teamId) {
    if (teamId == null) return 'Desconhecido';
    try {
      return _teamList.firstWhere((team) => team.id == teamId).name ??
          'Time $teamId';
    } catch (e) {
      return 'Time $teamId';
    }
  }

  Future<void> _saveMatchResult(
    MatchRounds oldMatch,
    int? newPts1,
    int? newPts2,
  ) async {
    try {
      MatchRounds updatedMatch = MatchRounds(
        id: oldMatch.id,
        round: oldMatch.round,
        team1: oldMatch.team1,
        team2: oldMatch.team2,
        team1Pts: newPts1,
        team2Pts: newPts2,
      );

      await widget.saveMatchRoundsListDB([updatedMatch]);

      if (!mounted) return;

      UIUtils.showCustomToast(
        context,
        'Resultado atualizado!',
        Colors.white,
        Colors.green,
      );

      Navigator.pop(context);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao salvar resultado',
        Colors.white,
        Colors.red,
      );
    }
  }

  void _showEditMatchDialog(MatchRounds match) {
    final TextEditingController team1PtsController = TextEditingController(
      text: match.team1Pts?.toString() ?? '',
    );
    final TextEditingController team2PtsController = TextEditingController(
      text: match.team2Pts?.toString() ?? '',
    );

    String team1Name = _getTeamName(match.team1);
    String team2Name = _getTeamName(match.team2);

    showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Editar Resultado',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rodada ${match.round ?? '-'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        team1Name,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: team1PtsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'X',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: team2PtsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        team2Name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B0082),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  int? pts1 = int.tryParse(team1PtsController.text);
                  int? pts2 = int.tryParse(team2PtsController.text);

                  _saveMatchResult(match, pts1, pts2);
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

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingScreen();
    }

    if (_matchList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma partida gerada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    Map<int, List<MatchRounds>> groupedMatches = {};
    for (var match in _matchList) {
      int round = match.round ?? 0;
      groupedMatches.putIfAbsent(round, () => []).add(match);
    }

    List<Widget> listWidgets = [];
    var sortedRounds = groupedMatches.keys.toList()..sort();

    for (var roundNumber in sortedRounds) {
      var matchesInRound = groupedMatches[roundNumber]!;

      listWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
          child: Text(
            'Rodada $roundNumber',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4B0082),
            ),
          ),
        ),
      );

      for (var match in matchesInRound) {
        String team1Name = _getTeamName(match.team1);
        String team2Name = _getTeamName(match.team2);

        // --- Aqui usamos o nosso novo Widget Componentizado! ---
        listWidgets.add(
          MatchResultItem(
            match: match,
            team1Name: team1Name,
            team2Name: team2Name,
            onTap: () => _showEditMatchDialog(match),
          ),
        );
      }
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: listWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B0082),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Resultados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }
}
