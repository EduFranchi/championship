import 'package:championship/ranking_table_item.dart';
import 'package:championship/team_ranking.dart';
import 'package:flutter/material.dart';

class RankingTable extends StatelessWidget {
  final List<TeamRanking> teamRankingList;

  const RankingTable({
    super.key,
    required this.teamRankingList,
  });

  // Constrói a lista de linhas da tabela
  List<Widget> _getRankingTableItemList() {
    // 1. Adiciona o cabeçalho no topo da lista
    List<Widget> list = [
      const RankingTableItem(isHeader: true),
    ];

    // 2. Adiciona os times
    for (int i = 0; i < teamRankingList.length; i++) {
      list.add(
        RankingTableItem(
          pos: (i + 1).toString(),
          text: teamRankingList[i].team.name,
          pts: '00', // Troque pela pontuação real futuramente
          isEven: i % 2 == 0, // Verifica se a linha é par para o efeito zebra
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Estica para ocupar a tela
      children: [
        // Título da tabela
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Tabela de Classificação',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87, // Um preto mais suave que o Colors.black
            ),
          ),
        ),

        // O Container principal que engloba toda a tabela
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Bordas arredondadas
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.05,
                ), // Sombra bem leve e elegante
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // O ClipRRect garante que os itens de dentro não ultrapassem a borda arredondada
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: _getRankingTableItemList(),
            ),
          ),
        ),
      ],
    );
  }
}
