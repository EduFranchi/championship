import 'package:flutter/material.dart';

class RoundItem extends StatelessWidget {
  final String team1Name;
  final int? team1Pts; // Alterado para int? para calcularmos o vencedor
  final String team2Name;
  final int? team2Pts; // Alterado para int?

  const RoundItem({
    super.key,
    required this.team1Name,
    this.team1Pts,
    required this.team2Name,
    this.team2Pts,
  });

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA VISUAL DO PLACAR (A mesma da tela de edição) ---
    bool hasResult = team1Pts != null && team2Pts != null;
    bool team1Won = hasResult && (team1Pts! > team2Pts!);
    bool team2Won = hasResult && (team2Pts! > team1Pts!);
    bool isTie = hasResult && (team1Pts == team2Pts);

    Color team1Color = team1Won || !hasResult || isTie
        ? Colors.black87
        : Colors.grey.shade400;
    FontWeight team1Weight = team1Won
        ? FontWeight.bold
        : (hasResult && !isTie ? FontWeight.normal : FontWeight.w500);

    Color team2Color = team2Won || !hasResult || isTie
        ? Colors.black87
        : Colors.grey.shade400;
    FontWeight team2Weight = team2Won
        ? FontWeight.bold
        : (hasResult && !isTie ? FontWeight.normal : FontWeight.w500);

    Color scoreBgColor = Colors.grey.shade100;
    Color scoreTextColor = Colors.grey.shade500;

    if (team1Won || team2Won) {
      scoreBgColor = const Color(0xFF4B0082).withValues(alpha: 0.1);
      scoreTextColor = const Color(0xFF4B0082);
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
      // Como aqui é apenas visualização, usamos apenas Padding (sem InkWell)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        fontSize: 15,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: scoreBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasResult ? '$team1Pts  -  $team2Pts' : ' - ',
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
                        fontSize: 15,
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
          ],
        ),
      ),
    );
  }
}
