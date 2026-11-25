import 'package:flutter/material.dart';

import '../models/achat_boutique_models.dart';

/// Données fictives des écrans d’Aya pour la session. Aucun paiement réel n’est
/// effectué et aucun numéro de carte complet n’est conservé.
class AchatBoutiqueController extends ChangeNotifier {
  // ---------- Achat client (22 à 27) ----------
  final offer = const BasketOffer(
    title: 'Panier Baguettes & Tartes', shop: 'Boulangerie de la Place',
    address: '12, Rue du Commerce, 75001 Paris', price: 6,
    pickupFrom: TimeOfDay(hour: 18, minute: 45), pickupUntil: TimeOfDay(hour: 19, minute: 30),
    distance: 200, walkMinutes: 3);
  final double serviceFee = 0;
  double get total => offer.price + serviceFee;

  final List<PaymentCard> _cards = [const PaymentCard('Visa', '4242', '12/28')];
  List<PaymentCard> get cards => List.unmodifiable(_cards);
  int selectedCard = 0;
  PaymentCard get card => _cards[selectedCard];

  final int orderNumber = 1042;
  final String pickupCode = '8419';

  void selectCard(int index) {
    selectedCard = index;
    notifyListeners();
  }

  /// Ajoute la carte saisie et la sélectionne.
  void addCard(String number, String expiry) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    _cards.add(PaymentCard(cardBrand(digits), digits.substring(digits.length - 4), expiry));
    selectedCard = _cards.length - 1;
    notifyListeners();
  }

  // ---------- Boutique (42 à 49 et 62 à 65) ----------
  ShopPlan plan = ShopPlan.premium;
  ShopInfo shop = const ShopInfo(name: 'Boulangerie de la Place', category: 'Boulangerie',
    address: '12, Rue du Commerce, Paris', phone: '01 40 00 00 00');
  final String merchantName = 'Nadia';

  List<DayHours> hours = const [
    DayHours('Lundi', TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 19, minute: 30)),
    DayHours('Mardi', TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 19, minute: 30)),
    DayHours('Mercredi', TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 19, minute: 30)),
    DayHours('Jeudi', TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 19, minute: 30)),
    DayHours('Vendredi', TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 19, minute: 30)),
    DayHours('Samedi', TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 19, minute: 0)),
    DayHours('Dimanche'),
  ];
  TimeOfDay defaultPickup = const TimeOfDay(hour: 19, minute: 30);

  /// Vitrine Flash en préparation (46 à 48).
  late Showcase draft = _newDraft();

  /// Vitrine du jour affichée au tableau de bord.
  Showcase live = const Showcase(title: 'Panier Baguettes & Tartes', initialValue: 15, price: 6,
    quantity: 3, pickupUntil: TimeOfDay(hour: 19, minute: 30));
  int sold = 2;

  final List<MerchantOrder> recentOrders = const [
    MerchantOrder(1043, 'Sophie T.', 6, TimeOfDay(hour: 19, minute: 0)),
    MerchantOrder(1042, 'Karim M.', 6, TimeOfDay(hour: 18, minute: 45)),
  ];

  bool orderAlerts = true;
  bool endOfSaleReminder = true;

  Showcase _newDraft() => Showcase(title: 'Panier Baguettes & Tartes', initialValue: 15, price: 6,
    quantity: 3, pickupUntil: defaultPickup);

  void choosePlan(ShopPlan value) {
    plan = value;
    notifyListeners();
  }

  void saveShop(ShopInfo info) {
    shop = info;
    notifyListeners();
  }

  void saveHours(List<DayHours> value, TimeOfDay pickup) {
    hours = List.unmodifiable(value);
    defaultPickup = pickup;
    notifyListeners();
  }

  void updateDraft(Showcase value) {
    draft = value;
    notifyListeners();
  }

  void choosePhoto(PhotoSource source) => updateDraft(draft.copyWith(photo: source));

  void publish() {
    live = draft;
    sold = 0;
    draft = _newDraft();
    notifyListeners();
  }

  void setOrderAlerts(bool value) {
    orderAlerts = value;
    notifyListeners();
  }

  void setEndOfSaleReminder(bool value) {
    endOfSaleReminder = value;
    notifyListeners();
  }
}

String cardBrand(String digits) {
  if (digits.startsWith('4')) return 'Visa';
  if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) return 'Mastercard';
  if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
  return 'Carte';
}

/// Contrôle de Luhn des numéros de carte.
bool luhnValid(String digits) {
  var sum = 0;
  for (var i = 0; i < digits.length; i++) {
    var n = int.parse(digits[digits.length - 1 - i]);
    if (i.isOdd) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
  }
  return sum % 10 == 0;
}

class AchatBoutiqueScope extends InheritedNotifier<AchatBoutiqueController> {
  const AchatBoutiqueScope({super.key, required AchatBoutiqueController controller, required super.child})
      : super(notifier: controller);

  static AchatBoutiqueController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AchatBoutiqueScope>()!.notifier!;
}
