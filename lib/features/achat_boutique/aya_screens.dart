/// Les 18 écrans d’Aya. Les identifiants reprennent les noms des maquettes.
enum AyaScreen {
  cart('22_client_panier', 'Mon panier'),
  checkout('23_client_recapitulatif', 'Récapitulatif'),
  payment('24_client_paiement', 'Moyen de paiement'),
  orderConfirmed('25_client_confirmation', 'Commande confirmée'),
  pickupPass('26_client_pass_qr', 'Mon pass de retrait'),
  directions('27_client_itineraire', 'Itinéraire'),
  plans('42_pro_formules', 'Choisir votre formule'),
  createShop('43_pro_creer_boutique', 'Créer ma boutique'),
  shopReady('44_pro_boutique_prete', 'Boutique prête'),
  dashboard('45_pro_tableau_de_bord', 'Tableau de bord'),
  newShowcase('46_pro_nouvelle_vitrine', 'Nouvelle Vitrine Flash'),
  showcasePhoto('47_pro_photo', 'Photo du panier'),
  showcasePreview('48_pro_apercu_vitrine', 'Aperçu de ma vitrine'),
  showcasePublished('49_pro_publication_ok', 'Vitrine publiée'),
  shopProfile('62_pro_profil_boutique', 'Profil de la boutique'),
  editShop('63_pro_modifier_boutique', 'Modifier la boutique'),
  shopHours('64_pro_horaires', 'Horaires & retrait'),
  shopAlerts('65_pro_alertes', 'Notifications');

  const AyaScreen(this.id, this.label);
  final String id;
  final String label;
  String get route => '/$id';
  String get number => id.substring(0, 2);

  /// Écrans de l’espace commerçant (préfixe `_pro_` des maquettes).
  bool get merchant => id.contains('_pro_');

  /// L’écran 25 n’a pas d’en-tête vert dans la maquette.
  bool get hasHeader => this != orderConfirmed;

  /// Onglet actif de la barre du bas, comme sur les maquettes ; `null` sans barre.
  int? get tab => switch (this) {
    cart || checkout || payment || directions => 0,
    dashboard || showcasePhoto || editShop || shopHours || shopAlerts => 0,
    newShowcase || showcasePreview => 1,
    shopProfile => 4,
    _ => null,
  };

  /// Écran précédent quand l’historique est vide (écran d’Aya ou [TeamLink]).
  Object? get back => switch (this) {
    cart => TeamLink.offerDetail,
    checkout => cart,
    payment => checkout,
    orderConfirmed => null,
    pickupPass => orderConfirmed,
    directions => pickupPass,
    plans => TeamLink.welcome,
    createShop => plans,
    shopReady => createShop,
    dashboard => shopReady,
    newShowcase || showcasePublished || shopProfile => dashboard,
    showcasePhoto || showcasePreview => newShowcase,
    editShop || shopHours || shopAlerts => shopProfile,
  };

  static AyaScreen? fromRoute(String? name) {
    final id = Uri.tryParse(name ?? '')?.pathSegments.lastOrNull;
    for (final screen in values) {
      if (screen.id == id) return screen;
    }
    return null;
  }
}

const ayaGroups = <String, List<AyaScreen>>{
  'Achat client': [
    AyaScreen.cart, AyaScreen.checkout, AyaScreen.payment,
    AyaScreen.orderConfirmed, AyaScreen.pickupPass, AyaScreen.directions,
  ],
  'Création de boutique': [
    AyaScreen.plans, AyaScreen.createShop, AyaScreen.shopReady, AyaScreen.dashboard,
  ],
  'Vitrine Flash': [
    AyaScreen.newShowcase, AyaScreen.showcasePhoto,
    AyaScreen.showcasePreview, AyaScreen.showcasePublished,
  ],
  'Profil boutique': [
    AyaScreen.shopProfile, AyaScreen.editShop, AyaScreen.shopHours, AyaScreen.shopAlerts,
  ],
};

/// Écrans des autres membres vers lesquels mènent les boutons de mes maquettes.
enum TeamLink {
  welcome('12_bienvenue', 'Votre compte est prêt', 'Chaimae'),
  clientProfile('32_client_profil', 'Mon profil', 'Chaimae'),
  clientHome('13_client_accueil', 'Autour de moi', 'Layla'),
  explore('14_client_liste', 'Ventes Flash', 'Layla'),
  offerDetail('18_client_fiche_panier', 'Panier Baguettes & Tartes', 'Layla'),
  orders('28_client_commandes', 'Mes commandes', 'Layla'),
  orderDetail('29_client_detail_commande', 'Détail de commande', 'Layla'),
  activeShowcase('50_pro_vitrine_active', 'Vitrine en cours', 'Oussama'),
  merchantOrderDetail('52_pro_detail_commande', 'Commande #1042', 'Oussama'),
  scanner('53_pro_scanner_qr', 'Scanner le pass client', 'Oussama'),
  showcases('56_pro_mes_vitrines', 'Mes vitrines', 'Oussama'),
  stats('59_pro_statistiques', 'Statistiques', 'Oussama'),
  subscription('61_pro_abonnement', 'Mon abonnement', 'Oussama'),
  merchantSettings('66_pro_parametres', 'Paramètres', 'Oussama'),
  merchantSupport('67_pro_support', 'Aide commerçant', 'Oussama'),
  billing('69_pro_facturation', 'Facturation', 'Oussama'),
  shopTeam('70_pro_equipe', 'Équipe boutique', 'Oussama');

  const TeamLink(this.id, this.label, this.owner);
  final String id;
  final String label;
  final String owner;
  String get number => id.substring(0, 2);
}
