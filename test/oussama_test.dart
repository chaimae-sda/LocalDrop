import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdrop/main.dart' show LocalDropApp;
import 'package:localdrop/features/achat_boutique/aya_screens.dart';
import 'package:localdrop/features/achat_boutique/controllers/achat_boutique_controller.dart';
import 'package:localdrop/features/gestion_commercant/merchant_screen.dart';
import 'package:localdrop/features/gestion_commercant/merchant_shell.dart';

Future<void> launch(
  WidgetTester t,
  String route, {
  Size size = const Size(390, 844),
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = size;
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPhysicalSize);
  await t.pumpWidget(LocalDropApp(key: UniqueKey(), initialRoute: route));
  await t.pumpAndSettle();
}

Future<void> tapLabel(WidgetTester t, String label) async {
  final finder = find.text(label).last;
  await t.ensureVisible(finder);
  await t.tap(finder);
  await t.pumpAndSettle();
}

void main() {
  test(
    'Le pass d’Aya, le retrait unique et les stocks utilisent la même commande',
    () {
      final shop = AchatBoutiqueController();
      addTearDown(shop.dispose);
      final karim = shop.byQr('LD-1042-8419')!;
      expect(shop.byCode('8419'), same(karim));
      expect(shop.byCode('0000'), isNull);
      expect(shop.byQr('LD-1043-8419'), isNull);
      expect(shop.collect(karim), isTrue);
      expect(shop.collect(karim), isFalse);
      expect(shop.pending.single.order.number, 1043);
      expect((shop.sold, shop.remaining, shop.liveCents), (2, 1, 1200));
      expect(shop.updateLive(shop.live.copyWith(quantity: 1)), isFalse);
      expect(
        shop.updateLive(shop.live.copyWith(quantity: 4, price: 7)),
        isTrue,
      );
      expect(
        (shop.remaining, shop.liveCents, karim.order.price),
        (2, 1200, 6.0),
      );
      shop.endShowcase();
      expect(shop.forSale, 0);
      expect(shop.updateLive(shop.live.copyWith(quantity: 8)), isFalse);
      shop.updateDraft(
        shop.draft.copyWith(title: 'Panier de fruits', quantity: 5),
      );
      shop.publish();
      expect((shop.sold, shop.remaining, shop.liveCents), (0, 5, 0));
      expect(shop.livePending, isEmpty);
      expect(shop.pending.single.product, 'Panier Baguettes & Tartes');
      expect(shop.collect(shop.byCode('5732')!), isTrue);
      expect(shop.remaining, 5);
    },
  );

  testWidgets('Les 17 écrans s’affichent sur téléphone et ordinateur', (
    t,
  ) async {
    expect(MerchantScreen.values.map((s) => s.number), [
      '50',
      '51',
      '52',
      '53',
      '54',
      '55',
      '56',
      '57',
      '58',
      '59',
      '60',
      '61',
      '66',
      '67',
      '68',
      '69',
      '70',
    ]);
    for (final size in [const Size(320, 640), const Size(1280, 800)]) {
      for (final screen in MerchantScreen.values) {
        await launch(t, screen.route, size: size);
        expect(
          t.widget<MerchantShell>(find.byType(MerchantShell)).screen,
          screen,
        );
        expect(
          t.takeException(),
          isNull,
          reason: '${screen.id} à ${size.width} px',
        );
      }
    }
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Karim présente son code, puis passe dans les commandes terminées',
    (t) async {
      await launch(t, MerchantScreen.live.route);
      await tapLabel(t, 'Voir tout');
      await tapLabel(t, '#1042');
      await tapLabel(t, 'Utiliser le code de secours');
      final code = find.byKey(const ValueKey('pickup-code'));
      await t.enterText(code, '0000');
      await t.pump();
      expect(
        find.text('Code inconnu. Vérifiez les quatre chiffres du pass.'),
        findsOneWidget,
      );
      await t.enterText(code, '5732');
      await t.pump();
      expect(
        find.text('Ce code correspond à une autre commande.'),
        findsOneWidget,
      );
      await t.enterText(code, '8419');
      await t.pump();
      await tapLabel(t, 'Valider le retrait');
      expect(find.text('Panier remis avec succès !'), findsOneWidget);
      await tapLabel(t, 'Voir les autres commandes');
      expect(find.text('À remettre (1)'), findsOneWidget);
      expect(find.text('Sophie T.'), findsOneWidget);
      await tapLabel(t, 'Terminées');
      expect(find.text('Karim M.'), findsOneWidget);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'La démo commune relie la vitrine du tableau de bord à l’écran 50',
    (t) async {
      await launch(t, AyaScreen.dashboard.route);
      await tapLabel(t, 'Voir ma vitrine');
      expect(
        t.widget<MerchantShell>(find.byType(MerchantShell)).screen,
        MerchantScreen.live,
      );
      expect(find.text('Karim M.'), findsOneWidget);
      await tapLabel(t, 'Voir tout');
      expect(find.text('À remettre (2)'), findsOneWidget);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Le tableau d’Aya ouvre la bonne commande et le scanner la remet',
    (t) async {
      await launch(t, AyaScreen.dashboard.route);
      await tapLabel(t, 'Commande #1043');
      expect(find.text('Sophie T.'), findsOneWidget);
      await tapLabel(t, 'Scanner le pass QR');
      await tapLabel(t, 'Simuler la lecture du pass');
      expect(find.text('#1043'), findsOneWidget);
      await tapLabel(t, 'Confirmer la remise du panier');
      expect(
        find.text('La commande #1043 est désormais marquée « Retirée ».'),
        findsOneWidget,
      );
      await tapLabel(t, 'Retour au tableau de bord');
      await tapLabel(t, 'Commande #1043');
      expect(
        find.text('Ce panier a déjà été remis au client.'),
        findsOneWidget,
      );
      await t.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'L’édition de stock revient à la vitrine avec la nouvelle quantité',
    (t) async {
      await launch(t, MerchantScreen.stock.route);
      await t.tap(find.byTooltip('Ajouter un panier'));
      await t.pump();
      await tapLabel(t, 'Mettre le stock à jour');
      expect(
        t.widget<MerchantShell>(find.byType(MerchantShell)).screen,
        MerchantScreen.live,
      );
      await tapLabel(t, 'Gérer les quantités');
      expect(find.text('4 paniers'), findsOneWidget);
      expect(find.text('2 paniers'), findsNWidgets(2));
      await t.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'La fin du créneau ferme la vente et conserve les retraits payés',
    (t) async {
      await launch(t, MerchantScreen.live.route);
      await t.pump(const Duration(minutes: 74));
      await t.pumpAndSettle();
      expect(find.text('TERMINÉE'), findsOneWidget);
      expect(find.text('Modifier cette vitrine'), findsNothing);
      expect(find.text('Karim M.'), findsOneWidget);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
}
