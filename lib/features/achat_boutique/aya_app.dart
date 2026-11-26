import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../src/ui.dart';
import '../gestion_commercant/merchant_shell.dart';
import 'aya_screens.dart';
import 'aya_shell.dart';
import 'controllers/achat_boutique_controller.dart';
import 'screens/achat_pages.dart';
import 'screens/boutique_creation_pages.dart';
import 'screens/boutique_profil_pages.dart';

/// Page de chaque écran d’Aya, utilisable lors de l’intégration dans l’application.
Widget ayaPage(AyaScreen screen) => switch (screen) {
  AyaScreen.cart => const CartPage(),
  AyaScreen.checkout => const CheckoutPage(),
  AyaScreen.payment => const PaymentPage(),
  AyaScreen.orderConfirmed => const OrderConfirmedPage(),
  AyaScreen.pickupPass => const PickupPassPage(),
  AyaScreen.directions => const DirectionsPage(),
  AyaScreen.plans => const PlansPage(),
  AyaScreen.createShop => const CreateShopPage(),
  AyaScreen.shopReady => const ShopReadyPage(),
  AyaScreen.dashboard => const DashboardPage(),
  AyaScreen.newShowcase => const NewShowcasePage(),
  AyaScreen.showcasePhoto => const ShowcasePhotoPage(),
  AyaScreen.showcasePreview => const ShowcasePreviewPage(),
  AyaScreen.showcasePublished => const ShowcasePublishedPage(),
  AyaScreen.shopProfile => const ShopProfilePage(),
  AyaScreen.editShop => const EditShopPage(),
  AyaScreen.shopHours => const ShopHoursPage(),
  AyaScreen.shopAlerts => const ShopAlertsPage(),
};

/// Application des 18 écrans d’Aya, lancée par `lib/main_aya.dart`.
class AyaApp extends StatefulWidget {
  const AyaApp({super.key, this.startAt, this.initialRoute});
  final String? initialRoute;
  final AyaScreen? startAt;
  @override
  State<AyaApp> createState() => _AyaAppState();
}

class _AyaAppState extends State<AyaApp> {
  final controller = AchatBoutiqueController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Route<void> routeFor(RouteSettings settings) {
    final merchant = merchantRouteFor(settings);
    if (merchant != null) return merchant;
    final screen = AyaScreen.fromRoute(settings.name) ?? AyaScreen.cart;
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: screen.route),
      pageBuilder: (_, __, ___) => AyaShell(screen: screen, child: ayaPage(screen)),
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) => AchatBoutiqueScope(controller: controller, child: MaterialApp(
    title: 'LocalDrop', theme: dropTheme(), debugShowCheckedModeBanner: false,
    locale: const Locale('fr'), supportedLocales: const [Locale('fr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    initialRoute: widget.initialRoute ?? (widget.startAt ?? AyaScreen.cart).route,
    onGenerateInitialRoutes: (initial) => [routeFor(RouteSettings(name: initial))],
    onGenerateRoute: routeFor,
  ));
}
