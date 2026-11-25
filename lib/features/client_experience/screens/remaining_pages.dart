import 'package:flutter/material.dart';

import '../../../src/navigation.dart';
import '../../../src/screens.dart';
import '../../../src/ui.dart';
import '../controllers/client_controller.dart';
import '../data/sample_data.dart';
import '../models/client_models.dart';
import 'client_experience_pages.dart';
import 'preferences_pages.dart';

class ShopDetailPage extends StatelessWidget {
  const ShopDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientExperienceScope.of(context);
    final shop = shops.firstWhere(
      (item) => item.id == controller.selectedShopId,
      orElse: () => shops.first,
    );
    final availableOffers = offers
        .where((offer) => offer.shopId == shop.id && offer.available > 0)
        .toList();
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: mint,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.storefront_rounded, size: 72, color: forest),
        ),
        const SizedBox(height: 14),
        Text(shop.name, style: headingStyle.copyWith(fontSize: 25)),
        Text(
          '${shop.category} · ${shop.distance.toStringAsFixed(1)} km',
          style: copyStyle,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(child: Text('Offres en cours', style: strongStyle)),
            Pill(
              '${availableOffers.length} disponible${availableOffers.length > 1 ? 's' : ''}',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (availableOffers.isEmpty)
          const SurfaceCard(
            child: Text(
              'Aucune offre disponible actuellement',
              style: copyStyle,
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final offer in availableOffers) OfferCard(offer: offer),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('À propos', style: strongStyle),
              const SizedBox(height: 6),
              Text(shop.description, style: copyStyle),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Adresse', style: strongStyle),
              const SizedBox(height: 6),
              Text(shop.address, style: copyStyle),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Horaires', style: strongStyle),
              const SizedBox(height: 6),
              Text(shop.hours, style: copyStyle),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Itinéraire simulé vers le commerce'),
              ),
            );
          },
          icon: const Icon(Icons.directions_outlined),
          style: OutlinedButton.styleFrom(
            foregroundColor: forest,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: forest),
          ),
          label: const Text('Voir l’itinéraire'),
        ),
        const SizedBox(height: 12),
        Text('Offres du commerce', style: strongStyle),
        const SizedBox(height: 8),
        DropButton(
          'Voir les offres',
          icon: Icons.local_offer_outlined,
          onPressed: () => go(context, DropScreen.flashOffers),
        ),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientExperienceScope.of(context);
    final favorites = offers
        .where((offer) => controller.isFavorite(offer.id))
        .toList();
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        if (favorites.isEmpty)
          const EmptyStatePage(
            title: 'Aucun favori',
            message: 'Ajoutez une vente Flash pour la retrouver facilement.',
          )
        else
          for (final offer in favorites)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurfaceCard(
                padding: 10,
                child: Column(
                  children: [
                    Container(
                      height: 125,
                      decoration: BoxDecoration(
                        color: mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 55,
                        color: forest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text(offer.name, style: strongStyle)),
                        IconButton(
                          tooltip: 'Retirer des favoris',
                          onPressed: () => controller.toggleFavorite(offer.id),
                          icon: const Icon(Icons.favorite, color: orange),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${offer.shop} · ${offer.price.toStringAsFixed(2)} €',
                        style: copyStyle,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ClientExperienceScope.of(context).selectOffer(offer.id);
                        go(context, DropScreen.offerDetail);
                      },
                      child: const Text('Voir l’offre'),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientExperienceScope.of(context);
    final unread = notifications
        .where((item) => !controller.readNotifications.contains(item.id))
        .length;
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$unread notification${unread > 1 ? 's' : ''} non lue${unread > 1 ? 's' : ''}',
                style: strongStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in notifications)
          Builder(
            builder: (context) {
              final read = controller.readNotifications.contains(item.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => controller.markNotificationRead(item.id),
                  child: SurfaceCard(
                    color: read ? Colors.white : mint,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: read
                              ? const Color(0xFFE9EEE9)
                              : orange,
                          child: Icon(
                            read
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: read ? muted : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: strongStyle),
                              const SizedBox(height: 4),
                              Text(item.message, style: copyStyle),
                              const SizedBox(height: 6),
                              Text(
                                item.time,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              if (item.offerId != null)
                                TextButton(
                                  onPressed: () {
                                    controller.selectOffer(item.offerId!);
                                    go(context, DropScreen.offerDetail);
                                  },
                                  child: const Text('Voir l’offre'),
                                ),
                              if (item.offerId == null)
                                TextButton(
                                  onPressed: () =>
                                      go(context, DropScreen.orders),
                                  child: const Text('Voir ma commande'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) => PageScroll(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    children: [
      for (final order in orders.where((order) => order.status != 'Terminée'))
        _OrderCard(order: order),
    ],
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final dynamic order;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () => go(context, DropScreen.orderDetail),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(order.offerName as String, style: strongStyle),
                Pill(order.status as String),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.shop as String, style: copyStyle),
            Text(order.pickup as String, style: copyStyle),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '${(order.amount as double).toStringAsFixed(2)} €',
                  style: strongStyle,
                ),
                const Text(
                  'Voir le détail',
                  style: TextStyle(color: forest, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = orders[0];
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        Text(order.id, style: headingStyle),
        const SizedBox(height: 8),
        Pill(order.status),
        const SizedBox(height: 14),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.offerName, style: strongStyle),
              const SizedBox(height: 6),
              Text(order.shop, style: copyStyle),
              Text(order.date, style: copyStyle),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Retrait', style: strongStyle),
              SizedBox(height: 6),
              Text(
                'Aujourd’hui, 18h00 - 19h30\n18 rue du Pont, Paris',
                style: copyStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Row(
            children: [
              const Expanded(child: Text('Montant payé', style: strongStyle)),
              Text('${order.amount.toStringAsFixed(2)} €', style: strongStyle),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialog) => AlertDialog(
              title: const Text('Pass de retrait'),
              content: const Text(
                'Intégration Aya : le QR code sera disponible après l’intégration du paiement.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialog),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
          child: const Text('Voir le pass de retrait'),
        ),
      ],
    );
  }
}

class PurchaseHistoryPage extends StatelessWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientExperienceScope.of(context);
    final eligibleOrders = orders
        .where(
          (order) =>
              order.status == 'Terminée' &&
              !controller.isOrderReviewed(order.id),
        )
        .toList();

    void openReview(ClientOrder order) {
      controller.selectOrder(order.id);
      go(context, DropScreen.review);
    }

    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        for (final order in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(order.offerName, style: strongStyle),
                      Pill(order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${order.shop} · ${order.amount.toStringAsFixed(2)} €',
                    style: copyStyle,
                  ),
                  if (order.status == 'Terminée')
                    controller.isOrderReviewed(order.id)
                        ? const Text(
                            'Avis déjà envoyé',
                            style: TextStyle(
                              color: success,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : TextButton(
                            onPressed: () => openReview(order),
                            child: const Text('Donner mon avis'),
                          )
                  else
                    TextButton(
                      onPressed: () => go(context, DropScreen.orderDetail),
                      child: const Text('Voir le détail'),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () {
            if (eligibleOrders.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les commandes ont déjà reçu un avis.'),
                ),
              );
              return;
            }
            if (eligibleOrders.length == 1) {
              openReview(eligibleOrders.first);
              return;
            }
            showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (sheet) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Choisir une commande', style: strongStyle),
                      const SizedBox(height: 10),
                      for (final order in eligibleOrders)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(order.offerName, style: strongStyle),
                          subtitle: Text(order.shop, style: copyStyle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(sheet);
                            openReview(order);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.star_outline_rounded),
          style: OutlinedButton.styleFrom(
            foregroundColor: forest,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: forest),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          label: const Text(
            'Donner mon avis',
            style: TextStyle(color: forest, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
