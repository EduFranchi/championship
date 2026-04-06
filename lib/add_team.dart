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

  final TextEditingController _controllerNameTeam = TextEditingController();
  final FocusNode _focusNodenameTeam = FocusNode();

  List<Team> _teamList = [];

  List<Widget> _getTeamList() {
    return _teamList
        .map(
          (e) => TeamItem(
            team: e,
            editTeam: (team) {
              _onPressedDialogTeam(team: team);
            },
            deleteTeam: (team) {
              _onPressedDeleteTeam(team: team);
            },
          ),
        )
        .toList();
  }

  void _deleteTeam({Team? team}) async {
    try {
      int result = await widget.deleteTeamDB.call(team: team);
      if (result != 0) {
        if (!mounted) return;

        UIUtils.showCustomToast(
          context,
          'Equipe excluida com sucesso',
          Colors.white,
          Colors.green,
        );

        Navigator.pop(context);

        _loadScreen();
      } else {
        throw Exception();
      }

      result = await widget.deleteAllMatchRoundsDB();
      if (result == 0) {
        if (!mounted) return;
        UIUtils.showCustomToast(
          context,
          'Erro ao resetar rodadas',
          Colors.white,
          Colors.red,
        );
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

  void _onPressedDeleteTeam({Team? team}) async {
    await showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: AlertDialog(
            constraints: BoxConstraints(
              minWidth: double.infinity,
            ),
            title: Text(
              'Excluir Equipe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Ao excluir a equipe, as rodadas serão resetadas! Deseja continuar?',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Não',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _deleteTeam(team: team);
                },
                child: Text(
                  'Sim',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPressedSaveTeam({Team? team}) async {
    try {
      int result = await widget.saveTeamDB.call(
        _controllerNameTeam.text,
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

        _loadScreen();
      } else {
        throw Exception();
      }

      if (team == null) {
        result = await widget.deleteAllMatchRoundsDB();
        if (result == 0) {
          if (!mounted) return;
          UIUtils.showCustomToast(
            context,
            'Erro ao resetar rodadas',
            Colors.white,
            Colors.red,
          );
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

  List<Widget> _rememberReset({Team? team}) {
    if (team == null) {
      return [
        const SizedBox(height: 5),
        Text(
          'Obs: Ao adicionar uma equipe, as rodadas serão resetadas!',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 15,
          ),
        ),
      ];
    } else {
      return [];
    }
  }

  void _onPressedDialogTeam({Team? team}) async {
    if (team != null) {
      _controllerNameTeam.text = team.name ?? '';
    } else {
      _controllerNameTeam.clear();
    }
    _focusNodenameTeam.requestFocus();
    await showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: AlertDialog(
            constraints: BoxConstraints(
              minWidth: double.infinity,
            ),
            title: Text(
              '${team == null ? 'Adicionar' : 'Editar'} Equipe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  focusNode: _focusNodenameTeam,
                  controller: _controllerNameTeam,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(5),
                    hintText: 'Escreva o nome da equipe',
                  ),
                ),
                ..._rememberReset(team: team),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_controllerNameTeam.text.isNotEmpty) {
                    _onPressedSaveTeam(team: team);
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
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getBody() {
    if (_isLoading) {
      return LoadingScreen();
    } else {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ..._getTeamList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onPressedDialogTeam,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(5),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.green,
                ),
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _loadScreen() async {
    _isLoading = true;
    if (!mounted) return;
    setState(() {});

    try {
      _teamList = await widget.getTeamListDB();
    } catch (e) {
      if (!mounted) return;
      UIUtils.showCustomToast(
        context,
        'Erro ao carregar lista de equipe',
        Colors.white,
        Colors.red,
      );
    }

    _isLoading = false;
    if (!mounted) return;
    setState(() {});
  }

  void _init() async {
    await _loadScreen();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Adicionar equipe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _getBody(),
    );
  }
}
