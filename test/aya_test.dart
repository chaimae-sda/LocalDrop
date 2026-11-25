import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdrop/features/achat_boutique/aya_app.dart';
import 'package:localdrop/features/achat_boutique/aya_screens.dart';
import 'package:localdrop/features/achat_boutique/aya_shell.dart';

Future<void> openAya(WidgetTester tester, AyaScreen screen, {Size size = const Size(390, 844)}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(AyaApp(key: UniqueKey(), startAt: screen));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('Les 18 écrans d’Aya gardent les numéros des maquettes', () {
    expect(AyaScreen.values.map((s) => s.number),
      ['22','23','24','25','26','27','42','43','44','45','46','47','48','49','62','63','64','65']);
    for (final screen in AyaScreen.values) {
      expect(AyaScreen.fromRoute(screen.route), screen);
    }
    expect(ayaGroups.values.expand((group) => group).toSet(), AyaScreen.values.toSet());
  });

  testWidgets('Les 18 écrans s’ouvrent sur mobile et ordinateur', (tester) async {
    for (final size in [const Size(320, 640), const Size(1280, 800)]) {
      for (final screen in AyaScreen.values) {
        await openAya(tester, screen, size: size);
        expect(tester.widget<AyaShell>(find.byType(AyaShell)).screen, screen);
        expect(tester.takeException(), isNull, reason: screen.id);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Achat : panier, nouvelle carte, confirmation, pass et itinéraire', (tester) async {
    await openAya(tester, AyaScreen.cart);
    expect(find.text('Total à payer'), findsOneWidget);
    await tapVisible(tester, find.text('Continuer'));
    expect(find.text('Visa se terminant par 4242'), findsOneWidget);
    await tapVisible(tester, find.text('Carte bancaire'));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '1234 5678');
    await tapVisible(tester, find.text('Payer 6,00 €'));
    expect(find.text('Vérifiez le numéro de carte.'), findsOneWidget);
    expect(find.text('Format MM/AA.'), findsOneWidget);
    await tester.enterText(fields.at(0), '5555 5555 5555 4444');
    await tester.enterText(fields.at(1), '12/39');
    await tester.enterText(fields.at(2), '123');
    await tapVisible(tester, find.text('Payer 6,00 €'));

    expect(find.text('Commande confirmée !'), findsOneWidget);
    expect(find.text('#1042'), findsOneWidget);
    expect(find.byTooltip('Retour'), findsNothing);
    await tapVisible(tester, find.text('Afficher mon QR code'));
    expect(find.bySemanticsLabel('Code de secours 8 4 1 9'), findsOneWidget);
    await tapVisible(tester, find.text('Itinéraire vers le commerce'));
    expect(find.text('3 min · 200 m'), findsOneWidget);
    await tapVisible(tester, find.text('Afficher mon pass de retrait'));
    expect(find.text('Présentez ce QR code au commerçant'), findsOneWidget);
  });

  testWidgets('Les écrans des autres membres sont indiqués', (tester) async {
    await openAya(tester, AyaScreen.orderConfirmed);
    await tapVisible(tester, find.text('Retour à l’accueil'));
    expect(find.text('Cet écran appartient au parcours de Layla.'), findsOneWidget);
  });

  testWidgets('Création de boutique jusqu’à la publication d’une Vitrine Flash', (tester) async {
    await openAya(tester, AyaScreen.plans);
    await tapVisible(tester, find.text('PLAN DÉCOUVERTE'));
    await tapVisible(tester, find.text('Continuer vers ma boutique'));
    await tapVisible(tester, find.text('Créer ma boutique').last);
    expect(find.text('Renseignez ce champ.'), findsNWidgets(3));
    final fields = find.byType(TextFormField);
    for (final (i, value) in ['Épicerie du coin', 'Épicerie', '5, Rue des Fleurs, Lyon', '0612345678'].indexed) {
      await tester.enterText(fields.at(i), value);
    }
    await tapVisible(tester, find.text('Créer ma boutique').last);

    expect(find.text('Votre boutique est prête !'), findsOneWidget);
    expect(find.text('Découverte'), findsOneWidget);
    await tapVisible(tester, find.text('Créer ma première vitrine'));

    await tester.enterText(find.byType(TextFormField).at(2), '20');
    await tapVisible(tester, find.text('Prévisualiser la vitrine'));
    expect(find.text('Inférieur à la valeur initiale.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), '6');
    await tapVisible(tester, find.byTooltip('Ajouter un panier'));

    await tapVisible(tester, find.text('Importer / photographier'));
    await tapVisible(tester, find.text('Utiliser cette photo'));
    expect(find.text('Prenez ou choisissez d’abord une photo.'), findsOneWidget);
    await tapVisible(tester, find.text('Choisir depuis la galerie'));
    await tapVisible(tester, find.text('Utiliser cette photo'));
    expect(find.text('Photo ajoutée'), findsOneWidget);

    await tapVisible(tester, find.text('Prévisualiser la vitrine'));
    expect(find.text('-60 %'), findsOneWidget);
    expect(find.text('4 paniers'), findsOneWidget);
    expect(find.text('Épicerie du coin'), findsOneWidget);
    await tapVisible(tester, find.text('Publier la Vitrine Flash'));
    expect(find.text('Votre vitrine est en ligne !'), findsOneWidget);
    await tapVisible(tester, find.text('Retour au tableau de bord'));
    expect(find.text('0 / 4'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('Profil boutique, horaires et notifications', (tester) async {
    await openAya(tester, AyaScreen.shopProfile);
    expect(find.text('Premium · 15 € / mois'), findsOneWidget);
    await tapVisible(tester, find.text('Informations du commerce'));
    await tester.enterText(find.byType(TextFormField).first, 'Boulangerie Aya');
    await tapVisible(tester, find.text('Enregistrer'));
    expect(find.text('Boulangerie Aya'), findsOneWidget);

    await tapVisible(tester, find.text('Horaires et retrait'));
    expect(find.text('Fermé'), findsOneWidget);
    await tapVisible(tester, find.text('Samedi'));
    await tapVisible(tester, find.byType(Switch));
    await tapVisible(tester, find.text('Valider'));
    expect(find.text('Fermé'), findsNWidgets(2));
    await tapVisible(tester, find.text('Enregistrer les horaires'));
    expect(find.text('Profil de la boutique'), findsWidgets);

    await openAya(tester, AyaScreen.shopAlerts);
    expect(find.text('Nouvelle commande #1043'), findsOneWidget);
    final reminder = find.widgetWithText(SwitchListTile, 'Rappel de fin de vente');
    await tapVisible(tester, reminder);
    expect(tester.widget<SwitchListTile>(reminder).value, isFalse);
  });
}
