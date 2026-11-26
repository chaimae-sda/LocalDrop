import 'package:flutter/material.dart';

import '../../main.dart' show LocalDropApp;
import '../../src/account_pages.dart' show AccountRow;
import '../../src/screens.dart' show DropScreen;
import '../../src/ui.dart';
import '../achat_boutique/aya_navigation.dart';
import '../achat_boutique/aya_screens.dart';
import '../achat_boutique/controllers/achat_boutique_controller.dart';
import '../achat_boutique/models/achat_boutique_models.dart';
import '../achat_boutique/widgets/achat_widgets.dart';
import 'merchant_screen.dart';
import 'merchant_widgets.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});
  @override
  Widget build(BuildContext context) {
    final plan = AchatBoutiqueScope.of(context).plan;
    return MerchantBody([
      SurfaceCard(
        color: mint,
        child: StackColumn(gap: 8, [
          Row(
            children: [
              Expanded(child: Text(plan.short, style: strongStyle)),
              Text(
                '${plan.monthly} €/mois',
                style: strongStyle.copyWith(color: forest),
              ),
            ],
          ),
          const Text('Votre abonnement', style: copyStyle),
        ]),
      ),
      const Text('Avantages inclus', style: strongStyle),
      for (final perk in plan.perks)
        Row(
          children: [
            const Icon(Icons.check_circle_outline, color: success, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(perk)),
          ],
        ),
      const Text('Prochaine échéance', style: strongStyle),
      SurfaceCard(
        child: plan == ShopPlan.discovery
            ? const Text('Formule gratuite')
            : Column(
                children: [
                  const ValueRow('Date', '23 décembre 2026'),
                  ValueRow('Montant', euros(plan.monthly.toDouble())),
                ],
              ),
      ),
      DropButton(
        'Changer de formule',
        style: ActionStyle.outline,
        icon: Icons.edit_outlined,
        onPressed: () => goAya(context, AyaScreen.plans),
      ),
      DropButton(
        'Consulter les factures',
        style: ActionStyle.outline,
        onPressed: () => openMerchant(context, MerchantScreen.billing),
      ),
    ]);
  }
}

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final plan = shop.plan;
    return MerchantBody([
      SurfaceCard(
        color: mint,
        child: Column(
          children: [
            ValueRow(plan.title, '', valueWidget: const StatusPill('ACTIF')),
            ValueRow('Tarif mensuel', euros(plan.monthly.toDouble())),
            ValueRow(
              'Prochaine facture',
              plan == ShopPlan.premium ? '23 déc. 2026' : 'Formule gratuite',
            ),
          ],
        ),
      ),
      const Text('Factures', style: strongStyle),
      for (final month in const [
        'Novembre 2026',
        'Octobre 2026',
        'Septembre 2026',
      ])
        AccountRow(
          Icons.receipt_long_outlined,
          month,
          'Payée · 15,00 €',
          () => showDialog<void>(
            context: context,
            builder: (dialog) => AlertDialog(
              title: Text(month),
              content: const Text(
                'Abonnement Premium\nMontant payé 15,00 €\nFacture de démonstration',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialog),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        ),
      const Text('Informations de paiement', style: strongStyle),
      SurfaceCard(child: ValueRow('Abonnement', 'Visa ···· 4242')),
    ]);
  }
}

class MerchantSettingsPage extends StatelessWidget {
  const MerchantSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => MerchantBody([
    const Text('Boutique', style: strongStyle),
    AccountRow(
      Icons.storefront_outlined,
      'Profil de la boutique',
      '',
      () => goAya(context, AyaScreen.shopProfile),
    ),
    AccountRow(
      Icons.notifications_none_outlined,
      'Notifications',
      '',
      () => goAya(context, AyaScreen.shopAlerts),
    ),
    AccountRow(
      Icons.groups_outlined,
      'Gérer mon équipe',
      '',
      () => openMerchant(context, MerchantScreen.team),
    ),
    AccountRow(
      Icons.credit_card_outlined,
      'Abonnement et facturation',
      '',
      () => openMerchant(context, MerchantScreen.plan),
    ),
    const Text('Assistance', style: strongStyle),
    AccountRow(
      Icons.help_outline,
      'Centre d’aide',
      '',
      () => openMerchant(context, MerchantScreen.support),
    ),
    AccountRow(
      Icons.shield_outlined,
      'Confidentialité',
      '',
      () => showDialog<void>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('Confidentialité'),
          content: const Text(
            'Les données de cette démonstration durent le temps de la session.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    ),
    AccountRow(Icons.logout, 'Se déconnecter', '', () async {
      if (!await confirmAction(
        context,
        'Quitter l’espace commerçant ?',
        'Vous reviendrez à l’écran de connexion.',
        'Se déconnecter',
      ))
        return;
      if (context.mounted)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const LocalDropApp(startAt: DropScreen.login),
          ),
          (_) => false,
        );
    }),
  ]);
}

