import 'dart:async';

import 'package:flutter/material.dart';

import '../achat_boutique/models/achat_boutique_models.dart';

class PickupTicket {
  const PickupTicket(this.order, this.product, this.code);
  final MerchantOrder order;
  final String product, code;
  String get payload => 'LD-${order.number}-$code';
}

class PastShowcase {
  const PastShowcase(this.title, this.sold, this.quantity);
  final String title;
  final int sold, quantity;
}

class SalesDay {
  const SalesDay(
    this.cents,
    this.sold,
    this.collected,
    this.capacity,
    this.shops,
  );
  final int cents, sold, collected, capacity, shops;
}

/// État partagé avec l’achat et la publication d’Aya pendant la démonstration.
mixin MerchantOperations on ChangeNotifier {
  Showcase get live;
  set live(Showcase value);
  int get sold;
  List<PickupTicket> get tickets;

  late final Set<int> _liveNumbers = tickets
      .map((ticket) => ticket.order.number)
      .toSet();
  final _collected = <int>{};
  final pastShowcases = <PastShowcase>[];
  final invitations = <String>[];
  final supportMessages = <String>[];
  final _openedAt = DateTime.now();
  bool _closed = false;
  bool _clockStarted = false;
  Timer? _deadline;

  // Le même créneau est présentable le matin comme le soir.
  DateTime get shopTime =>
      DateTime(2026, 11, 26, 18, 17).add(DateTime.now().difference(_openedAt));
  DateTime get closingTime =>
      DateTime(2026, 11, 26, live.pickupUntil.hour, live.pickupUntil.minute);
  bool get closed => _closed || !shopTime.isBefore(closingTime);
  int get remaining => live.quantity - sold;
  int get forSale => closed ? 0 : remaining;
  bool isCollected(PickupTicket ticket) =>
      _collected.contains(ticket.order.number);
  List<PickupTicket> get pending =>
      tickets.where((t) => !isCollected(t)).toList();
  List<PickupTicket> get livePending =>
      pending.where((t) => _liveNumbers.contains(t.order.number)).toList();
  int get dayCents =>
      tickets.fold(0, (sum, t) => sum + (t.order.price * 100).round());
  int get liveCents => tickets
      .where((t) => _liveNumbers.contains(t.order.number))
      .fold(0, (acc, t) => acc + (t.order.price * 100).round());

  PickupTicket? byNumber(int? number) =>
      tickets.where((t) => t.order.number == number).firstOrNull;
  PickupTicket? byCode(String code) =>
      tickets.where((t) => t.code == code).firstOrNull;
  PickupTicket? byQr(String payload) =>
      tickets.where((t) => t.payload == payload).firstOrNull;

  /// Le paiement a déjà réservé le panier. La remise modifie uniquement son statut.
  bool collect(PickupTicket ticket) {
    if (!tickets.contains(ticket) || !_collected.add(ticket.order.number))
      return false;
    notifyListeners();
    return true;
  }

  void startClock() {
    if (_clockStarted) return;
    _clockStarted = true;
    _scheduleClosure();
  }

  void _scheduleClosure() {
    _deadline?.cancel();
    if (_clockStarted && !_closed) {
      _deadline = Timer(closingTime.difference(shopTime), endShowcase);
    }
  }

  void endShowcase() {
    if (_closed) return;
    _closed = true;
    _deadline?.cancel();
    notifyListeners();
  }

  bool updateLive(Showcase next) {
    if (closed ||
        next.quantity < sold ||
        next.quantity < 1 ||
        next.quantity > 99 ||
        next.title.trim().isEmpty ||
        !next.price.isFinite ||
        next.price <= 0 ||
        next.price > next.initialValue)
      return false;
    live = next;
    _scheduleClosure();
    notifyListeners();
    return true;
  }

  /// Appelé avant le remplacement de la vitrine. Les passes déjà payés restent valides.
  void archiveLive() {
    _liveNumbers.clear();
    pastShowcases.insert(0, PastShowcase(live.title, sold, live.quantity));
    _closed = false;
  }

  void schedulePublishedShowcase() => _scheduleClosure();

  String? invite(String input) {
    final email = input.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Saisissez une adresse e-mail valide.';
    }
    if (invitations.contains(email))
      return 'Une invitation existe déjà pour cette adresse.';
    invitations.add(email);
    notifyListeners();
    return null;
  }

  void recordSupportMessage(String input) {
    final message = input.trim();
    if (message.isEmpty) return;
    supportMessages.add(message);
    notifyListeners();
  }

  List<SalesDay> salesDays(int count) {
    // Six journées fictives d’historique. La dernière colonne utilise la session.
    const history = [
      SalesDay(1350, 3, 3, 4, 1),
      SalesDay(1900, 4, 4, 5, 1),
      SalesDay(1650, 3, 3, 4, 1),
      SalesDay(2250, 4, 4, 5, 2),
      SalesDay(1950, 4, 4, 4, 1),
      SalesDay(2500, 4, 4, 5, 1),
    ];
    return [
      for (var daysAgo = count - 1; daysAgo > 0; daysAgo--)
        history[(history.length - daysAgo % history.length) % history.length],
      SalesDay(
        dayCents,
        tickets.length,
        _collected.length,
        live.quantity + pastShowcases.fold(0, (sum, s) => sum + s.quantity),
        1 + pastShowcases.length,
      ),
    ];
  }

  @override
  void dispose() {
    _deadline?.cancel();
    super.dispose();
  }
}
