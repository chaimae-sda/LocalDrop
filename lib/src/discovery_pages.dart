import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'demo.dart';
import 'navigation.dart';
import 'screens.dart';
import 'ui.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, bounds) {
    final artSize = (bounds.maxHeight * .39).clamp(140.0, 295.0).toDouble();
    return PageScroll(spread: true, padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        StackColumn(center: true, gap: 12, [
          const LogoMark(size: 71),
          Text('LocalDrop', style: headingStyle.copyWith(fontSize: 45, color: Colors.white, letterSpacing: -2.5)),
          const Text('Votre quartier, ses trésors,\nà prix mini.', textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFE5F0E8), fontSize: 17, height: 1.42)),
        ]),
        Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Center(
          child: Image.asset('assets/illustrations/splash.webp',
            height: artSize, fit: BoxFit.contain, semanticLabel: 'Baguette, croissant et légumes du quartier'))),
        StackColumn(center: true, gap: 13, [
          DropButton('Découvrir LocalDrop', icon: Icons.chevron_right_rounded,
            style: ActionStyle.white, onPressed: () => go(context, DropScreen.onboarding)),
          const Text('Du bon, du local, moins de gaspillage.', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFFBED4C5))),
        ]),
      ]);
  });
}

const _slides = [
  (DropScreen.onboarding, 'Le meilleur du quartier, à petit prix.',
    'Découvrez les paniers d’invendus de vos commerces préférés.', 'Pains et légumes au pied d’un téléphone'),
  (DropScreen.nearby, 'Des offres Flash près de chez vous.',
    'Recevez une alerte dès qu’un commerçant publie une offre à proximité.', 'Une vente Flash sur un téléphone'),
  (DropScreen.pickup, 'Un retrait simple et rapide.',
    'Réservez votre panier, payez en ligne et présentez votre QR code.', 'Une coche sur un téléphone confirme le retrait'),
];

class OnboardingPage extends StatelessWidget {
  const OnboardingPage(this.screen, {super.key});
  final DropScreen screen;
  @override
  Widget build(BuildContext context) {
    final index = _slides.indexWhere((slide) => slide.$1 == screen);
    final slide = _slides[index];
    void next() => go(context, index == 2 ? DropScreen.roles : _slides[index + 1].$1);
    return LayoutBuilder(builder: (context, bounds) => GestureDetector(
      onHorizontalDragEnd: (details) {
        final speed = details.primaryVelocity ?? 0;
        if (speed < -230) next();
        if (speed > 230 && index > 0) goBack(context, _slides[index - 1].$1);
      },
      child: PageScroll(spread: true, padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const LogoMark(size: 39),
            TextButton(onPressed: () => go(context, DropScreen.roles), child: const Text('Passer')),
          ]),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(borderRadius: BorderRadius.circular(19), child: ColoredBox(color: mint,
              child: Image.asset('assets/illustrations/onboarding_${index + 1}.webp',
                width: double.infinity, height: math.min(bounds.maxWidth * 1.07,
                    (bounds.maxHeight * .47).clamp(160.0, 385.0).toDouble()),
                fit: BoxFit.contain, semanticLabel: slide.$4)))),
          StackColumn(gap: 10, [
            Align(alignment: Alignment.centerLeft, child: Pill('LOCALDROP · 0${index + 1}')),
            Semantics(header: true, child: Text(slide.$2, style: headingStyle)),
            Text(slide.$3, style: copyStyle),
          ]),
          Padding(padding: const EdgeInsets.only(top: 18), child: StackColumn(gap: 16, [
            Semantics(label: 'Étape ${index + 1} sur 3', child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (var dot = 0; dot < 3; dot++) Container(
                width: dot == index ? 25 : 7, height: 7, margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(color: dot == index ? orange : const Color(0xFFD3E0D7),
                    borderRadius: BorderRadius.circular(10)))],
            )),
            DropButton(index == 2 ? 'Commencer' : 'Continuer', onPressed: next, icon: Icons.chevron_right_rounded),
          ])),
        ]),
    ));
  }
}

