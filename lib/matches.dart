import 'package:championship/round_item.dart';
import 'package:flutter/material.dart';

class Matches extends StatelessWidget {
  const Matches({super.key});

  List<Widget> _getRoundItemList() {
    return [
      RoundItem(
        team1Name: 'Eduardo A. / Mateus F.',
        team1Pts: '10',
        team2Name: 'Eduardo A. / Mateus F.',
        team2Pts: '8',
      ),
      RoundItem(
        team1Name: 'Eduardo A. / Mateus F.',
        team1Pts: '10',
        team2Name: 'Eduardo A. / Mateus F.',
        team2Pts: '8',
      ),
      RoundItem(
        team1Name: 'Eduardo A. / Mateus F.',
        team1Pts: '10',
        team2Name: 'Eduardo A. / Mateus F.',
        team2Pts: '8',
      ),
    ];
  }

  List<Widget> _getRoundList() {
    return [
      Text(
        'Rodada 1',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
          fontSize: 20,
        ),
      ),
      ..._getRoundItemList(),
      Text(
        'Rodada 2',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
          fontSize: 20,
        ),
      ),
      ..._getRoundItemList(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partidas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        ..._getRoundList(),
      ],
    );
  }
}
