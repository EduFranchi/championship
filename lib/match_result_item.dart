import 'package:championship/match_rounds.dart';
import 'package:flutter/material.dart';

class MatchResultItem extends StatelessWidget {
  final MatchRounds match;
  final String team1Name;
  final String team2Name;
  final VoidCallback onTap;

  const MatchResultItem({
    super.key,
    required this.match,
    required this.team1Name,
    required this.team2Name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica visual do placar
    bool hasResult = match.team1Pts != null && match.team2Pts != null;
    bool team1Won = hasResult && (match.team1Pts! > match.team2Pts!);
    bool team2Won = hasResult && (match.team2Pts! > match.team1Pts!);
    bool isTie = hasResult && (match.team1Pts == match.team2Pts);

    // Estilo do Time 1
    Color team1Color = team1Won || !hasResult || isTie
        ? Colors.black87
        : Colors.grey.shade400;
    FontWeight team1Weight = team1Won
        ? FontWeight.bold
        : (hasResult && !isTie ? FontWeight.normal : FontWeight.w500);

    // Estilo do Time 2
    Color team2Color = team2Won || !hasResult || isTie
        ? Colors.black87
        : Colors.grey.shade400;
    FontWeight team2Weight = team2Won
        ? FontWeight.bold
        : (hasResult && !isTie ? FontWeight.normal : FontWeight.w500);

    // Estilo da Caixa Central (Placar)
    Color scoreBgColor = Colors.grey.shade100;
    Color scoreTextColor = Colors.grey.shade500;

    if (team1Won || team2Won) {
      scoreBgColor = Colors.blue.withValues(alpha: 0.1);
      scoreTextColor = Colors.blue.shade800;
    } else if (isTie) {
      scoreBgColor = Colors.orange.withValues(alpha: 0.1);
      scoreTextColor = Colors.orange.shade800;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              // --- TIME 1 ---
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (team1Won)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        team1Name,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: team1Weight,
                          color: team1Color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // --- PLACAR CENTRAL ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: scoreBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasResult ? '${match.team1Pts}  -  ${match.team2Pts}' : ' - ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: scoreTextColor,
                  ),
                ),
              ),

              // --- TIME 2 ---
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        team2Name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: team2Weight,
                          color: team2Color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (team2Won)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
              ),

              // Ícone discreto para indicar clicabilidade
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
