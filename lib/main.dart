import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/account_pages.dart';
import 'src/auth_pages.dart';
import 'src/demo.dart';
import 'src/discovery_pages.dart';
import 'src/navigation.dart';
import 'src/screens.dart';
import 'src/shell.dart';
import 'src/support_pages.dart';
import 'src/ui.dart';
import 'features/client_experience/controllers/client_controller.dart';
import 'features/client_experience/screens/client_experience_pages.dart';
import 'features/client_experience/screens/remaining_pages.dart';
import 'features/client_experience/screens/preferences_pages.dart';

void main() => runApp(const LocalDropApp());

class LocalDropApp extends StatefulWidget {
  const LocalDropApp({super.key, this.startAt, this.onTeamRoute});
  final DropScreen? startAt;
  final TeamNavigator? onTeamRoute;

  @override
  State<LocalDropApp> createState() => _LocalDropAppState();
}

class _LocalDropAppState extends State<LocalDropApp> {
  final account = DemoAccount();
  final clientExperience = ClientExperienceController();
  @override
  void dispose() {
    account.dispose();
    clientExperience.dispose();
    super.dispose();
  }

  Route<void> routeFor(RouteSettings settings) {
    final screen = DropScreen.fromRoute(settings.name) ?? DropScreen.splash;
    final page = switch (screen) {
      DropScreen.splash => const SplashPage(),
      DropScreen.onboarding ||
      DropScreen.nearby ||
      DropScreen.pickup => OnboardingPage(screen),
      DropScreen.roles => const RolePage(),
      DropScreen.login ||
      DropScreen.signupClient ||
      DropScreen.signupMerchant => AuthPage(screen),
      DropScreen.verify => const VerificationPage(),
      DropScreen.reset => const ResetPage(),
      DropScreen.location => const PermissionPage(position: true),
      DropScreen.alerts => const PermissionPage(position: false),
      DropScreen.ready => const WelcomePage(),
      DropScreen.profile => const ProfilePage(),
      DropScreen.editProfile => const EditProfilePage(),
      DropScreen.addresses => const AddressesPage(),
      DropScreen.help => const HelpPage(),
      DropScreen.contact => const ContactPage(),
      DropScreen.aroundMe => const AroundMePage(),
      DropScreen.flashOffers => const FlashOffersPage(),
      DropScreen.search => const SearchPage(),
      DropScreen.filters => const FiltersPage(),
      DropScreen.categories => const CategoriesPage(),
      DropScreen.offerDetail => const OfferDetailPage(),
      DropScreen.shopDetail => const ShopDetailPage(),
      DropScreen.favorites => const FavoritesPage(),
      DropScreen.notifications => const NotificationsPage(),
      DropScreen.orders => const OrdersPage(),
      DropScreen.orderDetail => const OrderDetailPage(),
      DropScreen.purchaseHistory => const PurchaseHistoryPage(),
      DropScreen.review => const ReviewPage(),
      DropScreen.preferences => const PreferencesPage(),
      DropScreen.proximityAlerts => const ProximityAlertsPage(),
      DropScreen.noOffers => const EmptyOffersPage(),
      DropScreen.noOrders => const EmptyOrdersPage(),
      DropScreen.settings => const SettingsPage(),
    };
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: screen.route),
      pageBuilder: (_, __, ___) => ScreenShell(screen: screen, child: page),
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) => DemoScope(
    account: account,
    child: ClientExperienceScope(
      controller: clientExperience,
      child: TeamRoutes(
        onOpen: widget.onTeamRoute,
        child: MaterialApp(
          title: 'LocalDrop',
          theme: dropTheme(),
          debugShowCheckedModeBanner: false,
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          initialRoute: widget.startAt?.route ?? DropScreen.aroundMe.route,
          onGenerateInitialRoutes: (initial) => [
            routeFor(RouteSettings(name: initial)),
          ],
          onGenerateRoute: routeFor,
        ),
      ),
    ),
  );
}
