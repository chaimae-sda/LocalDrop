import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../src/ui.dart';
import '../achat_boutique/aya_navigation.dart';
import '../achat_boutique/aya_screens.dart';
import '../achat_boutique/controllers/achat_boutique_controller.dart';
import '../achat_boutique/models/achat_boutique_models.dart';
import '../achat_boutique/widgets/achat_widgets.dart';
import 'merchant_operations.dart';
import 'merchant_screen.dart';
import 'merchant_widgets.dart';

class OrderCard extends StatelessWidget {
  const OrderCard(this.ticket, {super.key});
  final PickupTicket ticket;

  @override
  Widget build(BuildContext context) {
    final order = ticket.order;
    final collected = AchatBoutiqueScope.of(context).isCollected(ticket);
    void detail() =>
        openMerchant(context, MerchantScreen.detail, order: order.number);
    return SurfaceCard(
      child: StackColumn(gap: 8, [
        InkWell(
          onTap: detail,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.number}',
                      style: strongStyle.copyWith(color: orangeText),
                    ),
                  ),
                  StatusPill(collected ? 'RETIRÉE' : 'PAYÉE'),
                  const Icon(Icons.chevron_right, size: 18, color: muted),
                ],
              ),
              Text(order.customer, style: strongStyle.copyWith(fontSize: 17)),
              Text(
                '${ticket.product} · ${euros(order.price)}',
                style: copyStyle,
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.schedule_outlined, size: 16, color: muted),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Retrait ${pickupTime(order.pickup)}',
                style: copyStyle,
              ),
            ),
            const Text('1 panier', style: copyStyle),
          ],
        ),
        if (!collected)
          ForestButton(
            'Valider le retrait (scan QR)',
            icon: Icons.qr_code_scanner,
            onPressed: () =>
                openMerchant(context, MerchantScreen.scan, order: order.number),
          ),
      ]),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool finished = false;

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final orders = finished
        ? shop.tickets.where(shop.isCollected).toList()
        : shop.pending;
    return MerchantBody([
      SegmentedButton<bool>(
        segments: [
          ButtonSegment(
            value: false,
            label: Text('À remettre (${shop.pending.length})'),
          ),
          const ButtonSegment(value: true, label: Text('Terminées')),
        ],
        showSelectedIcon: false,
        selected: {finished},
        onSelectionChanged: (value) => setState(() => finished = value.single),
      ),
      if (orders.isEmpty) ...[
        InfoBanner(
          finished
              ? 'Aucun panier retiré pour le moment.'
              : 'Tous les paniers réservés ont été remis.',
        ),
        if (!finished)
          DropButton(
            'Voir la vitrine',
            onPressed: () => openMerchant(context, MerchantScreen.empty),
          ),
      ],
      for (final ticket in orders) OrderCard(ticket),
      if (finished)
        DropButton(
          'Historique des ventes',
          style: ActionStyle.outline,
          onPressed: () => openMerchant(context, MerchantScreen.sales),
        ),
    ]);
  }
}

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage(this.number, {super.key});
  final int? number;

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final ticket = shop.byNumber(number ?? shop.orderNumber);
    if (ticket == null)
      return const MerchantBody([InfoBanner('Commande introuvable.')]);
    final order = ticket.order;
    final picked = shop.isCollected(ticket);
    return MerchantBody([
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          StatusPill(picked ? 'PAYÉE · RETIRÉE' : 'PAYÉE · À REMETTRE'),
          Text('#${order.number}', style: strongStyle),
        ],
      ),
      const SectionTitle('Client'),
      SurfaceCard(
        child: StackColumn(gap: 2, [
          Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(width: 8),
              Expanded(child: Text(order.customer, style: strongStyle)),
            ],
          ),
          ValueRow('Panier', ticket.product),
          const ValueRow('Quantité', '1'),
          ValueRow('Montant payé', euros(order.price)),
          ValueRow('Retrait prévu', pickupTime(order.pickup)),
        ]),
      ),
      if (picked)
        const InfoBanner('Ce panier a déjà été remis au client.')
      else ...[
        const InfoBanner('Demandez au client de présenter son pass QR.'),
        DropButton(
          'Scanner le pass QR',
          icon: Icons.qr_code_scanner,
          onPressed: () =>
              openMerchant(context, MerchantScreen.scan, order: order.number),
        ),
        DropButton(
          'Utiliser le code de secours',
          style: ActionStyle.outline,
          icon: Icons.dialpad,
          onPressed: () =>
              openMerchant(context, MerchantScreen.code, order: order.number),
        ),
      ],
    ]);
  }
}

class VerifyPickupPage extends StatefulWidget {
  const VerifyPickupPage({super.key, required this.manual, this.number});
  final bool manual;
  final int? number;
  @override
  State<VerifyPickupPage> createState() => _VerifyPickupPageState();
}

