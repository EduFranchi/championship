import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final VoidCallback
  onTap; // VoidCallback é o padrão do Flutter para 'void Function()'
  final IconData iconData;
  final String text;

  const SettingsItem({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // 1. O Material transparente garante que o Ripple (efeito de clique) apareça
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // 2. Arredonda o efeito cinza do clique para acompanhar o design do app
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          // 3. Aumentei o padding vertical para melhorar a área de toque do dedo
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              // 4. Um container com fundo claro para destacar o ícone (Design Moderno)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // Usando o withValues atualizado que você já aprendeu!
                  color: const Color(0xFF4B0082).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  iconData,
                  color: const Color(
                    0xFF4B0082,
                  ), // Ícone com a cor principal escura
                  size: 22,
                ),
              ),
              const SizedBox(width: 16), // Mais respiro entre o ícone e o texto
              // 5. O Expanded evita erros de tela (Overflow) se o texto for muito longo
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16, // Tamanho ideal para leitura
                    fontWeight: FontWeight.w600, // Levemente em negrito
                    color: Colors.black87, // Mais suave que o preto total
                  ),
                ),
              ),

              // 6. Uma setinha no final para indicar que o item abre uma ação
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400], // Bem discreto
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
