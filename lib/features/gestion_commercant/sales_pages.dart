import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../src/ui.dart';
import '../achat_boutique/controllers/achat_boutique_controller.dart';
import '../achat_boutique/models/achat_boutique_models.dart';
import '../achat_boutique/widgets/achat_widgets.dart';
import 'merchant_screen.dart';
import 'merchant_widgets.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int days = 7;
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final series = shop.salesDays(days);
    final amount = series.fold(0, (n, d) => n + d.cents);
    final sold = series.fold(0, (n, d) => n + d.sold);
    final rescued = series.fold(0, (n, d) => n + d.collected);
    final capacity = series.fold(0, (n, d) => n + d.capacity);
    final published = series.fold(0, (n, d) => n + d.shops);
    final metrics = [
      (
        Icons.show_chart,
        euros(amount / 100, compact: true),
        'Chiffre d’affaires',
      ),
      (Icons.shopping_bag_outlined, '$rescued', 'Paniers retirés'),
      (Icons.done, '${(100 * sold / capacity).round()} %', 'Taux de vente'),
      (Icons.bolt_outlined, '$published', 'Vitrines publiées'),
    ];
    final group = days == 7
        ? 1
        : days == 30
        ? 6
        : 15;
    final start = shop.shopTime.subtract(Duration(days: days - 1));
    final bars = [
      for (var i = 0; i < days; i += group)
        (
          start.add(Duration(days: i)),
          series.skip(i).take(group).fold(0, (n, d) => n + d.cents),
        ),
    ];
    final peak = bars.map((b) => b.$2).reduce(math.max);
    return MerchantBody([
      SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: 7, label: Text('7 jours')),
          ButtonSegment(value: 30, label: Text('30 jours')),
          ButtonSegment(value: 90, label: Text('3 mois')),
        ],
        selected: {days},
        onSelectionChanged: (n) => setState(() => days = n.single),
      ),
      for (var i = 0; i < metrics.length; i += 2)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, item) in metrics.skip(i).take(2).indexed) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(
                child: SurfaceCard(
                  color: mint,
                  padding: 12,
                  child: StackColumn(gap: 4, [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(item.$1, color: forest, size: 20),
                    ),
                    Text(
                      item.$2,
                      style: headingStyle.copyWith(fontSize: 23, color: forest),
                    ),
                    Text(item.$3, style: copyStyle.copyWith(fontSize: 12)),
                  ]),
                ),
              ),
            ],
          ],
        ),
      const Text('Évolution des ventes', style: strongStyle),
      SurfaceCard(
        child: StackColumn(gap: 10, [
          Text(
            group == 1
                ? 'Montant encaissé par jour'
                : 'Montant encaissé par période de $group jours',
            style: copyStyle,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (date, cents) in bars)
                Expanded(
                  child: Tooltip(
                    message:
                        '${date.day}/${date.month} · ${euros(cents / 100)}',
                    child: Semantics(
                      label:
                          'Période du ${date.day}/${date.month}, ${euros(cents / 100)}',
                      child: Column(
                        children: [
                          Container(
                            height: 90 * cents / peak,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: success,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ]),
      ),
      DropButton(
        'Voir les ventes',
        style: ActionStyle.outline,
        icon: Icons.receipt_long_outlined,
        onPressed: () => openMerchant(context, MerchantScreen.sales),
      ),
    ]);
  }
}

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final month = shop.salesDays(shop.shopTime.day);
    final amount = month.fold(0, (sum, day) => sum + day.cents);
    return MerchantBody([
      SurfaceCard(
        color: mint,
        child: StackColumn(gap: 4, [
          ValueRow('Ventes de novembre', euros(amount / 100), strong: true),
          const Text('0 % de commission sur les ventes', style: copyStyle),
        ]),
      ),
      const Text('Dernières transactions', style: strongStyle),
      for (final ticket in shop.tickets)
        SurfaceCard(
          child: InkWell(
            onTap: () => openMerchant(
              context,
              MerchantScreen.detail,
              order: ticket.order.number,
            ),
            child: StackColumn(gap: 4, [
              ValueRow(
                '#${ticket.order.number} · ${ticket.order.customer}',
                euros(ticket.order.price),
              ),
              Text(
                shop.isCollected(ticket)
                    ? 'Payée · Retirée'
                    : 'Payée · À remettre',
                style: copyStyle,
              ),
            ]),
          ),
        ),
      for (final sale in const [
        ('#1037 · Amélie R.', '4,90 €'),
        ('#1032 · Marc B.', '8,50 €'),
      ])
        SurfaceCard(
          child: StackColumn(gap: 4, [
            ValueRow(sale.$1, sale.$2),
            const Text('Payée · Retirée', style: copyStyle),
          ]),
        ),
      DropButton(
        'Consulter les factures',
        style: ActionStyle.outline,
        onPressed: () => openMerchant(context, MerchantScreen.billing),
      ),
    ]);
  }
}
