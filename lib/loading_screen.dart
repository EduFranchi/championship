import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Um indicador de progresso com a cor primária do app
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3, // Deixa a linha um pouco mais elegante
          ),
          const SizedBox(height: 24),
          // Um texto sutil informando o usuário
          Text(
            'Carregando dados...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
