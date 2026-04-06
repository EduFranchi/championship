import 'package:championship/match_rounds.dart';
import 'package:championship/round_item.dart';
import 'package:championship/team.dart';
import 'package:flutter/material.dart';

class Matches extends StatelessWidget {
  final Future<void> Function() onGenerateRaffle; // Ação de sortear
  final List<MatchRounds>? matchRoundsList; // Corrigido o erro de digitação
  final List<Team> teamList;

  const Matches({
    super.key,
    required this.onGenerateRaffle,
    this.matchRoundsList,
    required this.teamList,
  });

  // Função auxiliar para buscar o nome do time com segurança, evitando crashes
  String _getTeamName(int? teamId) {
    if (teamId == null) return 'Desconhecido';

    try {
      final team = teamList.firstWhere((element) => element.id == teamId);
      return team.name ?? 'Time $teamId';
    } catch (e) {
      // Se não encontrar o time (ex: time foi deletado), retorna um valor padrão
      return 'Time $teamId';
    }
  }

  // Constrói a lista de partidas de uma rodada específica
  List<Widget> _buildMatchesForRound(List<MatchRounds> roundMatches) {
    List<Widget> matchesWidgets = [];

    for (int i = 0; i < roundMatches.length; i++) {
      MatchRounds currentMatch = roundMatches[i];

      matchesWidgets.add(
        RoundItem(
          team1Name: _getTeamName(currentMatch.team1),
          team1Pts: currentMatch.team1Pts?.toString() ?? '',
          team2Name: _getTeamName(currentMatch.team2),
          team2Pts: currentMatch.team2Pts?.toString() ?? '',
        ),
      );

      // Adiciona uma linha divisória entre as partidas, exceto após a última
      if (i < roundMatches.length - 1) {
        matchesWidgets.add(
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        );
      }
    }
    return matchesWidgets;
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
                backgroundColor: Colors.blue[800], // Cor de destaque do botão
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

    // Estado Preenchido: Agrupa e exibe as rodadas
    Map<int, List<MatchRounds>> groupedMatches = {};

    for (MatchRounds match in matchRoundsList!) {
      int roundNumber = match.round ?? 0;
      groupedMatches.putIfAbsent(roundNumber, () => []).add(match);
    }

    List<Widget> roundsWidgets = [];

    groupedMatches.forEach((roundNumber, matchesList) {
      roundsWidgets.add(
        // Um Card moderno para englobar toda a rodada
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior:
              Clip.antiAlias, // Garante que o conteúdo não vaze as bordas
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho da Rodada com fundo destacado
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Text(
                  'Rodada $roundNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Lista de partidas dentro deste Card
              ..._buildMatchesForRound(matchesList),
            ],
          ),
        ),
      );
    });

    return Column(children: roundsWidgets);
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
