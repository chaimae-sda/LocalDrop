# LocalDrop — écrans de Chaimae

Frontend Flutter en français. Le projet s’ouvre dans VS Code à la racine du dépôt, au niveau du fichier `pubspec.yaml`. La cible fournie est le navigateur Web, avec un affichage mobile et un sélecteur d’écrans sur ordinateur.

## Lancer l’application

1. Installez le SDK Flutter stable (3.32 ou plus récent), l’extension **Flutter** pour VS Code et Chrome ou Edge. [Installation de Flutter dans VS Code](https://docs.flutter.dev/install/with-vs-code)
2. Dans VS Code, ouvrez **Fichier → Ouvrir le dossier…** et sélectionnez **LocalDrop**.
3. Dans le terminal intégré, exécutez `flutter pub get`.
4. Dans **Exécuter et déboguer**, choisissez **LocalDrop · Flutter (Chrome)** ou **LocalDrop · Flutter (Edge)** et appuyez sur **F5**.

Le lancement depuis le terminal est également possible avec `flutter run -d chrome` ou `flutter run -d edge`.

Pour consulter les planches de référence immédiatement, ouvrez [l’aperçu hors ligne](apercu/index.html) dans votre navigateur ou utilisez la configuration **LocalDrop · Maquettes hors ligne**. Le sélecteur, les flèches et les zones de navigation permettent de passer d’une maquette à l’autre. Les champs modifiables et les validations font partie de la version Flutter.

## Parcourir la démo

### Lancer la version mobile Flutter

Depuis la racine du projet, avec le SDK Flutter installé, exécutez une fois
`dart tool/prepare_mobile.dart`, puis `flutter pub get`. Cette commande crée
les projets Android et iOS à partir des modèles du SDK. Les deux utilisent
`lib/main.dart`. Branchez un téléphone Android ou démarrez un émulateur,
puis utilisez `flutter devices` et `flutter run -d <identifiant>`.
Pour obtenir un APK de test, utilisez `flutter build apk --debug`.
Sur macOS avec Xcode, le même projet fonctionne sur simulateur iOS.
La distribution en boutique nécessite vos identifiants définitifs et votre
signature de publication. L’identifiant généré est `com.localdrop.localdrop`.

- Sur ordinateur, le menu latéral donne accès aux 18 écrans. Sur mobile, utilisez le bouton **Tous les écrans** en haut à droite.
- **Connexion** propose de remplir un compte fictif avec `camille@example.com` et `LocalDrop2026`. L’inscription client ou commerçant utilise le code de vérification **8419**.
- Dans **Mon profil**, modifiez les coordonnées ou l’avatar, puis enregistrez. Dans **Mes adresses**, sélectionnez une adresse pour la modifier ou en ajouter une nouvelle.
- Dans le **Centre d’aide**, ouvrez une question ou sélectionnez **Nous contacter** pour essayer le formulaire.
- L’inscription, les permissions, la réinitialisation et le support sont simulés localement. Les changements de la session se réinitialisent au rechargement de la page.

## Écrans attribués

| Parcours | Écrans |
| --- | --- |
| Découverte | 00 Démarrage · 01 Présentation · 02 Proximité · 03 Retrait |
| Authentification | 04 Choix du profil · 05 Connexion · 06 Inscription client · 07 Inscription commerçant · 08 Vérification · 09 Mot de passe oublié |
| Personnalisation | 10 Localisation · 11 Notifications · 12 Bienvenue |
| Compte client | 32 Mon profil · 33 Modifier mon profil · 34 Mes adresses |
| Assistance | 37 Centre d’aide · 38 Contacter le support |

Les routes de [screens.dart](lib/src/screens.dart) reprennent les identifiants du kit. Par exemple, ajoutez `/#/34_client_adresses` à l’adresse locale pour ouvrir les adresses. Les écrans en Dart réutilisent les illustrations du démarrage présentes dans [assets/illustrations](assets/illustrations/).

## Intégration avec le reste de LocalDrop

Le constructeur `LocalDropApp(onTeamRoute: ...)` accepte un rappel qui reçoit le contexte Flutter et la destination `TeamScreen`. Sa propriété `id` correspond à l’écran du catalogue de l’équipe. En mode autonome, un panneau indique la destination et permet de rejoindre le profil client.

## Vérifications

```sh
flutter analyze
flutter test
flutter build web --release
```

Le build Web se trouve dans `build/web`. Pour le consulter, servez **ce dossier** avec un serveur HTTP local.
