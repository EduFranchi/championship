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
    List<Widget> list = [];
    for (int i = 0; i < teamRankingList.length; i++) {
      int pos = i + 1;
      list.add(
        RankingTableItem(
          pos: pos.toString(),
          text: teamRankingList[i].team.name,
          pts: '00',
          isLast: pos == teamRankingList.length,
        ),
      );
    }
    return [
      RankingTableItem(),
      ...list,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tabela de Classificação',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        ..._getRankingTableItemList(),
      ],
    );
  }
}
