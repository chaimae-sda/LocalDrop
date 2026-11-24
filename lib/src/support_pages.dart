import 'package:flutter/material.dart';

import 'account_pages.dart';
import 'demo.dart';
import 'navigation.dart';
import 'screens.dart';
import 'ui.dart';

class _HelpHeader extends StatelessWidget {
  const _HelpHeader(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => SurfaceCard(color: mint, padding: 22, child: StackColumn(center: true, gap: 8, [
    Icon(icon, size: 34, color: forest), Text(title, style: strongStyle.copyWith(color: forest, fontSize: 18), textAlign: TextAlign.center),
    Text(subtitle, style: copyStyle.copyWith(fontSize: 12), textAlign: TextAlign.center),
  ]));
}

const _questions = [
  (Icons.qr_code_scanner_rounded, 'Comment récupérer mon panier ?', 'Avec le QR code ou le code à 4 chiffres',
   'Dans vos commandes, ouvrez le pass de retrait. Présentez le QR code au commerçant pendant le créneau indiqué. Il peut aussi saisir votre code à quatre chiffres.'),
  (Icons.credit_card_outlined, 'Comment fonctionne le paiement ?', 'Directement dans l’application',
   'Dans le parcours d’achat, choisissez votre panier, vérifiez le récapitulatif et sélectionnez votre moyen de paiement avant de confirmer la réservation.'),
  (Icons.access_time_rounded, 'Que se passe-t-il si je suis en retard ?', 'Contactez le commerçant ou le support',
   'Prévenez le commerce dès que possible. Si vous avez besoin d’aide, indiquez le numéro de commande et le créneau de retrait dans votre message au support.'),
];

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int? open;
  @override
  Widget build(BuildContext context) => PageScroll(children: [
    const _HelpHeader(Icons.help_outline_rounded, 'Comment pouvons-nous vous aider ?', 'Réponses aux questions fréquentes.'),
    const SizedBox(height: 14),
    for (var i = 0; i < _questions.length; i++) ...[
      AccountRow(_questions[i].$1, _questions[i].$2, _questions[i].$3,
        () => setState(() => open = open == i ? null : i),
        trailing: open == i ? Icons.expand_less_rounded : Icons.expand_more_rounded),
      if (open == i) Padding(padding: const EdgeInsets.fromLTRB(12, 9, 12, 16),
        child: Text(_questions[i].$4, style: copyStyle)),
    ],
    AccountRow(Icons.mail_outline_rounded, 'Nous contacter', 'Une question supplémentaire ?', () => go(context, DropScreen.contact)),
  ]);
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final order = TextEditingController();
  final message = TextEditingController();
  bool initialized = false;
  bool complete = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      email.text = DemoScope.of(context).email;
      initialized = true;
    }
  }
  @override
  void dispose() { email.dispose(); order.dispose(); message.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => PageScroll(children: [
    const _HelpHeader(Icons.mail_outline_rounded, 'Contactez-nous', 'Notre équipe vous accompagne.'),
    const SizedBox(height: 16),
    if (complete) SurfaceCard(child: StackColumn([
      const Icon(Icons.check_circle_outline_rounded, color: success, size: 38),
      const Text('Demande simulée', style: strongStyle, textAlign: TextAlign.center),
      const Text('Votre message a été validé dans cet aperçu local.', style: copyStyle, textAlign: TextAlign.center),
      DropButton('Retour au centre d’aide', onPressed: () => jump(context, DropScreen.help)),
    ])) else Form(key: form, child: StackColumn(gap: 14, [
      StackColumn(gap: 6, [
        const FieldLabel('Sujet'),
        DropdownButtonFormField<String>(
          isExpanded: true, hint: const Text('Choisir un sujet'), validator: requiredText, onChanged: (_) {},
          items: [for (final option in ['Retrait d’un panier', 'Paiement', 'Mon compte', 'Autre question'])
            DropdownMenuItem(value: option, child: Text(option))],
        ),
      ]),
      DropField('Votre adresse e-mail', controller: email, icon: Icons.mail_outline_rounded,
        keyboard: TextInputType.emailAddress, validate: validEmail),
      DropField('Numéro de commande (facultatif)', controller: order, hint: '#1042', icon: Icons.receipt_long_outlined),
      DropField('Votre message', controller: message, hint: 'Décrivez votre demande…', lines: 4, validate: requiredText),
      DropButton('Envoyer ma demande', icon: Icons.mail_outline_rounded, onPressed: () {
        if (!form.currentState!.validate()) return;
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() => complete = true);
      }),
    ])),
  ]);
}
