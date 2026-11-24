import 'package:flutter/material.dart';

import 'screens.dart';
import 'ui.dart';

void go(BuildContext context, DropScreen screen, {bool replace = false}) {
  FocusManager.instance.primaryFocus?.unfocus();
  if (replace) {
    Navigator.of(context).pushReplacementNamed(screen.route);
  } else {
    Navigator.of(context).pushNamed(screen.route);
  }
}

void jump(BuildContext context, DropScreen screen) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).pushNamedAndRemoveUntil(screen.route, (route) => false);
}

void goBack(BuildContext context, DropScreen fallback) {
  final nav = Navigator.of(context);
  if (nav.canPop()) {
    nav.pop();
  } else {
    go(context, fallback, replace: true);
  }
}

typedef TeamNavigator = void Function(BuildContext context, TeamScreen destination);

class TeamRoutes extends InheritedWidget {
  const TeamRoutes({super.key, this.onOpen, required super.child});
  final TeamNavigator? onOpen;
  @override
  bool updateShouldNotify(TeamRoutes oldWidget) => onOpen != oldWidget.onOpen;
}

/// L'application complète peut fournir le routeur des autres modules.
Future<void> openTeam(BuildContext context, TeamScreen screen) async {
  final handler = context.getInheritedWidgetOfExactType<TeamRoutes>()?.onOpen;
  if (handler != null) {
    handler(context, screen);
    return;
  }
  final openProfile = await showModalBottomSheet<bool>(
    context: context, showDragHandle: true, useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 430),
    builder: (sheet) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: StackColumn([
        Text(screen.label, style: headingStyle.copyWith(fontSize: 24)),
        Text('Cet écran appartient au parcours ${screen == TeamScreen.merchantSetup ? 'commerçant' : 'de découverte client'} de l’équipe. Vous pouvez continuer la visite dans le profil client.', style: copyStyle),
        DropButton('Voir le profil client', icon: Icons.person_outline_rounded,
            onPressed: () => Navigator.pop(sheet, true)),
        TextButton(onPressed: () => Navigator.pop(sheet, false), child: const Text('Revenir à cet écran')),
      ]),
    ),
  );
  if (openProfile == true && context.mounted &&
      ModalRoute.of(context)?.settings.name != DropScreen.profile.route) {
    go(context, DropScreen.profile);
  }
}
