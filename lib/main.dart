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
  @override
  void dispose() { account.dispose(); super.dispose(); }

  Route<void> routeFor(RouteSettings settings) {
    final screen = DropScreen.fromRoute(settings.name) ?? DropScreen.splash;
    final page = switch (screen) {
      DropScreen.splash => const SplashPage(),
      DropScreen.onboarding || DropScreen.nearby || DropScreen.pickup => OnboardingPage(screen),
      DropScreen.roles => const RolePage(),
      DropScreen.login || DropScreen.signupClient || DropScreen.signupMerchant => AuthPage(screen),
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
    };
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: screen.route),
      pageBuilder: (_, __, ___) => ScreenShell(screen: screen, child: page),
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) => DemoScope(account: account, child: TeamRoutes(
    onOpen: widget.onTeamRoute, child: MaterialApp(
      title: 'LocalDrop', theme: dropTheme(), debugShowCheckedModeBanner: false,
      locale: const Locale('fr'), supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: widget.startAt?.route,
      onGenerateInitialRoutes: (initial) => [routeFor(RouteSettings(name: initial))],
      onGenerateRoute: routeFor,
    )));
}