class RolePage extends StatelessWidget {
  const RolePage({super.key});
  @override
  Widget build(BuildContext context) => PageScroll(children: [
    const Padding(padding: EdgeInsets.only(top: 10, bottom: 34),
      child: Intro('Bienvenue sur LocalDrop', 'Choisissez votre espace pour commencer.', logo: true)),
    for (final (isMerchant, title, description, image) in [
      (false, 'Je suis client', 'Je découvre les ventes Flash près de moi.', 'client'),
      (true, 'Je suis commerçant', 'Je crée ma vitrine et écoule mes invendus.', 'merchant'),
    ]) Padding(padding: const EdgeInsets.only(bottom: 12), child: SurfaceCard(child: StackColumn(gap: 8, [
      Align(alignment: Alignment.centerLeft, child: ClipRRect(borderRadius: BorderRadius.circular(11),
        child: Image.asset('assets/illustrations/$image.webp', width: 47, height: 47,
          fit: BoxFit.cover, excludeFromSemantics: true))),
      Text(title, style: strongStyle.copyWith(fontSize: 18)),
      Text(description, style: copyStyle.copyWith(fontSize: 13)),
      DropButton('Continuer', style: ActionStyle.outline,
        key: ValueKey(isMerchant ? 'choose-merchant' : 'choose-client'),
        onPressed: () => go(context, isMerchant ? DropScreen.signupMerchant : DropScreen.signupClient)),
    ]))),
    Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
      const Text('Déjà inscrit ?'), TextButton(onPressed: () => go(context, DropScreen.login), child: const Text('Se connecter')),
    ]),
  ]);
}

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key, required this.position});
  final bool position;
  @override
  Widget build(BuildContext context) {
    final account = DemoScope.of(context);
    void proceed(bool allow) {
      if (position) {
        account.locationAllowed = allow;
      } else {
        account.alertsAllowed = allow;
      }
      go(context, position ? DropScreen.alerts : DropScreen.ready);
    }
    return PageScroll(children: [
      const SizedBox(height: 12),
      Center(child: _CircleArt(icon: position ? Icons.location_on_outlined : Icons.notifications_none_rounded)),
      const SizedBox(height: 25),
      const Center(child: Kicker('Personnalisation')),
      const SizedBox(height: 11),
      Text(position ? 'Les meilleures offres sont près de vous.' : 'Ne manquez aucune vente Flash.',
        style: headingStyle, textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(position ? 'Autorisez votre position pour repérer les commerces du quartier et calculer les distances.'
        : 'Recevez une notification dès qu’un panier est disponible chez un commerçant proche.',
        style: copyStyle, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      SurfaceCard(child: StackColumn(gap: 9, [
        Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8, runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(position ? 'Position approximative' : 'Alertes LocalDrop', style: strongStyle),
          const Pill('Recommandé')]),
        Text(position ? 'Utilisée uniquement pour les offres autour de vous.'
          : 'Vous pouvez gérer les alertes à tout moment.', style: copyStyle.copyWith(fontSize: 12)),
      ])),
      const SizedBox(height: 22),
      DropButton(position ? 'Autoriser ma position' : 'Activer les notifications',
        icon: Icons.check_rounded, onPressed: () => proceed(true)),
      const SizedBox(height: 10),
      DropButton('Plus tard', style: ActionStyle.outline, onPressed: () => proceed(false)),
    ]);
  }
}

class _CircleArt extends StatelessWidget {
  const _CircleArt({required this.icon, this.checked = false});
  final IconData icon;
  final bool checked;
  @override
  Widget build(BuildContext context) {
    final size = checked ? 134.0 : 181.0;
    return ExcludeSemantics(child: Container(width: size, height: size, alignment: Alignment.center,
      decoration: BoxDecoration(color: checked ? mint : pale, shape: BoxShape.circle),
      child: Container(width: size * .82, height: size * .82,
        decoration: BoxDecoration(color: checked ? success : mint, shape: BoxShape.circle),
        child: Icon(icon, size: checked ? 55 : 75, color: checked ? Colors.white : success))));
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final merchant = DemoScope.of(context).merchant;
    return PageScroll(children: [
      const SizedBox(height: 28),
      const Center(child: _CircleArt(icon: Icons.check_rounded, checked: true)),
      const SizedBox(height: 12),
      const Center(child: Kicker('C’est parti !')),
      const SizedBox(height: 18),
      const Text('Bienvenue dans le quartier.', style: headingStyle, textAlign: TextAlign.center),
      const SizedBox(height: 10),
      Text(merchant ? 'Votre compte commerçant est prêt. Vous pouvez maintenant préparer votre boutique.'
        : 'Votre compte est prêt. Il ne reste qu’à découvrir vos premières offres.', style: copyStyle, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      SurfaceCard(child: StackColumn(gap: 6, [
        const Text('Votre aventure commence ici', style: strongStyle),
        Text(merchant ? 'Créez votre vitrine pour proposer vos premiers paniers.'
          : 'Explorez les commerces à proximité, réservez et récupérez vos paniers.', style: copyStyle),
      ])),
      const SizedBox(height: 18),
      DropButton(merchant ? 'Ouvrir mon espace commerçant' : 'Explorer les offres',
        icon: Icons.chevron_right_rounded,
        onPressed: () => openTeam(context, merchant ? TeamScreen.merchantSetup : TeamScreen.clientHome)),
      if (!merchant) TextButton(onPressed: () => jump(context, DropScreen.profile), child: const Text('Voir mon profil')),
    ]);
  }
}
