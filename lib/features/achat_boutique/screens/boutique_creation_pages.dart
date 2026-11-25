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

/// 46 · Nouvelle Vitrine Flash
class NewShowcasePage extends StatefulWidget {
  const NewShowcasePage({super.key});
  @override
  State<NewShowcasePage> createState() => _NewShowcasePageState();
}

class _NewShowcasePageState extends State<NewShowcasePage> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController();
  final initial = TextEditingController();
  final price = TextEditingController();
  late int quantity;
  late TimeOfDay pickup;
  var initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    final draft = AchatBoutiqueScope.of(context).draft;
    title.text = draft.title;
    initial.text = euros(draft.initialValue);
    price.text = euros(draft.price);
    quantity = draft.quantity;
    pickup = draft.pickupUntil;
  }

  @override
  void dispose() {
    title.dispose(); initial.dispose(); price.dispose();
    super.dispose();
  }

  String? validInitial(String? value) =>
      (parseEuros(value) ?? 0) <= 0 ? 'Saisissez un montant.' : null;

  String? validPrice(String? value) {
    final flash = parseEuros(value);
    if (flash == null || flash <= 0) return 'Saisissez un montant.';
    final base = parseEuros(initial.text);
    if (base != null && flash >= base) return 'Inférieur à la valeur initiale.';
    return null;
  }

  /// Garde la saisie dans le brouillon pendant le passage par l’écran photo.
  void saveDraft(AchatBoutiqueController state) => state.updateDraft(state.draft.copyWith(
    title: title.text.trim().isEmpty ? null : title.text.trim(),
    initialValue: parseEuros(initial.text), price: parseEuros(price.text),
    quantity: quantity, pickupUntil: pickup));

  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final photo = state.draft.photo;
    const amount = TextInputType.numberWithOptions(decimal: true);
    return PageScroll(children: [
      DashedFrame(child: Column(children: [
        const CameraBubble(),
        const SizedBox(height: 12),
        Text(photo == null ? 'Prendre une photo' : 'Photo ajoutée',
          style: strongStyle.copyWith(color: forest, fontSize: 17)),
        const SizedBox(height: 4),
        Text('Hébergée sur le bucket AWS S3', textAlign: TextAlign.center, style: copyStyle.copyWith(fontSize: 12)),
        TextButton(
          onPressed: () {
            saveDraft(state);
            goAya(context, AyaScreen.showcasePhoto);
          },
          style: TextButton.styleFrom(foregroundColor: orangeText),
          child: const Text('Importer / photographier', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
      ])),
      const SizedBox(height: 16),
      Form(key: form, child: StackColumn(gap: 16, [
        DropField('Titre du panier', controller: title, validate: requiredText),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: DropField('Valeur initiale', controller: initial, keyboard: amount, validate: validInitial)),
          const SizedBox(width: 12),
          Expanded(child: DropField('Prix flash', controller: price, keyboard: amount, validate: validPrice)),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: StackColumn(gap: 6, [
            const FieldLabel('Quantité'),
            QuantityStepper(value: quantity, onChanged: (value) => setState(() => quantity = value)),
          ])),
          const SizedBox(width: 12),
          Expanded(child: TimeField('Retrait avant', value: pickup,
            onChanged: (value) => setState(() => pickup = value))),
        ]),
        const InfoBanner('Les riverains proches recevront une alerte'),
        DropButton('Prévisualiser la vitrine', icon: Icons.chevron_right_rounded, onPressed: () {
          if (!form.currentState!.validate()) return;
          saveDraft(state);
          goAya(context, AyaScreen.showcasePreview);
        }),
      ])),
    ]);
  }
}

/// 47 · Photo du panier (la prise de vue est simulée)
class ShowcasePhotoPage extends StatelessWidget {
  const ShowcasePhotoPage({super.key});

