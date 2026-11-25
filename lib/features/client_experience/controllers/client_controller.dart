import 'package:flutter/material.dart';

class ClientExperienceController extends ChangeNotifier {
  final Set<String> favorites = {'bio'};
  final Set<String> readNotifications = {};
  final Set<String> reviewedOrders = {};
  final Set<String> selectedCategories = {};

  double maxDistance = 2;
  double maxPrice = 25;
  bool availableOnly = false;
  bool pickupTodayOnly = false;
  bool allPrices = true;
  bool notificationsEnabled = true;
  bool proximityAlertsEnabled = true;
  int proximityRadius = 2;

  String search = '';
  String selectedOfferId = 'boulangerie';
  String selectedShopId = 'boulangerie-du-pont';
  String selectedOrderId = 'LD-1991';

  bool isFavorite(String id) => favorites.contains(id);

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
  }

  void markNotificationRead(String id) {
    readNotifications.add(id);
    notifyListeners();
  }

  void setFilters({
    required double distance,
    required double price,
    required Set<String> categories,
    required bool available,
    bool pickupToday = false,
    bool allPrices = false,
  }) {
    maxDistance = distance;
    maxPrice = price;
    this.allPrices = allPrices;
    pickupTodayOnly = pickupToday;
    selectedCategories
      ..clear()
      ..addAll(categories);
    availableOnly = available;
    notifyListeners();
  }

  void resetFilters() {
    maxDistance = 2;
    maxPrice = 25;
    allPrices = true;
    pickupTodayOnly = false;
    selectedCategories.clear();
    availableOnly = false;
    notifyListeners();
  }

  void widenSearchRadius(double distance) {
    maxDistance = distance;
    notifyListeners();
  }

  void selectOffer(String id) {
    selectedOfferId = id;
  }

  void selectShop(String id) {
    selectedShopId = id;
  }

  void selectOrder(String id) {
    selectedOrderId = id;
  }

  bool isOrderReviewed(String id) => reviewedOrders.contains(id);

  void submitReview(String orderId) {
    reviewedOrders.add(orderId);
    notifyListeners();
  }

  void updateAlerts({
    required bool notifications,
    required bool proximity,
    required int radius,
  }) {
    notificationsEnabled = notifications;
    proximityAlertsEnabled = proximity;
    proximityRadius = radius;
    notifyListeners();
  }
}

class ClientExperienceScope
    extends InheritedNotifier<ClientExperienceController> {
  const ClientExperienceScope({
    super.key,
    required ClientExperienceController controller,
    required super.child,
  }) : super(notifier: controller);

  static ClientExperienceController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ClientExperienceScope>()!
      .notifier!;
}
