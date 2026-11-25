import 'package:flutter/material.dart';

import '../../../src/account_pages.dart' show AccountRow;
import '../../../src/ui.dart';
import '../aya_navigation.dart';
import '../aya_screens.dart';
import '../controllers/achat_boutique_controller.dart';
import '../models/achat_boutique_models.dart';
import '../widgets/achat_widgets.dart';

/// 62 · Profil de la boutique
class ShopProfilePage extends StatelessWidget {
  const ShopProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final shop = state.shop;
    return PageScroll(children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const ShopLogo(size: 64),
          const SizedBox(width: 16),
          Expanded(child: StackColumn(gap: 6, [
            Text(shop.name, style: headingStyle.copyWith(fontSize: 21, letterSpacing: -.6)),
            Text('Commerce partenaire · ${shop.city}', style: copyStyle.copyWith(fontSize: 13)),
          ])),
        ]),
      ),
      const SizedBox(height: 10),
      const SectionTitle('Ma boutique'),
      AccountRow(Icons.storefront_outlined, 'Informations du commerce', 'Nom, catégorie, adresse',
        () => goAya(context, AyaScreen.editShop)),
      AccountRow(Icons.schedule_rounded, 'Horaires et retrait', 'Horaires habituels et limites',
        () => goAya(context, AyaScreen.shopHours)),
      AccountRow(Icons.credit_card_rounded, 'Mon abonnement',
        '${state.plan.short} · ${state.plan.monthly} € / mois', () => openTeamLink(context, TeamLink.subscription)),
      AccountRow(Icons.group_outlined, 'Mon équipe', '2 collaborateurs',
        () => openTeamLink(context, TeamLink.shopTeam)),
      const SizedBox(height: 12),
      const SectionTitle('Gestion'),
      AccountRow(Icons.receipt_long_outlined, 'Facturation', '', () => openTeamLink(context, TeamLink.billing)),
      AccountRow(Icons.settings_outlined, 'Paramètres', '', () => openTeamLink(context, TeamLink.merchantSettings)),
      AccountRow(Icons.help_outline_rounded, 'Aide commerçant', '', () => openTeamLink(context, TeamLink.merchantSupport)),
    ]);
  }
}
