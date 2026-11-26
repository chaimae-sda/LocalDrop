import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../src/ui.dart';
import '../achat_boutique/aya_navigation.dart';
import '../achat_boutique/aya_screens.dart';
import '../achat_boutique/controllers/achat_boutique_controller.dart';
import '../achat_boutique/models/achat_boutique_models.dart';
import '../achat_boutique/widgets/achat_widgets.dart';
import 'merchant_operations.dart';
import 'merchant_screen.dart';
import 'merchant_widgets.dart';
import 'pickup_pages.dart';

String baskets(int count) => '$count panier${count > 1 ? 's' : ''}';

class ShowcaseSummary extends StatelessWidget {
  const ShowcaseSummary({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final live = shop.live;
    return SurfaceCard(
      color: mint,
      child: StackColumn(gap: 9, [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            StatusPill(
              shop.closed ? 'TERMINÉE' : 'VITRINE EN COURS',
              solid: !shop.closed,
            ),
            Text(
              'Fin à ${pickupTime(live.pickupUntil)}',
              style: copyStyle.copyWith(fontSize: 12),
            ),
          ],
        ),
        Text(live.title, style: strongStyle.copyWith(fontSize: 16)),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${shop.sold}',
                style: headingStyle.copyWith(color: forest, fontSize: 36),
              ),
              TextSpan(
                text: ' / ${live.quantity} paniers vendus',
                style: copyStyle,
              ),
            ],
          ),
        ),
        ProgressLine(shop.sold / live.quantity, label: 'Paniers vendus'),
        Text(
          '${euros(live.price)} par panier · ${euros(shop.liveCents / 100)} encaissés',
          style: copyStyle.copyWith(fontSize: 13),
        ),
      ]),
    );
  }
}

class LiveShowcasePage extends StatelessWidget {
  const LiveShowcasePage({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    return MerchantBody([
      const ShowcaseSummary(),
      Row(
        children: [
          const Expanded(
            child: Text('Commandes à remettre', style: strongStyle),
          ),
          TextButton(
            onPressed: () => openMerchant(context, MerchantScreen.orders),
            child: const Text('Voir tout'),
          ),
        ],
      ),
      for (final ticket in shop.livePending) OrderCard(ticket),
      if (shop.livePending.isEmpty)
        DropButton(
          shop.sold == 0
              ? 'En attente de commandes'
              : 'Voir le suivi des retraits',
          style: ActionStyle.outline,
          onPressed: () => openMerchant(context, MerchantScreen.empty),
        ),
      if (!shop.closed)
        DropButton(
          'Modifier cette vitrine',
          style: ActionStyle.outline,
          icon: Icons.edit_outlined,
          onPressed: () => openMerchant(context, MerchantScreen.edit),
        ),
      DropButton(
        'Gérer les quantités',
        style: ActionStyle.outline,
        icon: Icons.inventory_2_outlined,
        onPressed: () => openMerchant(context, MerchantScreen.stock),
      ),
    ]);
  }
}

class ShowcasesPage extends StatelessWidget {
  const ShowcasesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    return MerchantBody([
      DropButton(
        'Nouvelle Vitrine Flash',
        icon: Icons.add,
        onPressed: () => goAya(context, AyaScreen.newShowcase),
      ),
      const Text('Aujourd’hui', style: strongStyle),
      const ShowcaseSummary(),
      DropButton(
        'Consulter',
        style: ActionStyle.outline,
        icon: Icons.chevron_right,
        onPressed: () => openMerchant(context, MerchantScreen.live),
      ),
      const Text('Mes anciennes vitrines', style: strongStyle),
      for (final entry in [
        ...shop.pastShowcases,
        const PastShowcase('Panier du Jour', 3, 3),
      ])
        SurfaceCard(
          child: StackColumn(gap: 6, [
            Row(
              children: [
                Expanded(child: Text(entry.title, style: strongStyle)),
                const StatusPill('TERMINÉE'),
              ],
            ),
            Text(
              '${entry.sold} / ${baskets(entry.quantity)} vendus',
              style: copyStyle,
            ),
          ]),
        ),
      DropButton(
        'Gérer les quantités',
        style: ActionStyle.outline,
        icon: Icons.inventory_2_outlined,
        onPressed: () => openMerchant(context, MerchantScreen.stock),
      ),
    ]);
  }
}

class EditShowcasePage extends StatefulWidget {
  const EditShowcasePage({super.key});
  @override
  State<EditShowcasePage> createState() => _EditShowcasePageState();
}

