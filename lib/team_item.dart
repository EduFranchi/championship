import 'package:championship/team.dart';
import 'package:flutter/material.dart';

class TeamItem extends StatelessWidget {
  final Team team;
  final void Function(Team team) editTeam;
  final void Function(Team team) deleteTeam;

  const TeamItem({
    super.key,
    required this.team,
    required this.editTeam,
    required this.deleteTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                team.name ?? '',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      editTeam.call(team);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 25,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      deleteTeam.call(team);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 25,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
