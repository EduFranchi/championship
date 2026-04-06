import 'package:championship/team.dart';

class TeamRanking {
  final Team team;
  final int pts;
  final int matchesPlayed; // NOVO: Campo de partidas jogadas

  const TeamRanking({
    required this.team,
    required this.pts,
    this.matchesPlayed = 0,
  });
}
