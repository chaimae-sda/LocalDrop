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

/// 43 · Créer ma boutique
class CreateShopPage extends StatefulWidget {
  const CreateShopPage({super.key});
  @override
  State<CreateShopPage> createState() => _CreateShopPageState();
}

class _CreateShopPageState extends State<CreateShopPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final category = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();

  @override
  void dispose() {
    name.dispose(); category.dispose(); address.dispose(); phone.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    AchatBoutiqueScope.of(context).saveShop(ShopInfo(name: name.text.trim(), category: category.text.trim(),
      address: address.text.trim(), phone: phone.text.trim()));
    goAya(context, AyaScreen.shopReady);
  }

  @override
  Widget build(BuildContext context) => PageScroll(padding: const EdgeInsets.fromLTRB(20, 14, 20, 26), children: [
    const Kicker('Étape 1 sur 2'),
    const SizedBox(height: 12),
    const ProgressLine(.5, label: 'Création de la boutique'),
    const SizedBox(height: 14),
    const Text('Parlez-nous de votre commerce pour créer votre vitrine.', style: copyStyle),
    const SizedBox(height: 14),
    Form(key: form, child: StackColumn(gap: 14, [
      DropField('Nom de la boutique', controller: name, hint: 'Boulangerie de la Place',
        icon: Icons.storefront_outlined, validate: requiredText),
      DropField('Catégorie', controller: category, hint: 'Boulangerie & pâtisserie',
        icon: Icons.storefront_outlined, validate: requiredText),
      DropField('Adresse', controller: address, hint: '12, Rue du Commerce, 75001 Paris',
        icon: Icons.location_on_outlined, validate: requiredText),
      DropField('Téléphone', controller: phone, hint: '06 00 00 00 00', icon: Icons.phone_android_rounded,
        keyboard: TextInputType.phone, validate: validPhone, action: TextInputAction.done),
      DropButton('Créer ma boutique', icon: Icons.check_rounded, onPressed: submit),
    ])),
  ]);
}

/// 44 · Boutique prête
class ShopReadyPage extends StatelessWidget {
  const ShopReadyPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    return SuccessLayout(icon: Icons.storefront_outlined, title: 'Votre boutique est prête !',
      subtitle: 'Félicitations ! Vous pouvez publier votre première Vitrine Flash.', children: [
        SurfaceCard(child: StackColumn(gap: 4, [
          ValueRow('Boutique', state.shop.name, valueColor: ink),
          ValueRow('Abonnement', '', valueWidget: StatusPill(state.plan.short)),
          const ValueRow('Commission', '0 %', valueColor: ink),
        ])),
        const SizedBox(height: 18),
        DropButton('Créer ma première vitrine', icon: Icons.bolt_outlined,
          onPressed: () => goAya(context, AyaScreen.newShowcase)),
        const SizedBox(height: 10),
        DropButton('Voir mon tableau de bord', style: ActionStyle.outline,
          onPressed: () => jumpAya(context, AyaScreen.dashboard)),
      ]);
  }
}

/// 45 · Tableau de bord
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final live = state.live;
    return PageScroll(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(18)),
        child: StackColumn(gap: 6, [
          Text('Bonjour, ${state.merchantName}', style: const TextStyle(color: Color(0xFFD5E5DB), fontSize: 14)),
          Text(state.shop.name, style: headingStyle.copyWith(color: Colors.white, fontSize: 25)),
          const Text('Une belle journée pour réduire le gaspillage.',
            style: TextStyle(color: Color(0xFFD5E5DB), fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _StatTile(Icons.shopping_cart_outlined, '${state.sold} / ${live.quantity}', 'Paniers vendus')),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(Icons.show_chart_rounded, euros(state.sold * live.price, compact: true), 'Ventes du jour')),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _StatTile(Icons.qr_code_scanner_rounded, '${state.sold}', 'À remettre')),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(Icons.schedule_rounded, pickupTime(live.pickupUntil), 'Fin de vitrine')),
      ]),
      const SizedBox(height: 14),
      DropButton('Publier une Vitrine Flash', icon: Icons.bolt_outlined,
        onPressed: () => goAya(context, AyaScreen.newShowcase)),
      const SizedBox(height: 12),
      const SectionTitle('Vitrine du jour', trailing: Text('En cours',
        style: TextStyle(color: success, fontSize: 13, fontWeight: FontWeight.w600))),
      SurfaceCard(child: StackColumn(gap: 8, [
        Row(children: [
          Expanded(child: Text(live.title, style: strongStyle.copyWith(fontSize: 17))),
          const SizedBox(width: 8),
          const StatusPill('ACTIVE', solid: true),
        ]),
        Text('${state.sold} panier${state.sold > 1 ? 's' : ''} vendu${state.sold > 1 ? 's' : ''} sur ${live.quantity}'
          ' · Retrait avant ${pickupTime(live.pickupUntil)}', style: copyStyle.copyWith(fontSize: 13)),
        ProgressLine(state.sold / live.quantity, label: 'Paniers vendus'),
        const SizedBox(height: 2),
        DropButton('Voir ma vitrine', icon: Icons.chevron_right_rounded, style: ActionStyle.outline,
          onPressed: () => openTeamLink(context, TeamLink.activeShowcase)),
      ])),
      const SizedBox(height: 12),
      const SectionTitle('Commandes récentes'),
      for (final order in state.recentOrders.take(state.sold))
        AccountRow(Icons.receipt_long_outlined, 'Commande #${order.number}',
          '${order.customer} · ${euros(order.price)} · retrait ${pickupTime(order.pickup)}',
          () => openTeamLink(context, TeamLink.merchantOrderDetail)),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.icon, this.value, this.label);
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => Semantics(label: '$label : $value', excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(16)),
      child: StackColumn(gap: 6, [
        Align(alignment: Alignment.centerLeft, child: Icon(icon, size: 22, color: forest)),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(value, style: headingStyle.copyWith(fontSize: 27, color: forest, letterSpacing: -.6))),
        Text(label, style: copyStyle.copyWith(fontSize: 12, height: 1.2)),
      ]),
    ));
}
