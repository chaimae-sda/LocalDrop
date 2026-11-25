import 'package:flutter/material.dart';

class ClientExperienceController extends ChangeNotifier {
  final Set<String> favorites = {'bio'};
  final Set<String> readNotifications = {};
  final Set<String> selectedCategories = {};

  double maxDistance = 5;
  double maxPrice = 25;
  bool availableOnly = false;
  bool notificationsEnabled = true;
  bool proximityAlertsEnabled = true;
  int proximityRadius = 2;

  String search = '';

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
  }) {
    maxDistance = distance;
    maxPrice = price;
    selectedCategories
      ..clear()
      ..addAll(categories);
    availableOnly = available;
    notifyListeners();
  }

  void resetFilters() {
    maxDistance = 5;
    maxPrice = 25;
    selectedCategories.clear();
    availableOnly = false;
    notifyListeners();
  }

  void widenSearchRadius(double distance) {
    maxDistance = distance;
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
