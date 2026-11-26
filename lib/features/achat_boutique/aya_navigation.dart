import 'package:flutter/material.dart';

import '../../src/ui.dart';
import '../../src/screens.dart';
import '../../src/navigation.dart';
import '../../src/demo.dart';
import 'aya_screens.dart';

void goAya(BuildContext context, AyaScreen screen, {bool replace = false}) {
  FocusManager.instance.primaryFocus?.unfocus();
  final nav = Navigator.of(context);
  replace
      ? nav.pushReplacementNamed(screen.route)
      : nav.pushNamed(screen.route);
}

/// Ouvre [screen] en vidant l’historique.
void jumpAya(BuildContext context, AyaScreen screen) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).pushNamedAndRemoveUntil(screen.route, (route) => false);
}

/// Ouvre [screen] en ne gardant que [keep] dessous, s’il est dans l’historique.
void goAfter(BuildContext context, AyaScreen screen, AyaScreen keep) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).pushNamedAndRemoveUntil(
    screen.route,
    (route) => route.settings.name == keep.route,
  );
}

void backAya(BuildContext context, AyaScreen current) {
  final nav = Navigator.of(context);
  if (nav.canPop()) {
    nav.pop();
  } else if (current.back case final AyaScreen screen) {
    goAya(context, screen, replace: true);
  } else if (current.back case final TeamLink link) {
    openTeamLink(context, link);
  }
}

/// Ouvre un écran d’Aya ou indique l’écran d’un autre membre.
void openDestination(BuildContext context, Object target) {
  if (target is TeamLink) {
    openTeamLink(context, target);
  } else if (target is AyaScreen &&
      ModalRoute.of(context)?.settings.name != target.route) {
    goAya(context, target);
  }
}

/// Les écrans des autres membres seront reliés lors de la réunion des branches.
Future<void> openTeamLink(BuildContext context, TeamLink link) async {
  final route = switch (link) {
    TeamLink.clientHome => DropScreen.aroundMe,
    TeamLink.offerDetail => DropScreen.offerDetail,
    _ => DropScreen.fromRoute('/${link.id}'),
  };
  if (route != null &&
      context.getInheritedWidgetOfExactType<DemoScope>() != null) {
    go(context, route);
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 430),
    builder: (sheet) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: StackColumn([
        Text(
          '${link.number} · ${link.label}',
          style: headingStyle.copyWith(fontSize: 24),
        ),
        Text(
          'Cet écran appartient au parcours de ${link.owner}.',
          style: copyStyle,
        ),
        DropButton(
          'Revenir à cet écran',
          style: ActionStyle.outline,
          onPressed: () => Navigator.pop(sheet),
        ),
      ]),
    ),
  );
}
