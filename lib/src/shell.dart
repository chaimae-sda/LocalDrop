import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'navigation.dart';
import 'screens.dart';
import 'ui.dart';

class ScreenShell extends StatelessWidget {
  const ScreenShell({super.key, required this.screen, required this.child});
  final DropScreen screen;
  final Widget child;

  void _back(BuildContext context) {
    final fallback = switch (screen) {
      DropScreen.editProfile || DropScreen.addresses || DropScreen.help => DropScreen.profile,
      DropScreen.contact => DropScreen.help,
      DropScreen.signupClient || DropScreen.signupMerchant || DropScreen.login => DropScreen.roles,
      DropScreen.reset => DropScreen.login,
      _ => DropScreen.splash,
    };
    goBack(context, fallback);
  }

  Future<void> _openMenu(BuildContext context) async {
    final selected = await showModalBottomSheet<DropScreen>(
      context: context, isScrollControlled: true, showDragHandle: true,
      useSafeArea: true, constraints: const BoxConstraints(maxWidth: 440),
      builder: (sheet) => FractionallySizedBox(heightFactor: .85, child: _ScreenMenu(
        current: screen, onSelect: (value) => Navigator.pop(sheet, value))),
    );
    if (context.mounted && selected != null && selected != screen) jump(context, selected);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: canvas,
    body: LayoutBuilder(builder: (context, bounds) {
      final wide = bounds.maxWidth >= 820;
      final hasHeader = screen.inAccount;
      final dark = hasHeader || screen == DropScreen.splash;
      final mobile = ColoredBox(
        color: dark ? forest : Colors.white,
        child: SafeArea(child: Column(children: [
          ConstrainedBox(
            constraints: hasHeader
                ? const BoxConstraints(minHeight: 65)
                : const BoxConstraints.tightFor(height: 42),
            child: Row(children: [
              if (screen != DropScreen.splash)
                IconButton(tooltip: 'Retour', onPressed: () => _back(context),
                  icon: Icon(Icons.chevron_left_rounded, color: dark ? Colors.white : muted))
              else const SizedBox(width: 14),
              if (hasHeader) Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(screen.label, style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700, letterSpacing: -.4)),
                  const Text('LocalDrop', style: TextStyle(color: Color(0xFFD5E5DB), fontSize: 11)),
                ])))
              else const Spacer(),
              if (!wide)
                IconButton(tooltip: 'Tous les écrans', onPressed: () => _openMenu(context),
                  icon: Icon(Icons.grid_view_rounded, size: 19, color: dark ? Colors.white : forest))
              else if (hasHeader)
                const Padding(padding: EdgeInsets.only(right: 18), child: Icon(Icons.bolt_outlined, color: Colors.white)),
            ])),
          Expanded(child: Container(
            clipBehavior: Clip.antiAlias, width: double.infinity,
            decoration: BoxDecoration(color: screen == DropScreen.splash ? forest : Colors.white,
              borderRadius: hasHeader ? const BorderRadius.vertical(top: Radius.circular(23)) : BorderRadius.zero),
            child: child)),
          if (hasHeader) const _AccountNavigation(),
        ])),
      );
      if (!wide) return mobile;
      return Row(children: [
        SizedBox(width: bounds.maxWidth < 1050 ? 235 : 260,
          child: ColoredBox(color: Colors.white, child: SafeArea(child: _ScreenMenu(
            current: screen, onSelect: (value) { if (value != screen) jump(context, value); })))),
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

class _ScreenMenu extends StatelessWidget {
  const _ScreenMenu({required this.current, required this.onSelect});
  final DropScreen current;
  final ValueChanged<DropScreen> onSelect;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 19, 12, 17),
      child: Row(children: [
        const LogoMark(size: 36), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LocalDrop', style: headingStyle.copyWith(fontSize: 23)),
          const Text('Parcours client Layla', style: TextStyle(fontSize: 12, color: muted)),
        ])),
      ])),
    const Divider(height: 1, color: line),
    Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(13, 4, 13, 16),
      children: [
        for (final group in screenGroups.entries) ...[
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

class _AccountNavigation extends StatelessWidget {
  const _AccountNavigation();
  @override
  Widget build(BuildContext context) {
    const items = [
      ('Accueil', Icons.home_outlined, DropScreen.aroundMe),
      ('Explorer', Icons.search_rounded, DropScreen.flashOffers),
      ('Commandes', Icons.receipt_long_outlined, DropScreen.orders),
      ('Favoris', Icons.favorite_border_rounded, DropScreen.favorites),
    ];
    return DecoratedBox(decoration: const BoxDecoration(color: Colors.white,
      border: Border(top: BorderSide(color: line))),
      child: Row(children: [for (final (label, icon, target) in items)
        Expanded(child: InkWell(onTap: () {
          if (ModalRoute.of(context)?.settings.name != target.route) {
            go(context, target);
          }
        }, child: Padding(padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 21, color: ModalRoute.of(context)?.settings.name == target.route ? forest : muted),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              fontSize: 10,
              color: ModalRoute.of(context)?.settings.name == target.route ? forest : muted,
              fontWeight: ModalRoute.of(context)?.settings.name == target.route ? FontWeight.w700 : FontWeight.normal,
            )),
          ])))),
      ]));
  }
}
