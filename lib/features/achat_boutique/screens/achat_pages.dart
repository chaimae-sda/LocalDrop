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

/// 23 · Récapitulatif
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final offer = state.offer;
    return PageScroll(children: [
      const SectionTitle('Votre panier'),
      SurfaceCard(child: StackColumn(gap: 4, [
        Text(offer.title, style: strongStyle.copyWith(fontSize: 18)),
        Row(children: [
          const Icon(Icons.storefront_outlined, size: 17, color: muted),
          const SizedBox(width: 6),
          Expanded(child: Text(offer.shop, style: copyStyle)),
        ]),
        const Divider(height: 22, color: line),
        ValueRow('Prix du panier', euros(offer.price), size: 15),
        ValueRow('Frais de service', euros(state.serviceFee), size: 15),
        const Divider(height: 22, color: line),
        ValueRow('Total', euros(state.total), strong: true, valueColor: orangeText),
      ])),
      const SizedBox(height: 10),
      const SectionTitle('Retrait du panier'),
      SurfaceCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.calendar_today_outlined, size: 20, color: ink),
        const SizedBox(width: 10),
        Expanded(child: StackColumn(gap: 4, [
          Text('Aujourd’hui, ${pickupTime(offer.pickupFrom)} – ${pickupTime(offer.pickupUntil)}',
            style: strongStyle.copyWith(fontWeight: FontWeight.w600)),
          Text(offer.address, style: copyStyle.copyWith(fontSize: 13)),
        ])),
        const SizedBox(width: 8),
        const StatusPill('Confirmé'),
      ])),
      const SizedBox(height: 10),
      const SectionTitle('Paiement'),
      AccountRow(Icons.credit_card_rounded, 'Carte bancaire',
        '${state.card.brand} se terminant par ${state.card.last4}',
        () => goAya(context, AyaScreen.payment)),
      const SizedBox(height: 16),
      DropButton('Confirmer et payer · ${euros(state.total)}', icon: Icons.lock_outline_rounded,
        onPressed: () => jumpAya(context, AyaScreen.orderConfirmed)),
    ]);
  }
}

/// 24 · Moyen de paiement
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final form = GlobalKey<FormState>();
  final number = TextEditingController();
  final expiry = TextEditingController();
  final cvc = TextEditingController();

  @override
  void dispose() {
    number.dispose(); expiry.dispose(); cvc.dispose();
    super.dispose();
  }

  /// Les champs ne sont contrôlés que si une nouvelle carte est saisie.
  bool get adding => [number, expiry, cvc].any((c) => c.text.trim().isNotEmpty);

  String? validNumber(String? value) {
    if (!adding) return null;
    final digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^\d{13,19}$').hasMatch(digits) && luhnValid(digits) ? null : 'Vérifiez le numéro de carte.';
  }

  String? validExpiry(String? value) {
    if (!adding) return null;
    final match = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch((value ?? '').trim());
    if (match == null) return 'Format MM/AA.';
    final month = int.parse(match[1]!);
    final year = 2000 + int.parse(match[2]!);
    if (month < 1 || month > 12) return 'Mois invalide.';
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) return 'Carte expirée.';
    return null;
  }

  String? validCvc(String? value) {
    if (!adding) return null;
    return RegExp(r'^\d{3,4}$').hasMatch((value ?? '').trim()) ? null : '3 ou 4 chiffres.';
  }

  void pay(AchatBoutiqueController state) {
    if (adding) {
      if (!form.currentState!.validate()) return;
      state.addCard(number.text, expiry.text.replaceAll(' ', ''));
    }
    jumpAya(context, AyaScreen.orderConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final cards = state.cards;
    return PageScroll(children: [
      const SectionTitle('Moyen de paiement'),
      for (var i = 0; i < cards.length; i++) Padding(padding: const EdgeInsets.only(bottom: 10),
        child: Semantics(selected: i == state.selectedCard, button: true,
          child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => state.selectCard(i),
            child: SurfaceCard(child: StackColumn(gap: 4, [
              Row(children: [
                const Icon(Icons.credit_card_rounded, size: 22, color: ink),
                const SizedBox(width: 8),
                Expanded(child: Text('${cards[i].brand} ···· ${cards[i].last4}',
                  style: strongStyle.copyWith(fontSize: 18))),
                if (i == state.selectedCard) const StatusPill('Sélectionnée'),
              ]),
              Text('Expire ${cards[i].expiry}', style: copyStyle.copyWith(fontSize: 13)),
            ]))))),
      SurfaceCard(child: Form(key: form, child: StackColumn(gap: 12, [
        Row(children: [
          const Icon(Icons.add_rounded, color: ink),
          const SizedBox(width: 6),
          Expanded(child: Text('Ajouter une carte', style: strongStyle.copyWith(fontSize: 18))),
        ]),
        const Divider(height: 4, color: line),
        DropField('Numéro de carte', controller: number, hint: '0000 0000 0000 0000',
          icon: Icons.credit_card_rounded, keyboard: TextInputType.number, validate: validNumber,
          autofill: const [AutofillHints.creditCardNumber]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: DropField('Expiration', controller: expiry, hint: 'MM/AA',
            keyboard: TextInputType.datetime, validate: validExpiry,
            autofill: const [AutofillHints.creditCardExpirationDate])),
          const SizedBox(width: 12),
          Expanded(child: DropField('CVC', controller: cvc, hint: '123', keyboard: TextInputType.number,
            validate: validCvc, action: TextInputAction.done,
            autofill: const [AutofillHints.creditCardSecurityCode])),
        ]),
      ]))),
      const SizedBox(height: 14),
      const InfoBanner('Paiement sécurisé et chiffré'),
      const SizedBox(height: 14),
      DropButton('Payer ${euros(state.total)}', icon: Icons.lock_outline_rounded, onPressed: () => pay(state)),
    ]);
  }
}