  void choose(BuildContext context, AchatBoutiqueController state, PhotoSource source) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    state.choosePhoto(source);
  }

  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final photo = state.draft.photo;
    return PageScroll(children: [
      DashedFrame(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34), child: Column(children: [
        const CameraBubble(size: 72),
        const SizedBox(height: 14),
        Text('Photo du panier', style: strongStyle.copyWith(color: forest, fontSize: 17)),
        const SizedBox(height: 4),
        Text(photo == null ? 'Prenez une photo nette des produits du jour.' : 'Photo sélectionnée.',
          textAlign: TextAlign.center, style: copyStyle.copyWith(fontSize: 13)),
        const SizedBox(height: 16),
        CompactButton('Ouvrir la caméra', onPressed: () => choose(context, state, PhotoSource.camera)),
        const SizedBox(height: 10),
        CompactButton('Choisir depuis la galerie', outline: true,
          onPressed: () => choose(context, state, PhotoSource.gallery)),
      ])),
      const SizedBox(height: 16),
      const InfoBanner('Formats JPG ou PNG · max 10 Mo'),
      const SizedBox(height: 14),
      DropButton('Utiliser cette photo', icon: Icons.check_rounded, onPressed: () {
        if (photo == null) {
          feedback(context, 'Prenez ou choisissez d’abord une photo.');
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          goAya(context, AyaScreen.newShowcase, replace: true);
        }
      }),
    ]);
  }
}

/// 48 · Aperçu de ma vitrine
class ShowcasePreviewPage extends StatelessWidget {
  const ShowcasePreviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final draft = state.draft;
    return PageScroll(children: [
      const SectionTitle('Ce que verront les clients'),
      PhotoPlaceholder(height: 210, discount: draft.discount),
      const SizedBox(height: 14),
      Text(draft.title, style: headingStyle.copyWith(fontSize: 25)),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.storefront_outlined, size: 19, color: forest),
        const SizedBox(width: 6),
        Flexible(child: Text(state.shop.name, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: forest, fontWeight: FontWeight.w800, fontSize: 14))),
        const Text('  ·  200 m', style: TextStyle(color: muted, fontSize: 13)),
      ]),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(18)),
        child: StackColumn(gap: 2, [
          ValueRow('Valeur initiale', '', size: 15, valueWidget: Text(euros(draft.initialValue),
            style: const TextStyle(color: muted, decoration: TextDecoration.lineThrough))),
          ValueRow('Prix Flash', '', size: 15, valueWidget: Text(euros(draft.price),
            style: headingStyle.copyWith(color: orangeText, fontSize: 28, letterSpacing: -.4))),
          ValueRow('Quantité', '${draft.quantity} panier${draft.quantity > 1 ? 's' : ''}', size: 15),
          ValueRow('Retrait avant', pickupTime(draft.pickupUntil), size: 15),
        ]),
      ),
      const SizedBox(height: 14),
      DropButton('Publier la Vitrine Flash', icon: Icons.bolt_outlined, onPressed: () {
        state.publish();
        goAfter(context, AyaScreen.showcasePublished, AyaScreen.dashboard);
      }),
      const SizedBox(height: 10),
      DropButton('Modifier les informations', icon: Icons.edit_outlined, style: ActionStyle.outline,
        onPressed: () => Navigator.of(context).canPop()
            ? Navigator.of(context).pop()
            : goAya(context, AyaScreen.newShowcase, replace: true)),
    ]);
  }
}

/// 49 · Vitrine publiée
class ShowcasePublishedPage extends StatelessWidget {
  const ShowcasePublishedPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final live = state.live;
    final left = live.quantity - state.sold;
    return SuccessLayout(icon: Icons.bolt_rounded, title: 'Votre vitrine est en ligne !',
      subtitle: 'Les habitants à proximité sont informés de vos paniers du jour.', children: [
        SurfaceCard(child: StackColumn(gap: 4, [
          ValueRow(live.title, '', valueWidget: const StatusPill('PUBLIÉE', solid: true)),
          ValueRow('Disponibles', '$left panier${left > 1 ? 's' : ''}'),
          ValueRow('Fin de vente', pickupTime(live.pickupUntil)),
        ])),
        const SizedBox(height: 18),
        DropButton('Suivre les ventes en direct', icon: Icons.show_chart_rounded,
          onPressed: () => openTeamLink(context, TeamLink.activeShowcase)),
        const SizedBox(height: 10),
        DropButton('Retour au tableau de bord', style: ActionStyle.outline,
          onPressed: () => jumpAya(context, AyaScreen.dashboard)),
      ]);
  }
}
