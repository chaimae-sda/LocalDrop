import 'package:flutter/material.dart';
import 'main.dart' show LocalDropApp;
import 'features/gestion_commercant/merchant_screen.dart';

void main() => runApp(LocalDropApp(initialRoute: MerchantScreen.live.route));
