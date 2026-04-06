import 'package:flutter/material.dart';

class RankingTableItem extends StatelessWidget {
  final String? pos;
  final String? text;
  final String? played;
  final String? pts;
  final bool isHeader;
  final bool isEven;

  const RankingTableItem({
    super.key,
    this.pos,
    this.text,
    this.played,
    this.pts,
    this.isHeader = false,
    this.isEven = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isHeader
        ? const Color(0xFF1E1E1E)
        : (isEven ? Colors.grey[50] : Colors.white);

    final textColor = isHeader ? Colors.white : Colors.black87;
    final fontWeight = isHeader ? FontWeight.bold : FontWeight.w500;

    return Container(
      height: 45,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Coluna: POS (Posição)
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                pos ?? 'POS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
            ),
          ),

          // Coluna: EQUIPE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                text ?? 'EQUIPE',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Coluna: J (Jogadas)
          SizedBox(
            width: 35,
            child: Center(
              child: Text(
                played ?? 'J',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
            ),
          ),

          // Coluna: PTS (Pontos) - COM SUPER DESTAQUE
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                pts ?? 'PTS',
                style: TextStyle(
                  fontSize: 16, // Letra um pouco maior que o resto
                  fontWeight: FontWeight.w900, // Peso máximo de negrito
                  // Usa o azul tema para destacar os pontos, mantendo branco no cabeçalho
                  color: isHeader ? Colors.white : const Color(0xFF4B0082),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
