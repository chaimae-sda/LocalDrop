import 'package:flutter/material.dart';

import '../../../src/navigation.dart';
import '../../../src/screens.dart';
import '../../../src/ui.dart';
import '../controllers/client_controller.dart';
import '../data/sample_data.dart';
import '../models/client_models.dart';
import 'preferences_pages.dart';

Widget _productImage(FlashOffer offer, {double height = 150}) => ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.network(
    '${offer.imageUrl}?auto=format&fit=crop&w=800&q=80',
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      height: height,
      color: mint,
      alignment: Alignment.center,
      child: Icon(Icons.shopping_bag_outlined, size: 48, color: forest),
    ),
  ),
);

class AroundMePage extends StatelessWidget {
  const AroundMePage({super.key});

  @override
  Widget build(BuildContext context) => PageScroll(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    children: [
      Row(
        children: [
          const Icon(Icons.location_on, color: orange, size: 20),
          const SizedBox(width: 6),
          const Expanded(
            child: Text('12 rue du Commerce, Paris', style: strongStyle),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => go(context, DropScreen.notifications),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFE7EFE8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: line),
        ),
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _MapPainter(),
            ),
            for (final (left, top, label) in const [
              (.18, .55, '5'),
              (.62, .28, '3'),
              (.76, .65, '8'),
            ])
              Positioned(
                left: 390 * left - 18,
                top: 220 * top - 18,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 185,
              top: 106,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: forest,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          const Expanded(child: Text('Près de vous', style: headingStyle)),
          TextButton(
            onPressed: () => go(context, DropScreen.flashOffers),
            child: const Text('Voir tout'),
          ),
        ],
      ),
      for (final offer in offers.take(3)) OfferCard(offer: offer),
    ],
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * .48),
      Offset(size.width, size.height * .42),
      road,
    );
    canvas.drawLine(
      Offset(size.width * .5, 0),
      Offset(size.width * .44, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * .05, size.height * .82),
      Offset(size.width * .95, size.height * .18),
      road,
    );
    final park = Paint()..color = const Color(0xFFD1E4D5);
    canvas.drawCircle(Offset(size.width * .82, size.height * .78), 35, park);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlashOffersPage extends StatelessWidget {
  const FlashOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientExperienceScope.of(context);
    final filtered = offers.where((offer) {
      if (offer.distance > controller.maxDistance ||
          offer.price > controller.maxPrice)
        return false;
      if (controller.availableOnly && offer.available < 1) return false;
      if (controller.pickupTodayOnly && !offer.pickupToday) return false;
      if (controller.selectedCategories.isNotEmpty &&
          !controller.selectedCategories.contains(offer.category))
        return false;
      return true;
    }).toList();
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        TextField(
          key: const ValueKey('offers-search'),
          readOnly: true,
          decoration: const InputDecoration(
            hintText: 'Rechercher une offre',
            prefixIcon: Icon(Icons.search),
          ),
          onTap: () => go(context, DropScreen.search),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                '${filtered.length} offres disponibles',
                style: strongStyle,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => go(context, DropScreen.filters),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Filtres'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          const EmptyStatePage(
            key: ValueKey('no-filter-results'),
            title: 'Aucune offre correspondante',
            message: 'Élargissez votre rayon ou réinitialisez les filtres.',
          )
        else
          for (final offer in filtered) OfferCard(offer: offer),
      ],
    );
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});
  final FlashOffer offer;

  @override
  Widget build(BuildContext context) {
    final controller = ClientExperienceScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          controller.selectOffer(offer.id);
          go(context, DropScreen.offerDetail);
        },
        borderRadius: BorderRadius.circular(16),
        child: SurfaceCard(
          padding: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  _productImage(offer, height: 145),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Pill('-${offer.discount} %'),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: controller.isFavorite(offer.id)
                            ? 'Retirer des favoris'
                            : 'Ajouter aux favoris',
                        onPressed: () => controller.toggleFavorite(offer.id),
                        icon: Icon(
                          controller.isFavorite(offer.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(offer.name, style: strongStyle),
              const SizedBox(height: 4),
              Text(
                '${offer.shop} · ${offer.distance.toStringAsFixed(1)} km',
                style: copyStyle,
              ),
              const SizedBox(height: 3),
              Text(
                'Retrait avant ${offer.pickupLimit}',
                style: copyStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 7),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    '${offer.price.toStringAsFixed(2)} €',
                    style: strongStyle.copyWith(color: forest, fontSize: 18),
                  ),
                  Text(
                    '${offer.originalPrice.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: muted,
                    ),
                  ),
                  Text(
                    '${offer.available} disponibles',
                    style: const TextStyle(
                      color: success,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageScroll(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    children: [
      TextField(
        controller: controller,
        autofocus: true,
        onChanged: (value) => setState(() => query = value),
        decoration: InputDecoration(
          hintText: 'Produit, commerce ou catégorie',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Effacer',
                  onPressed: () {
                    controller.clear();
                    setState(() => query = '');
                  },
                  icon: const Icon(Icons.close),
                ),
        ),
      ),
      const SizedBox(height: 16),
      if (query.isEmpty) ...[
        const Text('Recherches populaires', style: strongStyle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const ['Boulangerie', 'Bio', 'Restaurant', 'Épicerie']
              .map(
                (label) => ActionChip(
                  label: Text(label),
                  onPressed: () => setState(() {
                    controller.text = label;
                    query = label;
                  }),
                ),
              )
              .toList(),
        ),
      ] else
        Builder(
          builder: (context) {
            final normalized = query.toLowerCase();
            final results = offers
                .where(
                  (offer) => '${offer.name} ${offer.shop} ${offer.category}'
                      .toLowerCase()
                      .contains(normalized),
                )
                .toList();
            final matchingShops = shops
                .where(
                  (shop) => '${shop.name} ${shop.category}'
                      .toLowerCase()
                      .contains(normalized),
                )
                .toList();
            final productSuggestions = offers
                .where(
                  (offer) =>
                      offer.name.toLowerCase().contains(normalized) ||
                      normalized.contains(offer.category.toLowerCase()) ||
                      normalized.contains('viennoiserie') &&
                          '${offer.name} ${offer.description}'
                              .toLowerCase()
                              .contains('boulanger'),
                )
                .map((offer) => offer.name)
                .toSet()
                .toList();
            final searchSuggestions = productSuggestions.isNotEmpty
                ? productSuggestions
                      .take(2)
                      .map((name) => 'Paniers : $name')
                      .toList()
                : offers
                      .map((offer) => offer.category)
                      .toSet()
                      .where(
                        (category) =>
                            normalized.isNotEmpty &&
                            (category.toLowerCase().contains(normalized) ||
                                normalized.contains(category.toLowerCase())),
                      )
                      .map((category) => 'Paniers $category')
                      .take(2)
                      .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (results.isNotEmpty)
                  for (final offer in results) OfferCard(offer: offer)
                else
                  const EmptyStatePage(
                    title: 'Aucun résultat',
                    message: 'Essayez un autre produit, commerce ou catégorie.',
                  ),
                if (matchingShops.isNotEmpty ||
                    searchSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Suggestions', style: strongStyle),
                  const SizedBox(height: 8),
                  for (final shop in matchingShops)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          ClientExperienceScope.of(context).selectShop(shop.id);
                          go(context, DropScreen.shopDetail);
                        },
                        child: SurfaceCard(
                          padding: 10,
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: mint,
                                child: Icon(
                                  Icons.storefront_outlined,
                                  color: forest,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(shop.name, style: strongStyle),
                                    Text(
                                      '${shop.distance.toStringAsFixed(1)} km · ${shop.hours}',
                                      style: copyStyle.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: muted),
                            ],
                          ),
                        ),
                      ),
                    ),
                  for (final suggestion in searchSuggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          final text = suggestion
                              .replaceFirst('Paniers : ', '')
                              .replaceFirst('Paniers ', '');
                          controller.text = text;
                          setState(() => query = text);
                        },
                        child: SurfaceCard(
                          padding: 10,
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: mint,
                                child: Icon(Icons.search, color: forest),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(suggestion, style: strongStyle),
                              ),
                              const Icon(Icons.chevron_right, color: muted),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
    ],
  );
}

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  late double distance;
  late double price;
  late bool available;
  late bool pickupToday;
  late bool allPrices;
  late Set<String> categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ClientExperienceScope.of(context);
    distance = controller.maxDistance;
    price = controller.maxPrice;
    available = controller.availableOnly;
    pickupToday = controller.pickupTodayOnly;
    allPrices = controller.allPrices;
    categories = {...controller.selectedCategories};
  }

  int get filteredCount {
    var count = offers.where((offer) {
      if (offer.distance > distance) return false;
      if (!allPrices && offer.price >= 10) return false;
      if (categories.isNotEmpty &&
          categories.contains('Toutes') == false &&
          !categories.contains(offer.category))
        return false;
      if (available && offer.available <= 0) return false;
      if (pickupToday && !offer.pickupToday) return false;
      return true;
    }).length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    const filterCategories = <String>[
      'Toutes',
      'Boulangerie',
      'Boucherie',
      'Primeur',
      'Traiteur',
      'Épicerie',
      'Fruits & légumes',
      'Restaurant',
      'Pâtisserie',
    ];
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        const Text('Catégories', style: strongStyle),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.7,
          ),
          itemCount: filterCategories.length,
          itemBuilder: (context, index) {
            final category = filterCategories[index];
            final selected = category == 'Toutes'
                ? categories.isEmpty
                : categories.contains(category);
            return InkWell(
              onTap: () => setState(() {
                if (category == 'Toutes') {
                  categories.clear();
                } else {
                  categories.remove('Toutes');
                  if (selected) {
                    categories.remove(category);
                  } else {
                    categories.add(category);
                  }
                }
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? mint : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? success : line),
                ),
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? forest : ink,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        const Text('Distance maximale', style: strongStyle),
        const SizedBox(height: 4),
        const Text('Autour de ma position', style: copyStyle),
        Slider(
          value: distance,
          min: 0.5,
          max: 5,
          divisions: 9,
          label: distance < 1
              ? '${(distance * 1000).round()} m'
              : '${distance.toStringAsFixed(1)} km',
          onChanged: (value) => setState(() => distance = value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            distance < 1
                ? '${(distance * 1000).round()} m'
                : '${distance.toStringAsFixed(1)} km',
            style: strongStyle,
          ),
        ),
        const SizedBox(height: 18),
        const Text('Prix maximum', style: strongStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => allPrices = false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: allPrices ? Colors.white : mint,
                  foregroundColor: forest,
                  side: BorderSide(color: allPrices ? line : success),
                  minimumSize: const Size(0, 48),
                ),
                child: const Text('Moins de 10 €'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => allPrices = true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: allPrices ? mint : Colors.white,
                  foregroundColor: forest,
                  side: BorderSide(color: allPrices ? success : line),
                  minimumSize: const Size(0, 48),
                ),
                child: const Text('Tous les prix'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Afficher uniquement', style: strongStyle),
        Material(
          color: Colors.white,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Offres disponibles uniquement',
              style: strongStyle,
            ),
            subtitle: const Text('Panier en stock'),
            value: available,
            onChanged: (value) => setState(() => available = value),
          ),
        ),
        Material(
          color: Colors.white,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Retrait aujourd’hui', style: strongStyle),
            value: pickupToday,
            onChanged: (value) => setState(() => pickupToday = value),
          ),
        ),
        const SizedBox(height: 14),
        DropButton(
          'Voir les $filteredCount offres',
          icon: Icons.check,
          onPressed: () {
            ClientExperienceScope.of(context).setFilters(
              distance: distance,
              price: allPrices ? 30 : 10,
              categories: categories,
              available: available,
              pickupToday: pickupToday,
              allPrices: allPrices,
            );
            go(context, DropScreen.flashOffers, replace: true);
          },
        ),
        const SizedBox(height: 8),
        DropButton(
          'Réinitialiser',
          style: ActionStyle.outline,
          onPressed: () {
            ClientExperienceScope.of(context).resetFilters();
            setState(() {
              distance = 2;
              price = 25;
              available = false;
              pickupToday = false;
              allPrices = true;
              categories.clear();
            });
          },
        ),
      ],
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const entries = <(String, String, IconData)>[
    ('Boulangerie', 'Boulangerie', Icons.bakery_dining_outlined),
    ('Boucheries', 'Boucherie', Icons.set_meal_outlined),
    ('Fruits & légumes', 'Fruits & légumes', Icons.eco_outlined),
    ('Restaurant', 'Restaurant', Icons.restaurant_outlined),
    ('Épiceries', 'Épicerie', Icons.shopping_basket_outlined),
    ('Pâtisseries', 'Pâtisserie', Icons.cake_outlined),
  ];

  @override
  Widget build(BuildContext context) => PageScroll(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    children: [
      const Intro(
        'Toutes les catégories',
        'Explorez les envies du jour autour de vous.',
      ),
      const SizedBox(height: 16),
      Column(
        children: [
          for (final entry in entries) ...[
            Builder(
              builder: (context) {
                final count = offers
                    .where(
                      (offer) =>
                          offer.category == entry.$2 && offer.available > 0,
                    )
                    .length;
                return InkWell(
                  onTap: () {
                    ClientExperienceScope.of(context).setFilters(
                      distance: 5,
                      price: 30,
                      categories: {entry.$2},
                      available: false,
                      allPrices: true,
                    );
                    go(context, DropScreen.flashOffers);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: mint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(entry.$3, color: forest, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.$1, style: strongStyle),
                              const SizedBox(height: 3),
                              Text(
                                '$count panier${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}',
                                style: copyStyle.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: muted),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: line),
          ],
        ],
      ),
    ],
  );
}

class OfferDetailPage extends StatelessWidget {
  const OfferDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientExperienceScope.of(context);
    final offer = offers.firstWhere(
      (item) => item.id == controller.selectedOfferId,
      orElse: () => offers.first,
    );
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        Stack(
          children: [
            _productImage(offer, height: 220),
            Positioned(
              right: 10,
              top: 10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => controller.toggleFavorite(offer.id),
                  icon: Icon(
                    controller.isFavorite(offer.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: orange,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                offer.name,
                style: headingStyle.copyWith(fontSize: 24),
              ),
            ),
            Pill('-${offer.discount} %'),
          ],
        ),
        const SizedBox(height: 8),
        Text(offer.description, style: copyStyle),
        const SizedBox(height: 14),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(
              '${offer.price.toStringAsFixed(2)} €',
              style: headingStyle.copyWith(color: forest, fontSize: 28),
            ),
            Text(
              '${offer.originalPrice.toStringAsFixed(2)} €',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: muted,
              ),
            ),
            Text(
              '${offer.available} disponibles',
              style: const TextStyle(
                color: success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            controller.selectShop(offer.shopId);
            go(context, DropScreen.shopDetail);
          },
          child: SurfaceCard(
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: mint,
                  child: Icon(Icons.storefront, color: forest),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.shop, style: strongStyle),
                      Text(offer.address, style: copyStyle),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations de retrait', style: strongStyle),
              SizedBox(height: 7),
              Text(
                'Aujourd’hui, 18h00 - 19h30\nBoulangerie du Pont · 18 rue du Pont',
                style: copyStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        DropButton(
          'Réserver cette offre',
          icon: Icons.shopping_bag_outlined,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (dialog) => AlertDialog(
                title: const Text('Réservation confirmée'),
                content: const Text(
                  'Votre panier est réservé jusqu’à 19h30. Présentez-vous au commerce pour finaliser le retrait.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialog),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
