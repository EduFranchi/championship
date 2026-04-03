import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final void Function() onTap;
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(iconData),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
