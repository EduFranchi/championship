import 'package:flutter/material.dart';

class RoundItem extends StatelessWidget {
  final String team1Name;
  final String team1Pts;
  final String team2Name;
  final String team2Pts;

  const RoundItem({
    super.key,
    required this.team1Name,
    required this.team1Pts,
    required this.team2Name,
    required this.team2Pts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          team1Name,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        Text(
          '  $team1Pts × $team2Pts  ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          team2Name,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
