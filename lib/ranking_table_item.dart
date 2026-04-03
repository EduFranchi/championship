import 'package:flutter/material.dart';

class RankingTableItem extends StatelessWidget {
  final String? pos;
  final String? text;
  final String? pts;
  final bool isLast;

  const RankingTableItem({
    super.key,
    this.pos,
    this.text,
    this.pts,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 35,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: isLast ? 4 : 2),
              top: BorderSide(width: 2),
              left: BorderSide(width: 4),
              right: BorderSide(width: 2),
            ),
            color: pts == null ? Colors.black : Colors.white,
          ),
          child: Center(
            child: Text(
              pos ?? 'POS',
              style: TextStyle(
                fontSize: pos == null ? 15 : 20,
                fontWeight: pos == null ? FontWeight.bold : FontWeight.normal,
                color: pos == null ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 35,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: isLast ? 4 : 2),
                top: BorderSide(width: 2),
                left: BorderSide(width: 2),
                right: BorderSide(width: 2),
              ),
              color: pts == null ? Colors.black : Colors.white,
            ),
            child: Align(
              alignment: AlignmentGeometry.centerStart,
              child: Text(
                text ?? 'EQUIPE',
                style: TextStyle(
                  fontSize: pos == null ? 15 : 17,
                  fontWeight: text == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: text == null ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 45,
          height: 35,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: isLast ? 4 : 2),
              top: BorderSide(width: 2),
              left: BorderSide(width: 2),
              right: BorderSide(width: 4),
            ),
            color: pts == null ? Colors.black : Colors.white,
          ),
          child: Center(
            child: Text(
              pts ?? 'PTS',
              style: TextStyle(
                fontSize: pts == null ? 15 : 20,
                fontWeight: FontWeight.bold,
                color: pts == null ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
