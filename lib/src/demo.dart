import 'package:flutter/material.dart';

class LocalAddress {
  const LocalAddress(this.label, this.street, this.city);
  final String label;
  final String street;
  final String city;
}

/// Données fictives de la session. Aucun mot de passe ni message n’est conservé.
class DemoAccount extends ChangeNotifier {
  static const demoEmail = 'camille@example.com';
  static const demoPassword = 'LocalDrop2026';
  String name = 'Camille Martin';
  String email = demoEmail;
  String phone = '06 12 34 56 78';
  String shop = '';
  bool merchant = false;
  bool sample = true;
  bool locationAllowed = false;
  bool alertsAllowed = false;
  int avatar = 0;
  static const _sampleAddresses = [
    const LocalAddress('Domicile', '12, Rue du Commerce', '75001 Paris, France'),
    const LocalAddress('Travail', '8, Avenue de l’Opéra', '75001 Paris, France'),
  ];
  final List<LocalAddress> _addresses = [..._sampleAddresses];
  List<LocalAddress> get addresses => List.unmodifiable(_addresses);
  int defaultAddress = 0;

  String get initials => name.trim().split(RegExp(r'\s+')).take(2)
      .where((part) => part.isNotEmpty)
      .map((part) => part.characters.first.toUpperCase()).join();

  void updateProfile(String newName, String newEmail, String newPhone, int newAvatar) {
    name = newName.trim();
    email = newEmail.trim();
    phone = newPhone.trim();
    avatar = newAvatar;
    notifyListeners();
  }

  void register(String newName, String newEmail, String newPhone, String? business) {
    sample = false;
    merchant = business != null;
    shop = business?.trim() ?? '';
    locationAllowed = false;
    alertsAllowed = false;
    _addresses.clear();
    defaultAddress = -1;
    updateProfile(newName, newEmail, newPhone, 0);
  }

  void openSample() {
    if (sample) return;
    sample = true;
    merchant = false;
    shop = '';
    locationAllowed = false;
    alertsAllowed = false;
    _addresses
      ..clear()
      ..addAll(_sampleAddresses);
    defaultAddress = 0;
    updateProfile('Camille Martin', demoEmail, '06 12 34 56 78', 0);
  }

  void saveAddress(LocalAddress address, {int? index, required bool makeDefault}) {
    if (index == null) {
      _addresses.add(address);
    } else {
      _addresses[index] = address;
    }
    if (makeDefault || _addresses.length == 1) defaultAddress = index ?? _addresses.length - 1;
    notifyListeners();
  }
}

class DemoScope extends InheritedNotifier<DemoAccount> {
  const DemoScope({super.key, required DemoAccount account, required super.child})
      : super(notifier: account);

  static DemoAccount of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DemoScope>()!.notifier!;
}
