import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../src/account_pages.dart' show AccountRow;
import '../../../src/ui.dart';
import '../aya_navigation.dart';
import '../aya_screens.dart';
import '../controllers/achat_boutique_controller.dart';
import '../models/achat_boutique_models.dart';
import '../widgets/achat_widgets.dart';

/// 22 · Mon panier
class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final offer = state.offer;
    return PageScroll(children: [
      const SectionTitle('Ma réservation en cours'),
      SurfaceCard(child: StackColumn(gap: 4, [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const SizedBox(width: 72, child: PhotoPlaceholder(height: 72, radius: 14)),
          const Spacer(),
          const StatusPill('1 panier'),
          const Spacer(flex: 2),
        ]),
        const SizedBox(height: 6),
        Text(offer.title, style: strongStyle.copyWith(fontSize: 15)),
        Text(offer.shop, style: copyStyle.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        ValueRow('Sous-total', euros(offer.price)),
        ValueRow('Frais de service', euros(state.serviceFee)),
        const Divider(height: 18, color: line),
        ValueRow('Total à payer', euros(state.total), strong: true),
      ])),
      const SizedBox(height: 14),
      const InfoBanner('Aucune commission facturée au commerçant'),
      const SizedBox(height: 14),
      DropButton('Continuer', icon: Icons.chevron_right_rounded,
        onPressed: () => goAya(context, AyaScreen.checkout)),
    ]);
  }
}
