enum DropScreen {
  splash('00_splash', 'Bienvenue sur LocalDrop'),
  onboarding('01_onboarding', 'Les bons paniers'),
  nearby('02_onboarding_proximite', 'Votre quartier'),
  pickup('03_onboarding_retrait', 'Le retrait'),
  roles('04_choix_profil', 'Choix du profil'),
  login('05_connexion', 'Connexion'),
  signupClient('06_inscription_client', 'Inscription client'),
  signupMerchant('07_inscription_commercant', 'Inscription commerçant'),
  verify('08_verification', 'Vérification'),
  reset('09_mot_de_passe', 'Mot de passe oublié'),
  location('10_autorisation_position', 'Localisation'),
  alerts('11_autorisation_notifications', 'Notifications'),
  ready('12_bienvenue', 'Compte prêt'),
  profile('32_client_profil', 'Mon profil'),
  editProfile('33_client_modifier_profil', 'Modifier mon profil'),
  addresses('34_client_adresses', 'Mes adresses'),
  help('37_client_aide', 'Centre d’aide'),
  contact('38_client_contact', 'Contacter le support');

  const DropScreen(this.id, this.label);
  final String id;
  final String label;
  String get route => '/$id';
  String get number => id.substring(0, 2);
  bool get inAccount => index >= profile.index;

  static DropScreen? fromRoute(String? name) {
    if (name == null || name == '/') return splash;
    final id = Uri.tryParse(name)?.pathSegments.lastOrNull;
    for (final screen in values) {
      if (screen.id == id) return screen;
    }
    return null;
  }
}

const screenGroups = <String, List<DropScreen>>{
  'Découverte': [
    DropScreen.splash, DropScreen.onboarding, DropScreen.nearby, DropScreen.pickup,
  ],
  'Accès au compte': [
    DropScreen.roles, DropScreen.login, DropScreen.signupClient,
    DropScreen.signupMerchant, DropScreen.verify, DropScreen.reset,
  ],
  'Personnalisation': [DropScreen.location, DropScreen.alerts, DropScreen.ready],
  'Espace client': [
    DropScreen.profile, DropScreen.editProfile, DropScreen.addresses,
    DropScreen.help, DropScreen.contact,
  ],
};

enum TeamScreen {
  clientHome('13_client_accueil', 'Accueil client'),
  explore('14_client_liste', 'Explorer'),
  orders('28_client_commandes', 'Mes commandes'),
  favorites('20_client_favoris', 'Mes favoris'),
  notifications('36_client_reglages_alertes', 'Réglages des alertes'),
  settings('41_client_parametres', 'Paramètres'),
  merchantSetup('42_pro_formules', 'Espace commerçant');

  const TeamScreen(this.id, this.label);
  final String id;
  final String label;
}
