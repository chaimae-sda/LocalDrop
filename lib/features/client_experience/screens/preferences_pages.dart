import 'package:flutter/material.dart';

import '../../../src/navigation.dart';
import '../../../src/screens.dart';
import '../../../src/ui.dart';
import '../controllers/client_controller.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int rating = 0;
  final comment = TextEditingController();

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageScroll(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    children: [
      const Text('Votre avis', style: headingStyle),
      const SizedBox(height: 8),
      const Text(
        'Panier fruits & légumes · Marché Bio Central',
        style: copyStyle,
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final value = index + 1;
          return IconButton(
            onPressed: () => setState(() => rating = value),
            icon: Icon(
              value <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: value <= rating ? orange : muted,
              size: 38,
            ),
          );
        }),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: comment,
        maxLines: 5,
        decoration: const InputDecoration(hintText: 'Votre commentaire'),
      ),
      const SizedBox(height: 16),
      DropButton(
        'Valider mon avis',
        icon: Icons.check,
        onPressed: () {
          if (rating == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sélectionnez une note avant de valider.'),
              ),
            );
            return;
          }
          showDialog<void>(
            context: context,
            builder: (dialog) => AlertDialog(
              title: const Text('Merci pour votre avis'),
              content: const Text(
                'Votre avis a été enregistré localement pour cette démonstration.',
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

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final selected = <String>{'Bio', 'Boulangerie'};
  bool ecoMode = true;

  @override
  Widget build(BuildContext context) {
    const categories = ['Boulangerie', 'Bio', 'Épicerie', 'Restaurant'];
    return PageScroll(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        const Text('Mes préférences', style: headingStyle),
        const SizedBox(height: 8),
        const Text(
          'Choisissez les catégories qui vous intéressent.',
          style: copyStyle,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories
              .map(
                (category) => FilterChip(
                  label: Text(category),
                  selected: selected.contains(category),
                  onSelected: (value) => setState(() {
                    if (value) {
                      selected.add(category);
                    } else {
                      selected.remove(category);
                    }
                  }),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.white,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Afficher les offres anti-gaspillage',
              style: strongStyle,
            ),
            value: ecoMode,
            onChanged: (value) => setState(() => ecoMode = value),
          ),
        ),
        DropButton(
          'Enregistrer mes préférences',
          icon: Icons.check,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Préférences enregistrées localement'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProximityAlertsPage extends StatefulWidget {
  const ProximityAlertsPage({super.key});

  @override
  State<ProximityAlertsPage> createState() => _ProximityAlertsPageState();
}

class _ProximityAlertsPageState extends State<ProximityAlertsPage> {
  bool notifications = true;
  bool proximity = true;
  int radius = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ClientExperienceScope.of(context);
    notifications = controller.notificationsEnabled;
    proximity = controller.proximityAlertsEnabled;
    radius = controller.proximityRadius;
  }

  @override
  Widget build(BuildContext context) => PageScroll(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    children: [
      const Text('Alertes de proximité', style: headingStyle),
      const SizedBox(height: 14),
      Material(
        color: Colors.white,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notifications', style: strongStyle),
          subtitle: const Text('Recevoir les nouvelles ventes Flash'),
          value: notifications,
          onChanged: (value) => setState(() => notifications = value),
        ),
      ),
      Material(
        color: Colors.white,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Alertes à proximité', style: strongStyle),
          subtitle: const Text('M’avertir près d’un commerce partenaire'),
          value: proximity,
          onChanged: (value) => setState(() => proximity = value),
        ),
      ),
      const SizedBox(height: 12),
      const Text('Rayon de proximité', style: strongStyle),
      Slider(
        value: radius.toDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        label: '$radius km',
        onChanged: (value) => setState(() => radius = value.round()),
      ),
      Align(alignment: Alignment.centerRight, child: Text('$radius km')),
      const SizedBox(height: 18),
      DropButton(
        'Enregistrer les alertes',
        icon: Icons.check,
        onPressed: () {
          ClientExperienceScope.of(context).updateAlerts(
            notifications: notifications,
            proximity: proximity,
            radius: radius,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alertes enregistrées localement')),
          );
        },
      ),
    ],
  );
}

class EmptyOffersPage extends StatelessWidget {
  const EmptyOffersPage({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStatePage(
    title: 'Aucune offre à proximité',
    message:
        'Élargissez votre rayon ou réinitialisez les filtres pour découvrir davantage de commerces.',
  );
}

class EmptyOrdersPage extends StatelessWidget {
  const EmptyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStatePage(
    title: 'Aucune commande',
    message:
        'Vous n’avez pas encore réservé d’offre. Découvrez les ventes près de chez vous.',
  );
}

class EmptyStatePage extends StatelessWidget {
  const EmptyStatePage({super.key, required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              color: mint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              title.contains('commande')
                  ? Icons.receipt_long_outlined
                  : Icons.location_off_outlined,
              size: 48,
              color: forest,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: headingStyle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(message, style: copyStyle, textAlign: TextAlign.center),
          if (title == 'Aucune offre à proximité' ||
              title == 'Aucune offre correspondante') ...[
            const SizedBox(height: 16),
            DropButton(
              'Élargir le rayon',
              icon: Icons.my_location,
              onPressed: () {
                final controller = ClientExperienceScope.of(context);
                controller.widenSearchRadius(10);
                go(context, DropScreen.flashOffers);
              },
            ),
            const SizedBox(height: 8),
            DropButton(
              'Réinitialiser les filtres',
              style: ActionStyle.outline,
              onPressed: () {
                ClientExperienceScope.of(context).resetFilters();
                go(context, DropScreen.flashOffers);
              },
            ),
          ],
          if (title.contains('Aucune commande')) ...[
            const SizedBox(height: 16),
            DropButton(
              'Découvrir les offres',
              icon: Icons.search,
              onPressed: () {
                go(context, DropScreen.flashOffers);
              },
            ),
          ],
        ],
      ),
    ),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => PageScroll(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    children: [
      const Text('Paramètres', style: headingStyle),
      const SizedBox(height: 12),
      _SettingsTile(
        icon: Icons.favorite_border,
        title: 'Mes favoris',
        onTap: () => go(context, DropScreen.favorites),
      ),
      _SettingsTile(
        icon: Icons.tune,
        title: 'Mes préférences',
        onTap: () => go(context, DropScreen.preferences),
      ),
      _SettingsTile(
        icon: Icons.notifications_outlined,
        title: 'Alertes de proximité',
        onTap: () => go(context, DropScreen.proximityAlerts),
      ),
      _SettingsTile(
        icon: Icons.receipt_long_outlined,
        title: 'Mes commandes',
        onTap: () => go(context, DropScreen.orders),
      ),
      _SettingsTile(
        icon: Icons.person_outline,
        title: 'Profil',
        subtitle: 'Espace appartenant à Chaimae',
        onTap: () => openTeam(context, TeamScreen.settings),
      ),
    ],
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SurfaceCard(
      padding: 8,
      child: Material(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: mint,
            child: Icon(icon, color: forest),
          ),
          title: Text(title, style: strongStyle),
          subtitle: subtitle == null ? null : Text(subtitle!, style: copyStyle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    ),
  );
}
