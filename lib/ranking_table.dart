import 'package:championship/ranking_table_item.dart';
import 'package:championship/team_ranking.dart';
import 'package:flutter/material.dart';

class RankingTable extends StatelessWidget {
  final List<TeamRanking> teamRankingList;

  const RankingTable({
    super.key,
    required this.teamRankingList,
  });

  List<Widget> _getRankingTableItemList() {
    List<Widget> list = [
      const RankingTableItem(isHeader: true),
    ];

    for (int i = 0; i < teamRankingList.length; i++) {
      list.add(
        RankingTableItem(
          pos: (i + 1).toString(),
          text: teamRankingList[i].team.name,
          played: teamRankingList[i].matchesPlayed
              .toString(), // Agora pega as partidas jogadas
          pts: teamRankingList[i].pts.toString(), // Agora pega a pontuação real
          isEven: i % 2 == 0,
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Tabela de Classificação',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
