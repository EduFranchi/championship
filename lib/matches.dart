import 'package:championship/match_rounds.dart';
import 'package:championship/round_item.dart'; // Mantido o seu import original
import 'package:championship/team.dart';
import 'package:flutter/material.dart';

class Matches extends StatelessWidget {
  final Future<void> Function() onGenerateRaffle;
  final List<MatchRounds>? matchRoundsList;
  final List<Team> teamList;

  const Matches({
    super.key,
    required this.onGenerateRaffle,
    this.matchRoundsList,
    required this.teamList,
  });

  // Função auxiliar segura para buscar o nome do time
  String _getTeamName(int? teamId) {
    if (teamId == null) return 'Desconhecido';

    try {
      final team = teamList.firstWhere((element) => element.id == teamId);
      return team.name ?? 'Time $teamId';
    } catch (e) {
      return 'Time $teamId';
    }
  }

  // Constrói a visualização principal (Lista de rodadas ou Botão de sortear)
  Widget _buildContent() {
    // Estado Vazio: Mostra uma mensagem amigável e um botão chamativo
    if (matchRoundsList == null || matchRoundsList!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.sports_soccer, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma partida gerada',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onGenerateRaffle,
              icon: const Icon(Icons.casino),
              label: const Text('Sortear Partidas'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: const Color(0xFF4B0082),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Estado Preenchido: Agrupa e exibe as rodadas de forma moderna
    Map<int, List<MatchRounds>> groupedMatches = {};

    for (MatchRounds match in matchRoundsList!) {
      int roundNumber = match.round ?? 0;
      groupedMatches.putIfAbsent(roundNumber, () => []).add(match);
    }

    List<Widget> listWidgets = [];

    // Ordena as rodadas cronologicamente
    var sortedRounds = groupedMatches.keys.toList()..sort();

    for (var roundNumber in sortedRounds) {
      var matchesInRound = groupedMatches[roundNumber]!;

      // Cabeçalho solto da Rodada
      listWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
          child: Text(
            'Rodada $roundNumber',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(
                0xFF4B0082,
              ), // Mesma cor temática do resto do app
            ),
          ),
        ),
      );

      // Cards individuais para cada partida (usando o nosso novo RoundItem)
      for (var match in matchesInRound) {
        listWidgets.add(
          RoundItem(
            team1Name: _getTeamName(match.team1),
            team1Pts: match.team1Pts, // Passando o valor original int?
            team2Name: _getTeamName(match.team2),
            team2Pts: match.team2Pts, // Passando o valor original int?
          ),
        );
      }
    }

    // Usamos Column com crossAxisAlignment Stretch para ocupar bem a tela
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: listWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título principal da seção
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Partidas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
        ),
        _buildContent(),
      ],
    );
  }
}
