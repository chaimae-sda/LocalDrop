import 'package:flutter/material.dart';
import '../../src/ui.dart';

class MerchantBody extends StatelessWidget {
  const MerchantBody(this.children, {super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      PageScroll(children: [StackColumn(children, gap: 14)]);
}

Future<bool> confirmAction(
  BuildContext context,
  String title,
  String message,
  String action,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;
}
