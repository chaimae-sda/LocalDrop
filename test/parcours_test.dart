import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdrop/main.dart';
import 'package:localdrop/src/screens.dart';
import 'package:localdrop/src/shell.dart';

Future<void> openPage(
  WidgetTester tester,
  DropScreen screen, {
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(LocalDropApp(key: UniqueKey(), startAt: screen));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('Les liens directs Chaimae conservent les numéros des maquettes', () {
    expect(
      DropScreen.values.map((s) => s.number),
      containsAll([
        '00',
        '01',
        '02',
        '03',
        '04',
        '05',
        '06',
        '07',
        '08',
        '09',
        '10',
        '11',
        '12',
        '32',
        '33',
        '34',
        '37',
        '38',
      ]),
    );
    for (final screen in DropScreen.values) {
      expect(DropScreen.fromRoute(screen.route), screen);
    }
  });

  testWidgets('Toutes les pages s’ouvrent sur mobile et ordinateur', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(1280, 800)]) {
      for (final screen in DropScreen.values) {
        await openPage(tester, screen, size: size);
        expect(
          tester.widget<ScreenShell>(find.byType(ScreenShell)).screen,
          screen,
        );
        expect(tester.takeException(), isNull, reason: screen.id);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Connexion de démonstration et modification du profil', (
    tester,
  ) async {
    await openPage(tester, DropScreen.login);
    await tapVisible(tester, find.text('Se connecter'));
    expect(find.text('Saisissez une adresse e-mail valide.'), findsOneWidget);
    await tapVisible(
      tester,
      find.text('Remplir avec le compte de démonstration'),
    );
    await tapVisible(tester, find.text('Se connecter'));
    expect(tester.widget<ScreenShell>(find.byType(ScreenShell)).screen, DropScreen.aroundMe);
    await tapVisible(tester, find.text('Profil').last);
    expect(find.text('Camille Martin'), findsOneWidget);
    await tapVisible(tester, find.text('Mes informations'));
    await tester.enterText(find.byType(TextFormField).first, 'Chaimae Test');
    await tapVisible(tester, find.text('Enregistrer les modifications'));
    expect(find.text('Chaimae Test'), findsOneWidget);
  });

  testWidgets(
    'Les inscriptions client et commerçant mènent à la vérification',
    (tester) async {
      for (final merchant in [false, true]) {
        await openPage(tester, DropScreen.roles);
        await tapVisible(
          tester,
          find.byKey(ValueKey(merchant ? 'choose-merchant' : 'choose-client')),
        );
        final fields = find.byType(TextFormField);
        final values = [
          'Chaimae Test',
          if (merchant) 'Épicerie du coin',
          'chaimae@example.com',
          '0612345678',
          'Panier2026',
        ];
        for (var i = 0; i < values.length; i++) {
          await tester.ensureVisible(fields.at(i));
          await tester.enterText(fields.at(i), values[i]);
        }
        await tapVisible(tester, find.byType(CheckboxListTile));
        await tapVisible(tester, find.text('Créer mon compte'));
        await tester.enterText(find.byKey(const ValueKey('otp')), '0000');
        await tapVisible(tester, find.text('Valider mon code'));
        expect(
          find.text('Saisissez le code de démonstration 8419.'),
          findsOneWidget,
        );
        await tester.enterText(find.byKey(const ValueKey('otp')), '8419');
        await tapVisible(tester, find.text('Valider mon code'));
        await tapVisible(tester, find.text('Plus tard'));
        await tapVisible(tester, find.text('Activer les notifications'));
        expect(find.text('Bienvenue dans le quartier.'), findsOneWidget);
        expect(
          find.text(
            merchant ? 'Ouvrir mon espace commerçant' : 'Explorer les offres',
          ),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('Nouvelle adresse et adresse par défaut', (tester) async {
    await openPage(tester, DropScreen.addresses);
    await tapVisible(tester, find.text('Ajouter une adresse'));
    final fields = find.byType(TextFormField);
    for (final entry in ['Famille', '5 rue des Fleurs', 'Rabat'].indexed) {
      await tester.enterText(fields.at(entry.$1), entry.$2);
    }
    await tapVisible(tester, find.byType(CheckboxListTile));
    await tapVisible(tester, find.text('Enregistrer'));
    expect(find.text('Famille'), findsOneWidget);
    expect(find.text('Par défaut'), findsOneWidget);
  });

  testWidgets('FAQ, formulaire de contact et confirmation locale', (
    tester,
  ) async {
    await openPage(tester, DropScreen.help);
    await tapVisible(tester, find.text('Comment récupérer mon panier ?'));
    expect(find.textContaining('ouvrez le pass de retrait'), findsOneWidget);
    await tapVisible(tester, find.text('Nous contacter'));
    await tapVisible(tester, find.text('Envoyer ma demande'));
    expect(find.text('Renseignez ce champ.'), findsNWidgets(2));
    await tapVisible(tester, find.byType(DropdownButton<String>));
    await tapVisible(tester, find.text('Mon compte').last);
    await tester.enterText(
      find.byType(TextFormField).last,
      'Comment modifier mes informations ?',
    );
    await tapVisible(tester, find.text('Envoyer ma demande'));
    expect(find.text('Demande simulée'), findsOneWidget);
  });

  test('Les 18 écrans Layla sont présents dans les routes', () {
    const layla = [
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '28',
      '29',
      '30',
      '31',
      '35',
      '36',
      '39',
      '40',
      '41',
    ];
    expect(
      layla.map(
        (number) =>
            DropScreen.values.where((screen) => screen.number == number).length,
      ),
      everyElement(1),
    );
  });

  testWidgets('Les écrans Layla principaux s’ouvrent', (tester) async {
    for (final screen in [
      DropScreen.aroundMe,
      DropScreen.flashOffers,
      DropScreen.search,
      DropScreen.filters,
      DropScreen.categories,
      DropScreen.offerDetail,
      DropScreen.shopDetail,
      DropScreen.favorites,
      DropScreen.notifications,
      DropScreen.orders,
      DropScreen.orderDetail,
      DropScreen.purchaseHistory,
      DropScreen.review,
      DropScreen.preferences,
      DropScreen.proximityAlerts,
      DropScreen.noOffers,
      DropScreen.noOrders,
      DropScreen.settings,
    ]) {
      await openPage(tester, screen);
      expect(tester.takeException(), isNull, reason: screen.id);
    }
  });

  testWidgets('Suggestions, filtres, catégories et avis Layla', (tester) async {
    await openPage(tester, DropScreen.search);
    await tester.enterText(find.byType(TextField).first, 'boulangerie');
    await tester.pumpAndSettle();
    expect(find.text('Suggestions'), findsOneWidget);
    expect(find.text('Boulangerie du Pont'), findsOneWidget);

    await openPage(tester, DropScreen.filters);
    expect(find.text('Autour de ma position'), findsOneWidget);
    expect(find.textContaining('Voir les'), findsOneWidget);
    await tapVisible(tester, find.text('Boucherie'));
    expect(find.textContaining('Voir les'), findsOneWidget);
    await tapVisible(tester, find.text('Moins de 10 €'));
    await tapVisible(tester, find.textContaining('Voir les'));

    await openPage(tester, DropScreen.categories);
    expect(find.text('Boucheries'), findsOneWidget);
    expect(find.text('Boulangerie'), findsOneWidget);
    expect(find.textContaining('panier'), findsWidgets);

    await openPage(tester, DropScreen.shopDetail);
    expect(find.text('Offres en cours'), findsOneWidget);
    expect(find.text('Aucune offre disponible actuellement'), findsNothing);
    expect(find.text('Voir l’itinéraire'), findsOneWidget);

    await openPage(tester, DropScreen.purchaseHistory);
    expect(find.text('Donner mon avis'), findsWidgets);
  });
}