class MerchantSupportPage extends StatefulWidget {
  const MerchantSupportPage({super.key});
  @override
  State<MerchantSupportPage> createState() => _MerchantSupportPageState();
}

class _MerchantSupportPageState extends State<MerchantSupportPage> {
  final form = GlobalKey<FormState>();
  final message = TextEditingController();
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    return Form(
      key: form,
      child: MerchantBody([
        SurfaceCard(
          color: mint,
          child: StackColumn(center: true, [
            const Icon(Icons.help_outline, color: forest, size: 36),
            Text(
              'Besoin d’un coup de main ?',
              style: strongStyle.copyWith(fontSize: 19),
            ),
          ]),
        ),
        AccountRow(
          Icons.bolt_outlined,
          'Comment publier une vitrine ?',
          'Photo, prix, quantité et horaire',
          () => goAya(context, AyaScreen.newShowcase),
        ),
        AccountRow(
          Icons.qr_code_scanner,
          'Comment valider un retrait ?',
          'QR et code de secours',
          () => openMerchant(context, MerchantScreen.scan),
        ),
        AccountRow(
          Icons.credit_card_outlined,
          'Comment gérer mon abonnement ?',
          'Formules et facturation',
          () => openMerchant(context, MerchantScreen.plan),
        ),
        const Text('Parler à LocalDrop', style: strongStyle),
        DropField(
          'Votre message',
          controller: message,
          hint: 'Décrivez votre demande…',
          lines: 3,
          validate: requiredText,
        ),
        DropButton(
          'Enregistrer ma demande',
          icon: Icons.mail_outline,
          onPressed: () {
            if (!form.currentState!.validate()) return;
            shop.recordSupportMessage(message.text);
            message.clear();
            form.currentState!.reset();
            feedback(context, 'Demande enregistrée dans la démo.');
          },
        ),
        if (shop.supportMessages.isNotEmpty)
          InfoBanner('Dernière demande · ${shop.supportMessages.last}'),
      ]),
    );
  }
}

class ShopTeamPage extends StatefulWidget {
  const ShopTeamPage({super.key});
  @override
  State<ShopTeamPage> createState() => _ShopTeamPageState();
}

class _ShopTeamPageState extends State<ShopTeamPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    return Form(
      key: form,
      child: MerchantBody([
        const SectionTitle(
          'Membres de la boutique',
          trailing: Text('2 membres', style: copyStyle),
        ),
        for (final member in const [
          ('NA', 'Nadia A.', 'Propriétaire', 'ADMIN'),
          ('LM', 'Louis M.', 'Validation des retraits', 'ACTIF'),
        ])
          SurfaceCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: mint,
                  child: Text(
                    member.$1,
                    style: strongStyle.copyWith(color: forest),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.$2, style: strongStyle),
                      Text(member.$3, style: copyStyle),
                    ],
                  ),
                ),
                StatusPill(member.$4),
              ],
            ),
          ),
        const Text('Inviter un collaborateur', style: strongStyle),
        DropField(
          'Adresse e-mail',
          controller: email,
          hint: 'collegue@exemple.fr',
          keyboard: TextInputType.emailAddress,
          validate: validEmail,
        ),
        DropButton(
          'Créer une invitation',
          icon: Icons.person_add_alt,
          onPressed: () {
            if (!form.currentState!.validate()) return;
            final error = shop.invite(email.text);
            if (error != null) {
              feedback(context, error);
              return;
            }
            email.clear();
            form.currentState!.reset();
            feedback(
              context,
              'Invitation ajoutée à la session de démonstration.',
            );
          },
        ),
        if (shop.invitations.isNotEmpty) ...[
          const Text('Invitations en attente', style: strongStyle),
          for (final email in shop.invitations) SurfaceCard(child: Text(email)),
        ],
      ]),
    );
  }
}
