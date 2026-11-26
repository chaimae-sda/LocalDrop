import 'package:flutter/material.dart';

import '../../src/ui.dart';
import '../achat_boutique/aya_navigation.dart';
import '../achat_boutique/aya_screens.dart';
import '../achat_boutique/aya_shell.dart' show MerchantTabs;
import '../achat_boutique/controllers/achat_boutique_controller.dart';
import 'account_pages.dart';
import 'merchant_screen.dart';
import 'pickup_pages.dart';
import 'sales_pages.dart';
import 'showcase_pages.dart';

Route<void>? merchantRouteFor(RouteSettings settings) {
  final screen = MerchantScreen.fromRoute(settings.name);
  if (screen == null) return null;
  final order = settings.arguments;
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) =>
        MerchantShell(screen: screen, order: order is int ? order : null),
  );
}

/// Un navigateur commun conserve le stock et les commandes entre les parcours.
class MerchantShell extends StatefulWidget {
  const MerchantShell({super.key, required this.screen, this.order});
  final MerchantScreen screen;
  final int? order;
  @override
  State<MerchantShell> createState() => _MerchantShellState();
}

class _MerchantShellState extends State<MerchantShell> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AchatBoutiqueScope.of(context).startClock();
  }

  Widget get page => switch (widget.screen) {
    MerchantScreen.live => const LiveShowcasePage(),
    MerchantScreen.orders => const OrdersPage(),
    MerchantScreen.detail => OrderDetailPage(widget.order),
    MerchantScreen.scan || MerchantScreen.code => VerifyPickupPage(
      manual: widget.screen == MerchantScreen.code,
      number: widget.order,
    ),
    MerchantScreen.done => PickupDonePage(widget.order),
    MerchantScreen.showcases => const ShowcasesPage(),
    MerchantScreen.edit => const EditShowcasePage(),
    MerchantScreen.stock => const StockPage(),
    MerchantScreen.stats => const StatsPage(),
    MerchantScreen.sales => const SalesPage(),
    MerchantScreen.plan => const PlanPage(),
    MerchantScreen.settings => const MerchantSettingsPage(),
    MerchantScreen.support => const MerchantSupportPage(),
    MerchantScreen.empty => const EmptyOrdersPage(),
    MerchantScreen.billing => const BillingPage(),
    MerchantScreen.team => const ShopTeamPage(),
  };

  void openDestination(String target) {
    if (target == widget.screen.route) return;
    Navigator.of(context).pushNamed(target);
  }

  Future<void> showMenu() async {
    final target = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 460),
      builder: (sheet) => FractionallySizedBox(
        heightFactor: .85,
        child: MerchantMenu(
          current: widget.screen,
          onSelect: (route) => Navigator.pop(sheet, route),
        ),
      ),
    );
    if (mounted && target != null) openDestination(target);
  }

  @override
  Widget build(BuildContext context) {
    final shop = AchatBoutiqueScope.of(context);
    final screen = widget.screen;
    final title = screen == MerchantScreen.detail
        ? 'Commande #${widget.order ?? shop.orderNumber}'
        : screen.label;
    return Scaffold(
      backgroundColor: canvas,
      body: LayoutBuilder(
        builder: (context, bounds) {
          final wide = bounds.maxWidth >= 820;
          final phone = ColoredBox(
            color: forest,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Retour',
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.pop(context);
                            } else {
                              goAya(
                                context,
                                AyaScreen.dashboard,
                                replace: true,
                              );
                            }
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                'Espace commerçant',
                                style: TextStyle(
                                  color: Color(0xFFD2E5D9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!wide)
                          IconButton(
                            tooltip: 'Tous les écrans',
                            icon: const Icon(
                              Icons.grid_view_rounded,
                              color: Colors.white,
                            ),
                            onPressed: showMenu,
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.bolt_outlined,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(23),
                        ),
                      ),
                      child: page,
                    ),
                  ),
                  if (screen.tab case final int tab) MerchantTabs(tab),
                ],
              ),
            ),
          );
          if (!wide) return phone;
          return Row(
            children: [
              SizedBox(
                width: bounds.maxWidth < 1050 ? 240 : 268,
                child: ColoredBox(
                  color: Colors.white,
                  child: SafeArea(
                    child: MerchantMenu(
                      current: screen,
                      onSelect: openDestination,
                    ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1, color: line),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Container(
                      width: 400,
                      constraints: const BoxConstraints(maxHeight: 844),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18162E1F),
                            blurRadius: 32,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: phone,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

const _groups = {
  'Vitrine & retraits': [
    MerchantScreen.live,
    MerchantScreen.orders,
    MerchantScreen.detail,
    MerchantScreen.scan,
    MerchantScreen.code,
    MerchantScreen.done,
    MerchantScreen.empty,
  ],
  'Catalogue & stock': [
    MerchantScreen.showcases,
    MerchantScreen.edit,
    MerchantScreen.stock,
  ],
  'Activité': [
    MerchantScreen.stats,
    MerchantScreen.sales,
    MerchantScreen.plan,
    MerchantScreen.billing,
  ],
  'Ma boutique': [
    MerchantScreen.settings,
    MerchantScreen.support,
    MerchantScreen.team,
  ],
};

class MerchantMenu extends StatelessWidget {
  const MerchantMenu({
    super.key,
    required this.current,
    required this.onSelect,
  });
  final MerchantScreen current;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            LogoMark(size: 36),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LocalDrop', style: strongStyle),
                  Text('Parcours d’Oussama', style: copyStyle),
                ],
              ),
            ),
          ],
        ),
      ),
      const Divider(height: 1),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            for (final group in _groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 12, 0, 5),
                child: FieldLabel(group.key),
              ),
              for (final entry in group.value)
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selected: current == entry,
                  selectedTileColor: mint,
                  leading: Text(
                    entry.number,
                    style: copyStyle.copyWith(fontSize: 12),
                  ),
                  minLeadingWidth: 18,
                  horizontalTitleGap: 8,
                  title: Text(
                    entry.label,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () => onSelect(entry.route),
                ),
            ],
            const Padding(
              padding: EdgeInsets.fromLTRB(9, 12, 0, 5),
              child: FieldLabel('Parcours d’Aya'),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.qr_code),
              title: const Text('Pass client #1042'),
              onTap: () => onSelect(AyaScreen.pickupPass.route),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Tableau de bord'),
              onTap: () => onSelect(AyaScreen.dashboard.route),
            ),
          ],
        ),
      ),
    ],
  );
}