class _VerifyPickupPageState extends State<VerifyPickupPage> {
  String input = '';
  PickupTicket? scanned;
  bool attempted = false;

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final demo = widget.number == null
        ? (shop.pending.firstOrNull ?? shop.tickets.first)
        : shop.byNumber(widget.number);
    final ticket = widget.manual ? shop.byCode(input) : scanned;
    final checked = widget.manual
        ? attempted || input.length == 4
        : scanned != null;
    final error = !checked
        ? null
        : ticket == null
        ? 'Code inconnu. Vérifiez les quatre chiffres du pass.'
        : widget.number != null && ticket.order.number != widget.number
        ? 'Ce code correspond à une autre commande.'
        : shop.isCollected(ticket)
        ? 'Ce panier a déjà été retiré.'
        : null;
    final matched = checked && ticket != null && error == null;
    void validate() {
      setState(() => attempted = true);
      if (!matched || !shop.collect(ticket)) return;
      openMerchant(
        context,
        MerchantScreen.done,
        order: ticket.order.number,
        replace: true,
      );
    }

    return MerchantBody([
      if (widget.manual) ...[
        const SizedBox(height: 14),
        const Icon(Icons.qr_code_scanner, color: success, size: 48),
        Text(
          'Code de secours',
          textAlign: TextAlign.center,
          style: headingStyle.copyWith(fontSize: 24),
        ),
        const Text(
          'Saisissez les 4 chiffres affichés sur le pass du client.',
          textAlign: TextAlign.center,
          style: copyStyle,
        ),
        TextField(
          key: const ValueKey('pickup-code'),
          autofocus: false,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: headingStyle.copyWith(
            fontSize: 29,
            color: forest,
            letterSpacing: 8,
          ),
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Code à 4 chiffres',
            hintText: '• • • •',
            counterText: '',
          ),
          onChanged: (text) => setState(() {
            input = text;
            attempted = false;
          }),
          onSubmitted: (_) => validate(),
        ),
      ] else ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(18),
          ),
          child: StackColumn(center: true, gap: 16, [
            const Text(
              'Aperçu du scanner',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (demo != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: orange, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExcludeSemantics(
                  child: PickupQr(demo.payload, size: 126),
                ),
              ),
            const Text(
              'Lecture simulée pour la démonstration',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ]),
        ),
        if (demo != null)
          ForestButton(
            'Simuler la lecture du pass',
            icon: Icons.qr_code_scanner,
            onPressed: () => setState(() => scanned = shop.byQr(demo.payload)),
          ),
      ],
      if (error != null)
        Semantics(liveRegion: true, child: InfoBanner(error, warm: true)),
      if (matched)
        SurfaceCard(
          child: Column(
            children: [
              ValueRow('Commande trouvée', '#${ticket.order.number}'),
              ValueRow('Client', ticket.order.customer),
              ValueRow('Panier', ticket.product),
            ],
          ),
        ),
      if (widget.manual || matched)
        DropButton(
          widget.manual
              ? 'Valider le retrait'
              : 'Confirmer la remise du panier',
          icon: Icons.check,
          onPressed: validate,
        ),
      if (!widget.manual)
        DropButton(
          'Saisir le code manuellement',
          style: ActionStyle.outline,
          icon: Icons.dialpad,
          onPressed: () =>
              openMerchant(context, MerchantScreen.code, order: widget.number),
        ),
    ]);
  }
}

class PickupDonePage extends StatelessWidget {
  const PickupDonePage(this.number, {super.key});
  final int? number;

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final ticket = number == null
        ? shop.tickets.where(shop.isCollected).lastOrNull
        : shop.byNumber(number);
    if (ticket == null || !shop.isCollected(ticket)) {
      return MerchantBody([
        const InfoBanner('Validez un pass pour afficher son reçu de retrait.'),
        DropButton(
          'Ouvrir les commandes',
          onPressed: () => openMerchant(context, MerchantScreen.orders),
        ),
      ]);
    }
    final order = ticket.order;
    return SuccessLayout(
      icon: Icons.check,
      title: 'Panier remis avec succès !',
      subtitle:
          'La commande #${order.number} est désormais marquée « Retirée ».',
      children: [
        SurfaceCard(
          child: Column(
            children: [
              ValueRow('Client', order.customer),
              ValueRow('Commande', '#${order.number}'),
              ValueRow('Montant', euros(order.price)),
              const ValueRow(
                'Statut',
                '',
                valueWidget: StatusPill('RETIRÉE', solid: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DropButton(
          'Voir les autres commandes',
          icon: Icons.chevron_right,
          onPressed: () =>
              openMerchant(context, MerchantScreen.orders, replace: true),
        ),
        const SizedBox(height: 10),
        DropButton(
          'Retour au tableau de bord',
          style: ActionStyle.outline,
          onPressed: () => goAya(context, AyaScreen.dashboard),
        ),
      ],
    );
  }
}