class _EditShowcasePageState extends State<EditShowcasePage> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(), price = TextEditingController();
  TimeOfDay? until;
  int available = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (until != null) return;
    final shop = AchatBoutiqueScope.of(context);
    title.text = shop.live.title;
    price.text = euros(shop.live.price).replaceAll(' €', '');
    until = shop.live.pickupUntil;
    available = shop.remaining;
  }

  @override
  void dispose() {
    title.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    if (shop.closed)
      return const MerchantBody([InfoBanner('Cette vitrine est terminée.')]);
    return Form(
      key: form,
      child: MerchantBody([
        const InfoBanner('La vitrine est visible par les clients.'),
        DropField('Titre', controller: title, validate: requiredText),
        DropField(
          'Prix Flash (€)',
          controller: price,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validate: (text) {
            final amount = parseEuros(text);
            if (amount == null || amount <= 0)
              return 'Saisissez un prix positif.';
            return amount > shop.live.initialValue
                ? 'Le prix dépasse la valeur du panier.'
                : null;
          },
        ),
        TimeField(
          'Retrait avant',
          value: until!,
          onChanged: (time) => setState(() => until = time),
        ),
        const FieldLabel('Quantité encore disponible'),
        QuantityStepper(
          value: available,
          min: shop.sold == 0 ? 1 : 0,
          max: 99 - shop.sold,
          onChanged: (n) => setState(() => available = n),
        ),
        DropButton(
          'Enregistrer les modifications',
          icon: Icons.check,
          onPressed: () {
            if (!form.currentState!.validate()) return;
            final ok = shop.updateLive(
              shop.live.copyWith(
                title: title.text.trim(),
                price: parseEuros(price.text),
                pickupUntil: until,
                quantity: shop.sold + available,
              ),
            );
            if (ok) openMerchant(context, MerchantScreen.live, replace: true);
          },
        ),
        DropButton(
          'Terminer la vitrine',
          style: ActionStyle.outline,
          icon: Icons.schedule,
          onPressed: () async {
            if (!await confirmAction(
              context,
              'Terminer la vitrine ?',
              'Les commandes déjà payées pourront toujours être retirées.',
              'Terminer',
            ))
              return;
            if (!context.mounted) return;
            shop.endShowcase();
            openMerchant(context, MerchantScreen.showcases, replace: true);
          },
        ),
      ]),
    );
  }
}

class StockPage extends StatefulWidget {
  const StockPage({super.key});
  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  int? draft;
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    return MerchantBody([
      SurfaceCard(
        child: StackColumn(gap: 4, [
          Text(shop.live.title, style: strongStyle),
          ValueRow('Stock total', baskets(shop.live.quantity)),
          ValueRow('Déjà vendus', baskets(shop.sold)),
          ValueRow('Restants', baskets(shop.remaining)),
          ProgressLine(shop.sold / shop.live.quantity, label: 'Stock réservé'),
        ]),
      ),
      if (shop.closed)
        const InfoBanner(
          'La vente est terminée. Les retraits restent disponibles.',
        )
      else ...[
        const Text('Ajuster le stock', style: strongStyle),
        const FieldLabel('Quantité totale'),
        QuantityStepper(
          value: draft ?? shop.live.quantity,
          min: math.max(1, shop.sold),
          onChanged: (n) => setState(() => draft = n),
        ),
        Text(
          'La quantité totale inclut les ${baskets(shop.sold)} déjà réservés.',
          style: copyStyle,
        ),
        DropButton(
          'Mettre le stock à jour',
          icon: Icons.check,
          onPressed: () {
            if (shop.updateLive(
              shop.live.copyWith(quantity: draft ?? shop.live.quantity),
            )) {
              openMerchant(context, MerchantScreen.live, replace: true);
            }
          },
        ),
      ],
    ]);
  }
}

class EmptyOrdersPage extends StatelessWidget {
  const EmptyOrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final waiting = shop.sold == 0 && !shop.closed;
    final title = waiting
        ? 'Les premières commandes arrivent bientôt !'
        : shop.livePending.isEmpty
        ? 'Tous les retraits sont à jour'
        : 'Des paniers attendent leur client';
    return SuccessLayout(
      icon: Icons.inventory_2_outlined,
      title: title,
      subtitle: waiting
          ? 'Votre vitrine est en ligne dans le quartier.'
          : '${shop.livePending.length} commande(s) à remettre sur cette vitrine.',
      children: [
        InfoBanner(
          '${baskets(shop.forSale)} en vente · fin à ${pickupTime(shop.live.pickupUntil)}',
        ),
        const SizedBox(height: 14),
        DropButton(
          'Suivre ma vitrine',
          icon: Icons.show_chart,
          onPressed: () => openMerchant(context, MerchantScreen.live),
        ),
        const SizedBox(height: 10),
        DropButton(
          'Publier une autre offre',
          style: ActionStyle.outline,
          icon: Icons.add,
          onPressed: () => goAya(context, AyaScreen.newShowcase),
        ),
      ],
    );
  }
}
