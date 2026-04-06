import 'package:championship/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Championship',
      theme: ThemeData(
        // Alteramos a cor semente para combinar com os botões e detalhes
        // que criamos (Colors.blue[800]). O Flutter vai gerar uma paleta inteira
        // baseada nesse azul!
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
        ),
        // Opcional: Define uma cor de fundo global um pouco mais "fria" e moderna
        scaffoldBackgroundColor: Colors.grey.shade50,
        useMaterial3: true,
      ),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
