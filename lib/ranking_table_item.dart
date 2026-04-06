import 'package:flutter/material.dart';

class RankingTableItem extends StatelessWidget {
  final String? pos;
  final String? text;
  final String? pts;
  final bool isHeader;
  final bool isEven; // Para controlar a cor alternada

  const RankingTableItem({
    super.key,
    this.pos,
    this.text,
    this.pts,
    this.isHeader = false,
    this.isEven = false,
  });

  @override
  Widget build(BuildContext context) {
    // Define as cores com base no tipo da linha (cabeçalho, par ou ímpar)
    final backgroundColor = isHeader
        ? const Color(0xFF1E1E1E) // Cor escura para o cabeçalho
        : (isEven ? Colors.grey[50] : Colors.white); // Efeito Zebra

    final textColor = isHeader ? Colors.white : Colors.black87;
    final fontWeight = isHeader ? FontWeight.bold : FontWeight.w500;

    return Container(
      height: 45, // Uma altura um pouco maior deixa a leitura mais confortável
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

          // Coluna: EQUIPE (O Expanded faz ela ocupar todo o espaço restante)
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
                maxLines: 1, // Previne que a linha quebre
                overflow: TextOverflow
                    .ellipsis, // Coloca "..." se o nome for muito grande
              ),
            ),
          ),

          // Coluna: PTS (Pontos)
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                pts ?? 'PTS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold, // Pontos sempre em destaque
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
