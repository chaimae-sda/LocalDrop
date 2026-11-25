import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../src/ui.dart';
import 'aya_navigation.dart';
import 'aya_screens.dart';

/// Cadre des écrans d’Aya : en-tête vert, contenu arrondi et barre du bas,
/// avec la même présentation que le reste de LocalDrop.
class AyaShell extends StatelessWidget {
  const AyaShell({super.key, required this.screen, required this.child});
  final AyaScreen screen;
  final Widget child;

  Future<void> _openMenu(BuildContext context) async {
    final selected = await showModalBottomSheet<AyaScreen>(
      context: context, isScrollControlled: true, showDragHandle: true,
      useSafeArea: true, constraints: const BoxConstraints(maxWidth: 440),
      builder: (sheet) => FractionallySizedBox(heightFactor: .85, child: _AyaMenu(
        current: screen, onSelect: (value) => Navigator.pop(sheet, value))),
    );
    if (context.mounted && selected != null && selected != screen) jumpAya(context, selected);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: canvas,
    body: LayoutBuilder(builder: (context, bounds) {
      final wide = bounds.maxWidth >= 820;
      final header = screen.hasHeader;
      final mobile = ColoredBox(
        color: header ? forest : Colors.white,
        child: SafeArea(child: Column(children: [
          ConstrainedBox(
            constraints: header
                ? const BoxConstraints(minHeight: 65)
                : const BoxConstraints.tightFor(height: 42),
            child: Row(children: [
              if (header)
                IconButton(tooltip: 'Retour', onPressed: () => backAya(context, screen),
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white))
              else const SizedBox(width: 14),
              if (header) Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(screen.label, style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w700, letterSpacing: -.4)),
                    Text(screen.merchant ? 'Espace commerçant' : 'LocalDrop',
                      style: const TextStyle(color: Color(0xFFD5E5DB), fontSize: 11)),
                  ])))
              else const Spacer(),
              if (!wide)
                IconButton(tooltip: 'Tous les écrans', onPressed: () => _openMenu(context),
                  icon: Icon(Icons.grid_view_rounded, size: 19, color: header ? Colors.white : forest))
              else if (header)
                const Padding(padding: EdgeInsets.only(right: 18), child: Icon(Icons.bolt_outlined, color: Colors.white)),
            ])),
          Expanded(child: Container(
            clipBehavior: Clip.antiAlias, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: header ? const BorderRadius.vertical(top: Radius.circular(23)) : BorderRadius.zero),
            child: child)),
          if (screen.tab case final tab?)
            _AyaBottomBar(screen.merchant ? _merchantTabs : _clientTabs, active: tab),
        ])),
      );
      if (!wide) return mobile;
      return Row(children: [
        SizedBox(width: bounds.maxWidth < 1050 ? 235 : 260,
          child: ColoredBox(color: Colors.white, child: SafeArea(child: _AyaMenu(
            current: screen, onSelect: (value) { if (value != screen) jumpAya(context, value); })))),
        const VerticalDivider(width: 1, thickness: 1, color: line),
        Expanded(child: Padding(padding: EdgeInsets.symmetric(
          horizontal: 20, vertical: bounds.maxHeight < 580 ? 7 : 20),
          child: Center(child: Container(
            width: 400, height: math.min(844.0, bounds.maxHeight),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFD4DED7)),
              boxShadow: const [BoxShadow(color: Color(0x18162E1F), blurRadius: 38, offset: Offset(0, 12))]),
            child: mobile)))),
      ]);
    }),
  );
}

class _AyaMenu extends StatelessWidget {
  const _AyaMenu({required this.current, required this.onSelect});
  final AyaScreen current;
  final ValueChanged<AyaScreen> onSelect;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 19, 12, 17),
      child: Row(children: [
        const LogoMark(size: 36), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LocalDrop', style: headingStyle.copyWith(fontSize: 23)),
          const Text('Parcours d’Aya', style: TextStyle(fontSize: 12, color: muted)),
        ])),
      ])),
    const Divider(height: 1, color: line),
    Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(13, 4, 13, 16),
      children: [
        for (final group in ayaGroups.entries) ...[
          Padding(padding: const EdgeInsets.fromLTRB(10, 16, 0, 5), child: FieldLabel(group.key)),
          for (final screen in group.value)
            Padding(padding: const EdgeInsets.symmetric(vertical: 1),
              child: Material(color: current == screen ? mint : Colors.transparent,
                borderRadius: BorderRadius.circular(9), child: InkWell(
                  onTap: () => onSelect(screen), borderRadius: BorderRadius.circular(9),
                  child: Semantics(selected: current == screen, button: true,
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      child: Row(children: [
                        Text(screen.number, style: TextStyle(fontSize: 11, fontFamily: 'monospace',
                          color: current == screen ? forest : muted)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(screen.label, style: TextStyle(fontSize: 13,
                          color: current == screen ? forest : ink,
                          fontWeight: current == screen ? FontWeight.w700 : FontWeight.w500))),
                        if (current == screen) const Icon(Icons.chevron_right_rounded, size: 15, color: forest),
                      ])))))),
        ],
      ])),
  ]);
}

/// Onglet : libellé, icône et destination (écran d’Aya ou [TeamLink]).
typedef _Tab = (String, IconData, Object);

const _clientTabs = <_Tab>[
  ('Accueil', Icons.home_outlined, TeamLink.clientHome),
  ('Explorer', Icons.search_rounded, TeamLink.explore),
  ('Commandes', Icons.receipt_long_outlined, TeamLink.orders),
  ('Profil', Icons.person_outline_rounded, TeamLink.clientProfile),
];

const _merchantTabs = <_Tab>[
  ('Accueil', Icons.home_outlined, AyaScreen.dashboard),
  ('Vitrines', Icons.bolt_outlined, TeamLink.showcases),
  ('Scanner', Icons.qr_code_scanner_rounded, TeamLink.scanner),
  ('Stats', Icons.show_chart_rounded, TeamLink.stats),
  ('Profil', Icons.person_outline_rounded, AyaScreen.shopProfile),
];

class _AyaBottomBar extends StatelessWidget {
  const _AyaBottomBar(this.items, {required this.active});
  final List<_Tab> items;
  final int active;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: const BoxDecoration(color: Colors.white,
    border: Border(top: BorderSide(color: line))),
    child: Row(children: [for (final (i, (label, icon, target)) in items.indexed)
      Expanded(child: Semantics(selected: i == active, button: true, child: InkWell(
        onTap: () => openDestination(context, target),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 21, color: i == active ? forest : muted),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: i == active ? forest : muted,
                fontWeight: i == active ? FontWeight.w700 : FontWeight.normal)),
          ]))))),
    ]));
}
