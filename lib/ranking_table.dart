import 'package:championship/ranking_table_item.dart';
import 'package:flutter/material.dart';

class RankingTable extends StatelessWidget {
  const RankingTable({super.key});

  List<Widget> _getRankingTableItemList() {
    return [
      RankingTableItem(),
      RankingTableItem(
        pos: '00',
        text: 'Eduardo A. / Mateus F.',
        pts: '00',
      ),
      RankingTableItem(
        pos: '00',
        text: 'Eduardo A. / Mateus F.',
        pts: '00',
      ),
      RankingTableItem(
        pos: '00',
        text: 'Eduardo A. / Mateus F.',
        pts: '00',
      ),
      RankingTableItem(
        pos: '00',
        text: 'Eduardo A. / Mateus F.',
        pts: '00',
        isLast: true,
      ),
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
