import 'dart:developer';

import 'package:championship/loading_screen.dart';
import 'package:championship/team.dart';
import 'package:championship/team_item.dart';
import 'package:championship/ui_utils.dart';
import 'package:flutter/material.dart';

class AddTeam extends StatefulWidget {
  final Future<List<Team>> Function() getTeamListDB;
  final Future<int> Function(String teamNameToSave, {Team? team}) saveTeamDB;
  final Future<int> Function({Team? team}) deleteTeamDB;
  final Future<int> Function() deleteAllMatchRoundsDB;

  const AddTeam({
    super.key,
    required this.getTeamListDB,
    required this.saveTeamDB,
    required this.deleteTeamDB,
    required this.deleteAllMatchRoundsDB,
  });

  @override
  State<AddTeam> createState() => _AddTeamState();
}

class _AddTeamState extends State<AddTeam> {
  bool _isLoading = true;

  // Controlador de texto
  final TextEditingController _teamNameController = TextEditingController();

  List<Team> _teamList = [];

  @override
  void initState() {
    super.initState();
    // Chama o carregamento direto, sem precisar de uma função _init() intermediária
    _loadData();
  }

  // MÉTODO CRÍTICO: Previne vazamento de memória quando a tela é fechada
  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  // Carrega os dados do banco de dados
  Future<void> _loadData() async {
    _isLoading = true;
    if (!mounted) return;
    setState(() {});

    try {
      _teamList = await widget.getTeamListDB();
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao carregar lista de equipes',
        Colors.white,
        Colors.red,
      );
    }

    _isLoading = false;
    if (!mounted) return;
    setState(() {});
  }

  // Lógica de deleção com reset das rodadas
  void _deleteTeam({Team? team}) async {
    try {
      int result = await widget.deleteTeamDB.call(team: team);
      if (result != 0) {
        if (!mounted) return;

        UIUtils.showCustomToast(
          context,
          'Equipe excluída com sucesso',
          Colors.white,
          Colors.green,
        );

        Navigator.pop(context);
        _loadData();
      } else {
        throw Exception();
      }

      result = await widget.deleteAllMatchRoundsDB();
      if (result == 0) {
        log('Erro ao resetar rodadas');
      }
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao excluir equipe',
        Colors.white,
        Colors.red,
      );
    }
  }

  // Lógica para salvar a equipe
  void _saveTeam({Team? team}) async {
    try {
      int result = await widget.saveTeamDB.call(
        _teamNameController.text.trim(),
        team: team,
      );
      if (result != 0) {
        if (!mounted) return;

        UIUtils.showCustomToast(
          context,
          'Equipe salva com sucesso',
          Colors.white,
          Colors.green,
        );

        Navigator.pop(context);
        _loadData();
      } else {
        throw Exception();
      }

      if (team == null) {
        result = await widget.deleteAllMatchRoundsDB();
        if (result == 0) {
          log('Erro ao resetar rodadas');
        }
      }
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao salvar equipe',
        Colors.white,
        Colors.red,
      );
    }
  }

  // Diálogo de confirmação de exclusão (Visual Moderno)
  void _showDeleteTeamDialog({Team? team}) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Excluir Equipe?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Ao excluir a equipe, todas as rodadas serão resetadas! Deseja continuar?',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.red[50],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _deleteTeam(team: team),
              child: const Text(
                'Excluir',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Caixa visual de alerta para não usar apenas texto itálico
  Widget _buildWarningResetBox({Team? team}) {
    if (team != null) {
      return const SizedBox.shrink(); // Retorna vazio se for edição
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Atenção: Ao adicionar uma nova equipe, todas as rodadas atuais serão resetadas!',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo para Adicionar/Editar equipe (Visual Moderno)
  void _showAddEditTeamDialog({Team? team}) async {
    if (team != null) {
      _teamNameController.text = team.name ?? '';
    } else {
      _teamNameController.clear();
    }

    await showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              team == null ? 'Adicionar Equipe' : 'Editar Equipe',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _teamNameController,
                  autofocus: true, // Substitui o FocusNode de forma limpa!
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction
                      .done, // Mostra o botão "Confirmar" no teclado
                  onSubmitted: (value) {
                    // Salva a equipe ao apertar o botão de confirmar do teclado
                    if (value.trim().isNotEmpty) {
                      _saveTeam(team: team);
                    } else {
                      UIUtils.showCustomToast(
                        context,
                        'Nome da equipe está vazio',
                        Colors.white,
                        Colors.red,
                      );
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Nome da equipe',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                _buildWarningResetBox(team: team),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B0082),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_teamNameController.text.trim().isNotEmpty) {
                    _saveTeam(team: team);
                  } else {
                    UIUtils.showCustomToast(
                      context,
                      'Nome da equipe está vazio',
                      Colors.white,
                      Colors.red,
                    );
                  }
                },
                child: Text(
                  team == null ? 'Adicionar' : 'Salvar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Constrói o corpo da tela
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingScreen();
    }

    // Empty State: Tela quando não há times
    if (_teamList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma equipe cadastrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione as equipes para começar o campeonato.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Lista de Times
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 80,
      ),
      itemCount: _teamList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final team = _teamList[index];
        return TeamItem(
          team: team,
          editTeam: (t) => _showAddEditTeamDialog(team: t),
          deleteTeam: (t) => _showDeleteTeamDialog(team: t),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B0082),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Equipes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditTeamDialog(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4B0082),
        foregroundColor: Colors.white,
      ),
    );
  }
}