/// 25 · Commande confirmée
class OrderConfirmedPage extends StatelessWidget {
  const OrderConfirmedPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    return SuccessLayout(icon: Icons.check_rounded, title: 'Commande confirmée !',
      subtitle: 'Votre panier est réservé et payé.', children: [
        SurfaceCard(child: StackColumn(gap: 2, [
          ValueRow('Commande', '#${state.orderNumber}', valueColor: ink),
          ValueRow(state.offer.shop, euros(state.total)),
          const SizedBox(height: 8),
          InfoBanner('À retirer avant ${pickupTime(state.offer.pickupUntil)}', warm: true),
        ])),
        const SizedBox(height: 18),
        DropButton('Afficher mon QR code', icon: Icons.qr_code_2_rounded,
          onPressed: () => goAya(context, AyaScreen.pickupPass)),
        const SizedBox(height: 10),
        DropButton('Retour à l’accueil', style: ActionStyle.outline,
          onPressed: () => openTeamLink(context, TeamLink.clientHome)),
      ]);
  }
}

/// 26 · Mon pass de retrait
class PickupPassPage extends StatelessWidget {
  const PickupPassPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AchatBoutiqueScope.of(context);
    final offer = state.offer;
    final digits = state.pickupCode.split('');
    return PageScroll(children: [
      Text(offer.shop, textAlign: TextAlign.center, style: strongStyle.copyWith(fontSize: 19)),
      const SizedBox(height: 6),
      Text(offer.address, textAlign: TextAlign.center, style: copyStyle.copyWith(fontSize: 13)),
      const SizedBox(height: 16),
      DashedFrame(color: const Color(0xFFC3CEC7), fill: Colors.white,
        child: LayoutBuilder(builder: (context, box) => Column(children: [
          Text('Présentez ce QR code au commerçant', textAlign: TextAlign.center,
            style: copyStyle.copyWith(color: const Color(0xFF34443B))),
          const SizedBox(height: 16),
          PickupQr('LD-${state.orderNumber}-${state.pickupCode}', size: math.min(200, box.maxWidth - 20)),
          const SizedBox(height: 16),
          Text('Code de secours', style: copyStyle.copyWith(color: const Color(0xFF34443B))),
          const SizedBox(height: 4),
          Semantics(label: 'Code de secours ${digits.join(' ')}', excludeSemantics: true,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final digit in digits) Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(digit, style: headingStyle.copyWith(fontSize: 30, color: forest, letterSpacing: 0))),
            ])),
        ]))),
      const SizedBox(height: 16),
      InfoBanner('À retirer avant ${pickupTime(offer.pickupUntil)}', warm: true),
      const SizedBox(height: 12),
      DropButton('Itinéraire vers le commerce', icon: Icons.map_outlined, style: ActionStyle.outline,
        onPressed: () => goAya(context, AyaScreen.directions)),
      const SizedBox(height: 10),
      ForestButton('Voir ma commande', icon: Icons.receipt_long_outlined,
        onPressed: () => openTeamLink(context, TeamLink.orderDetail)),
    ]);
  }
}
