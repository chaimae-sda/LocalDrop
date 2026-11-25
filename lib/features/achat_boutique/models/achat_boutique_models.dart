import 'package:flutter/material.dart';

/// 6 → « 6,00 € » ; avec [compact], 12 → « 12 € ».
String euros(double value, {bool compact = false}) {
  final whole = value == value.roundToDouble();
  final text = compact && whole ? value.round().toString() : value.toStringAsFixed(2).replaceAll('.', ',');
  return '$text €';
}

/// Lit « 6 », « 6,00 » ou « 6,00 € ». Renvoie `null` si la saisie n’est pas un montant.
double? parseEuros(String? input) {
  final text = (input ?? '').replaceAll('€', '').replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) return null;
  return double.parse(text);
}

String two(int value) => value.toString().padLeft(2, '0');

/// 19:30 → « 19h30 ».
String pickupTime(TimeOfDay time) => '${two(time.hour)}h${two(time.minute)}';

/// 07:00 → « 07:00 ».
String clockTime(TimeOfDay time) => '${two(time.hour)}:${two(time.minute)}';

int minutes(TimeOfDay time) => time.hour * 60 + time.minute;

class BasketOffer {
  const BasketOffer({required this.title, required this.shop, required this.address,
    required this.price, required this.pickupFrom, required this.pickupUntil,
    required this.distance, required this.walkMinutes});
  final String title, shop, address;
  final double price;
  final TimeOfDay pickupFrom, pickupUntil;
  final int distance, walkMinutes;

  /// « 12, Rue du Commerce, 75001 Paris » → « 12, Rue du Commerce ».
  String get street => address.split(',').take(2).join(',').trim();
}

/// Seuls la marque, les 4 derniers chiffres et l’expiration sont gardés.
class PaymentCard {
  const PaymentCard(this.brand, this.last4, this.expiry);
  final String brand, last4, expiry;
}

enum ShopPlan {
  discovery('Plan Découverte', 'Découverte', 0, [
    'Vitrine éphémère quotidienne', 'Jusqu’à 10 ventes par mois', 'Support standard',
  ]),
  premium('Abonnement Premium', 'Premium', 15, [
    'Ventes illimitées', 'Statistiques avancées', 'Notifications prioritaires',
    'Aucune commission sur les ventes',
  ]);

  const ShopPlan(this.title, this.short, this.monthly, this.perks);
  final String title, short;
  final int monthly;
  final List<String> perks;
}

class ShopInfo {
  const ShopInfo({required this.name, required this.category, required this.address, required this.phone});
  final String name, category, address, phone;

  /// « 12, Rue du Commerce, Paris » → « Paris ».
  String get city => address.split(',').last.trim().replaceFirst(RegExp(r'^\d{4,5}\s*'), '');
}

/// Horaires d’une journée ; sans heures, le commerce est fermé.
class DayHours {
  const DayHours(this.day, [this.open, this.close]);
  final String day;
  final TimeOfDay? open, close;
  bool get closed => open == null || close == null;
  String get label => closed ? 'Fermé' : '${clockTime(open!)} – ${clockTime(close!)}';
}

enum PhotoSource { camera, gallery }

class Showcase {
  const Showcase({required this.title, required this.initialValue, required this.price,
    required this.quantity, required this.pickupUntil, this.photo});
  final String title;
  final double initialValue, price;
  final int quantity;
  final TimeOfDay pickupUntil;
  final PhotoSource? photo;

  int get discount => initialValue <= 0 ? 0 : ((1 - price / initialValue) * 100).round();

  Showcase copyWith({String? title, double? initialValue, double? price, int? quantity,
    TimeOfDay? pickupUntil, PhotoSource? photo}) => Showcase(
      title: title ?? this.title, initialValue: initialValue ?? this.initialValue,
      price: price ?? this.price, quantity: quantity ?? this.quantity,
      pickupUntil: pickupUntil ?? this.pickupUntil, photo: photo ?? this.photo);
}

class MerchantOrder {
  const MerchantOrder(this.number, this.customer, this.price, this.pickup);
  final int number;
  final String customer;
  final double price;
  final TimeOfDay pickup;
}
