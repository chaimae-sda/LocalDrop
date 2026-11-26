import 'package:flutter/widgets.dart';

enum MerchantScreen {
  live('50_pro_vitrine_active', 'Vitrine en cours'),
  orders('51_pro_commandes', 'Commandes du jour'),
  detail('52_pro_detail_commande', 'Détail de commande'),
  scan('53_pro_scanner_qr', 'Scanner le pass client'),
  code('54_pro_code_secours', 'Saisir le code client'),
  done('55_pro_retrait_valide', 'Retrait confirmé'),
  showcases('56_pro_mes_vitrines', 'Mes vitrines'),
  edit('57_pro_modifier_vitrine', 'Modifier la vitrine'),
  stock('58_pro_stock', 'Gestion du stock'),
  stats('59_pro_statistiques', 'Statistiques'),
  sales('60_pro_ventes', 'Historique des ventes'),
  plan('61_pro_abonnement', 'Mon abonnement'),
  settings('66_pro_parametres', 'Paramètres'),
  support('67_pro_support', 'Aide commerçant'),
  empty('68_pro_sans_commandes', 'En attente de commandes'),
  billing('69_pro_facturation', 'Facturation'),
  team('70_pro_equipe', 'Équipe boutique');

  const MerchantScreen(this.id, this.label);
  final String id, label;
  String get route => '/$id';
  String get number => id.substring(0, 2);

  static MerchantScreen? fromRoute(String? name) {
    final id = Uri.tryParse(name ?? '')?.pathSegments.lastOrNull;
    return values.where((s) => s.id == id).firstOrNull;
  }

  int? get tab => switch (this) {
    scan || code || done => null,
    showcases || edit || stock => 1,
    stats || sales => 3,
    plan || settings || support || billing || team => 4,
    _ => 0,
  };
}

void openMerchant(
  BuildContext context,
  MerchantScreen screen, {
  int? order,
  bool replace = false,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  final navigator = Navigator.of(context);
  if (replace) {
    navigator.pushReplacementNamed(screen.route, arguments: order);
  } else {
    navigator.pushNamed(screen.route, arguments: order);
  }
}
