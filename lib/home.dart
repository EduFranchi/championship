import 'package:championship/add_team.dart';
import 'package:championship/custom_shared_prefs.dart';
import 'package:championship/matches.dart';
import 'package:championship/ranking_table.dart';
import 'package:championship/settings_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controllerWin = TextEditingController();
  final TextEditingController _controllerDraw = TextEditingController();

  Future<void> _getWinAndDrawValue() async {
    int winValue = await CustomSharedPrefs.getWinValue() ?? 0;
    _controllerWin.text = winValue.toString();
    int drawValue = await CustomSharedPrefs.getDrawValue() ?? 0;
    _controllerDraw.text = drawValue.toString();
  }

  void _onTapEditMetrics() async {
    await _getWinAndDrawValue();
    if (!mounted) return;

    Navigator.pop(context);

    await showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: AlertDialog(
            title: const Text(
              'Editar métricas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Valor vitória:   ',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllerWin,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(5),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'Valor empate: ',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllerDraw,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(5),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
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
                onPressed: () async {
                  await CustomSharedPrefs.setWinValue(
                    int.tryParse(_controllerWin.text) ?? 0,
                  );
                  await CustomSharedPrefs.setDrawValue(
                    int.tryParse(_controllerDraw.text) ?? 0,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text(
                  'Salvar',
                  style: TextStyle(
                    color: Colors.black,
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

  void _addTeam() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTeam(),
      ),
    ).then((_) {
      //reload
    });
  }

  void _onPressedAction() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(5),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Opções',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SettingsItem(
                onTap: _onTapEditMetrics,
                iconData: Icons.edit,
                text: 'Editar métricas',
              ),
              SettingsItem(
                onTap: _addTeam,
                iconData: Icons.add,
                text: 'Adicionar equipe',
              ),
              SettingsItem(
                onTap: () {},
                iconData: Icons.edit_square,
                text: 'Alterar resultado de partida',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Championship',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _onPressedAction,
            child: Icon(Icons.more_vert, size: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RankingTable(),
            const SizedBox(height: 30),
            Matches(),
          ],
        ),
      ),
    );
  }
}
