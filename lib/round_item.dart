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
        Expanded(
          child: Text(
            team1Name,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: Center(
            child: Text(
              '$team1Pts × $team2Pts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            team2Name,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
