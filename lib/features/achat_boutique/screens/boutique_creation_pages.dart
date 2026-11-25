import 'package:flutter/material.dart';

import '../../../src/account_pages.dart' show AccountRow;
import '../../../src/ui.dart';
import '../aya_navigation.dart';
import '../aya_screens.dart';
import '../controllers/achat_boutique_controller.dart';
import '../models/achat_boutique_models.dart';
import '../widgets/achat_widgets.dart';

/// 42 · Choisir votre formule
class PlansPage extends StatelessWidget {
  const PlansPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    return PageScroll(padding: const EdgeInsets.fromLTRB(20, 14, 20, 26), children: [
      Text.rich(TextSpan(style: copyStyle, children: const [
        TextSpan(text: 'Sélectionnez l’abonnement adapté à votre commerce. '),
        TextSpan(text: '0 % de commission', style: TextStyle(fontWeight: FontWeight.w800)),
        TextSpan(text: ' sur les ventes.'),
      ])),
      const SizedBox(height: 16),
      for (final plan in ShopPlan.values) Padding(
        padding: EdgeInsets.only(bottom: 16, top: plan == ShopPlan.premium ? 8 : 0),
        child: _PlanCard(plan, selected: state.plan == plan, onTap: () => state.choosePlan(plan))),
      ForestButton('Continuer vers ma boutique', icon: Icons.storefront_outlined,
        onPressed: () => goAya(context, AyaScreen.createShop)),
    ]);
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard(this.plan, {required this.selected, required this.onTap});
  final ShopPlan plan;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final premium = plan == ShopPlan.premium;
    return Stack(clipBehavior: Clip.none, children: [
      Semantics(button: true, selected: selected, inMutuallyExclusiveGroup: true,
        label: '${plan.title}, ${plan.monthly} euros par mois',
        child: Material(
          color: selected ? peach : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? orange : const Color(0xFFD5DFD9), width: selected ? 2 : 1)),
          child: InkWell(onTap: onTap, customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(padding: const EdgeInsets.fromLTRB(18, 20, 18, 18), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(plan.title.toUpperCase(), style: strongStyle.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: .2))),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '${plan.monthly} €', style: headingStyle.copyWith(
                      fontSize: 26, color: premium ? orange : forest, letterSpacing: -.5)),
                    const TextSpan(text: '/mois', style: TextStyle(fontSize: 12, color: muted)),
                  ])),
                ]),
                const SizedBox(height: 12),
                for (final perk in plan.perks) Padding(padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    const Icon(Icons.check_rounded, size: 16, color: ink),
                    const SizedBox(width: 8),
                    Expanded(child: Text(perk, style: const TextStyle(fontSize: 14, color: ink))),
                  ])),
              ]))),
        )),
      if (premium) Positioned(right: 18, top: -12, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(20)),
        child: const Text('RECOMMANDÉ', style: TextStyle(color: Colors.white,
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .4)))),
    ]);
  }
}
