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

/// 63 · Modifier la boutique
class EditShopPage extends StatefulWidget {
  const EditShopPage({super.key});
  @override
  State<EditShopPage> createState() => _EditShopPageState();
}

class _EditShopPageState extends State<EditShopPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final category = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  var initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    final shop = AchatBoutiqueScope.of(context).shop;
    name.text = shop.name;
    category.text = shop.category;
    address.text = shop.address;
    phone.text = shop.phone;
  }

  @override
  void dispose() {
    name.dispose(); category.dispose(); address.dispose(); phone.dispose();
    super.dispose();
  }

  void save() {
    if (!form.currentState!.validate()) return;
    AchatBoutiqueScope.of(context).saveShop(ShopInfo(name: name.text.trim(), category: category.text.trim(),
      address: address.text.trim(), phone: phone.text.trim()));
    final nav = Navigator.of(context);
    nav.canPop() ? nav.pop() : goAya(context, AyaScreen.shopProfile, replace: true);
  }

  @override
  Widget build(BuildContext context) => PageScroll(children: [
    const Center(child: ShopLogo(size: 76)),
    TextButton.icon(onPressed: () => feedback(context, 'Choix du logo simulé.'),
      style: TextButton.styleFrom(foregroundColor: success),
      icon: const Icon(Icons.photo_camera_outlined, size: 17), label: const Text('Changer le logo')),
    const SizedBox(height: 6),
    Form(key: form, child: StackColumn(gap: 14, [
      DropField('Nom du commerce', controller: name, icon: Icons.storefront_outlined, validate: requiredText),
      DropField('Catégorie', controller: category, icon: Icons.storefront_outlined, validate: requiredText),
      DropField('Adresse', controller: address, icon: Icons.location_on_outlined, validate: requiredText),
      DropField('Numéro de téléphone', controller: phone, icon: Icons.phone_android_rounded,
        keyboard: TextInputType.phone, validate: validPhone, action: TextInputAction.done),
      DropButton('Enregistrer', icon: Icons.check_rounded, onPressed: save),
    ])),
  ]);
}
