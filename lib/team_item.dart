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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        // Sem o ícone, aumentamos um pouquinho o padding esquerdo (16)
        // para o texto não colar na borda do Card.
        contentPadding: const EdgeInsets.only(
          left: 16,
          right: 8,
          top: 4,
          bottom: 4,
        ),

        // Removemos o 'leading' completamente!
        title: Text(
          team.name ?? 'Equipe sem nome',
          style: const TextStyle(
            fontSize: 16, // Voltei para 16 pois agora tem bastante espaço
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: Colors.blueGrey,
              tooltip: 'Editar',
              onPressed: () => editTeam(team),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
              tooltip: 'Excluir',
              onPressed: () => deleteTeam(team),
            ),
          ],
        ),
      ),
    );
  }
}
