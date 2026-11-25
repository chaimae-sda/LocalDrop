import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../src/ui.dart';
import '../models/achat_boutique_models.dart';

const peach = Color(0xFFFFF1EA);
const orangeText = Color(0xFFD9541A);
const cream = Color(0xFFFDEBC8);

/// Titre de section (« Votre panier », « Paiement »…).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Row(children: [
      Expanded(child: Semantics(header: true, child: Text(text, style: strongStyle.copyWith(fontSize: 17)))),
      if (trailing != null) trailing!,
    ]),
  );
}

/// Bandeau d’information : vert avec coche, ou orange avec horloge.
class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key, this.warm = false});
  final String text;
  final bool warm;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: warm ? peach : mint, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(warm ? Icons.schedule_rounded : Icons.check_circle_outline_rounded,
        size: 19, color: warm ? orangeText : forest),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13, height: 1.3,
        fontWeight: FontWeight.w700, color: warm ? orangeText : forest))),
    ]),
  );
}

/// Ligne libellé / valeur des récapitulatifs.
class ValueRow extends StatelessWidget {
  const ValueRow(this.label, this.value, {super.key, this.strong = false, this.valueColor,
    this.valueWidget, this.size = 14});
  final String label;
  final String value;
  final bool strong;
  final Color? valueColor;
  final Widget? valueWidget;
  final double size;
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: strong ? size + 3 : size, height: 1.3, color: strong ? ink : const Color(0xFF34443B),
      fontWeight: strong ? FontWeight.w800 : FontWeight.w400);
    // Sans widget de valeur, la largeur est partagée selon la longueur des deux textes.
    final labelText = Text(label, style: style);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
      if (valueWidget == null) Flexible(flex: math.max(label.length, 4), child: labelText)
      else Expanded(child: labelText),
      const SizedBox(width: 12),
      valueWidget ?? Flexible(flex: math.max(value.length, 4), child: Text(value, textAlign: TextAlign.end,
        style: style.copyWith(color: valueColor ?? (strong ? ink : const Color(0xFF34443B)),
          fontWeight: strong || valueColor != null ? FontWeight.w800 : FontWeight.w500))),
    ]));
  }
}

/// Étiquette ronde ; `solid` pour « ACTIVE » ou « PUBLIÉE ».
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.solid = false, this.warm = false});
  final String label;
  final bool solid, warm;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: solid ? success : warm ? peach : mint,
      borderRadius: BorderRadius.circular(50)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
      color: solid ? Colors.white : warm ? orangeText : forest)),
  );
}

/// Bouton plein vert foncé (« Continuer vers ma boutique », « Voir ma commande »).
class ForestButton extends StatelessWidget {
  const ForestButton(this.label, {super.key, required this.onPressed, this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: forest, foregroundColor: Colors.white,
      elevation: 0, shadowColor: Colors.transparent,
      minimumSize: const Size(0, 48), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Flexible(child: Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
    ]),
  ));
}

/// Grand rond de réussite des écrans 25, 44 et 49.
class SuccessBadge extends StatelessWidget {
  const SuccessBadge(this.icon, {super.key, this.size = 148});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: Container(
    width: size, height: size, alignment: Alignment.center,
    decoration: const BoxDecoration(color: mint, shape: BoxShape.circle),
    child: Container(width: size * .74, height: size * .74,
      decoration: const BoxDecoration(color: success, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: size * .3)),
  ));
}

/// Mise en page des écrans de réussite : rond, titre, texte puis contenu.
class SuccessLayout extends StatelessWidget {
  const SuccessLayout({super.key, required this.icon, required this.title, required this.subtitle,
    required this.children});
  final IconData icon;
  final String title, subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => PageScroll(children: [
    const SizedBox(height: 22),
    Center(child: SuccessBadge(icon)),
    const SizedBox(height: 14),
    Semantics(header: true, child: Text(title, textAlign: TextAlign.center,
      style: headingStyle.copyWith(fontSize: 27))),
    const SizedBox(height: 8),
    Text(subtitle, textAlign: TextAlign.center, style: copyStyle),
    const SizedBox(height: 24),
    ...children,
  ]);
}

/// Petit bouton de l’écran 47.
class CompactButton extends StatelessWidget {
  const CompactButton(this.label, {super.key, required this.onPressed, this.outline = false});
  final String label;
  final VoidCallback onPressed;
  final bool outline;
  @override
  Widget build(BuildContext context) => outline
    ? OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(
        foregroundColor: forest, backgroundColor: Colors.white, side: const BorderSide(color: forest),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)))
    : FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(
        backgroundColor: orange, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)));
}

/// Barre de progression arrondie.
class ProgressLine extends StatelessWidget {
  const ProgressLine(this.value, {super.key, this.label});
  final double value;
  final String? label;
  @override
  Widget build(BuildContext context) => Semantics(label: label, value: '${(value * 100).round()} %',
    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
      value: value.clamp(0, 1), minHeight: 6, color: success, backgroundColor: const Color(0xFFD3DED7))));
}

/// Cadre en pointillés des zones photo et du QR code.
class DashedFrame extends StatelessWidget {
  const DashedFrame({super.key, required this.child, this.color = const Color(0xFF7CC29C),
    this.fill = mint, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final Color color, fill;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorder(color, fill),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder(this.color, this.fill);
  final Color color, fill;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16));
    canvas.drawRRect(rect, Paint()..color = fill);
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
    for (final metric in (Path()..addRRect(rect.deflate(1))).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 14) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 8, metric.length)), paint);
      }
    }
  }
  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color || old.fill != fill;
}

/// Rond orange avec un appareil photo.
class CameraBubble extends StatelessWidget {
  const CameraBubble({super.key, this.size = 56});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: Container(
    width: size, height: size,
    decoration: const BoxDecoration(color: orange, shape: BoxShape.circle),
    child: Icon(Icons.photo_camera_outlined, color: Colors.white, size: size * .45)));
}

/// Emplacement de la photo du panier, avec le badge de remise éventuel.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({super.key, this.height = 200, this.discount, this.radius = 18});
  final double height;
  final int? discount;
  final double radius;
  @override
  Widget build(BuildContext context) => Semantics(image: true, label: 'Photo du panier',
    child: Container(height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4DC), cream])),
      child: Stack(children: [
        Center(child: Icon(Icons.image_outlined, size: math.min(56, height * .4), color: const Color(0xFFC9A46A))),
        if (discount != null && discount! > 0) Positioned(left: 16, top: 16, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(40)),
          child: Text('-$discount %', style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.w800, fontSize: 14)))),
      ])));
}

/// Logo de la boutique dans un rond blanc.
class ShopLogo extends StatelessWidget {
  const ShopLogo({super.key, this.size = 62});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: Container(
    width: size, height: size,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Icon(Icons.storefront_outlined, color: forest, size: size * .46)));
}

/// QR code du pass de retrait, dessiné à partir du numéro de commande.
class PickupQr extends StatelessWidget {
  const PickupQr(this.seed, {super.key, this.size = 200});
  final String seed;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(image: true, label: 'QR code du pass de retrait',
    child: SizedBox.square(dimension: size, child: CustomPaint(painter: _QrPainter(seed))));
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this.seed);
  final String seed;
  static const cells = 25;
  static const finders = [(0, 0), (cells - 7, 0), (0, cells - 7)];

  bool _nearFinder(int x, int y) {
    for (final (ox, oy) in finders) {
      if (x >= ox - 1 && x <= ox + 7 && y >= oy - 1 && y <= oy + 7) return true;
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / cells;
    final dark = Paint()..color = ink;
    final light = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, light);
    final random = math.Random(seed.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff));
    for (var y = 0; y < cells; y++) {
      for (var x = 0; x < cells; x++) {
        final on = !_nearFinder(x, y) && (x == 6 || y == 6 ? (x + y).isEven : random.nextBool());
        if (on) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell + .5, cell + .5), dark);
      }
    }
    for (final (ox, oy) in finders) {
      final origin = Offset(ox * cell, oy * cell);
      canvas.drawRect(origin & Size.square(cell * 7), dark);
      canvas.drawRect((origin + Offset(cell, cell)) & Size.square(cell * 5), light);
      canvas.drawRect((origin + Offset(cell * 2, cell * 2)) & Size.square(cell * 3), dark);
    }
  }
  @override
  bool shouldRepaint(_QrPainter old) => old.seed != seed;
}

/// Plan simplifié du quartier (écran 27).
class NeighbourhoodMap extends StatelessWidget {
  const NeighbourhoodMap({super.key, required this.shopLabel, this.height = 250});
  final String shopLabel;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(image: true,
    label: 'Plan du quartier : votre position et $shopLabel',
    child: ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(height: height,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        Widget pin(double x, double y, Color color, String label) => Positioned(
          left: x * w - 70, top: y * h - 62, width: 140,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: ink))),
            Icon(Icons.location_on_rounded, color: color, size: 34),
          ]));
        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _MapPainter())),
          pin(.3, .3, orange, shopLabel),
          pin(.78, .63, forest, 'Boucherie · 450 m'),
          Positioned(left: w * .53 - 15, top: h * .78 - 15, child: Container(width: 30, height: 30,
            decoration: const BoxDecoration(color: Color(0x553B82F6), shape: BoxShape.circle),
            child: Center(child: Container(width: 14, height: 14,
              decoration: BoxDecoration(color: const Color(0xFF3B82F6), shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)))))),
        ]);
      }))));
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final block = Paint()..color = const Color(0xFFD7ECDF);
    final park = Paint()..color = const Color(0xFF9DD1B3);
    const gap = 9.0;
    const cols = [0.0, .37, .69, 1.0];
    const rows = [0.0, .35, .67, 1.0];
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        canvas.drawRect(Rect.fromLTRB(
          cols[c] * size.width + (c == 0 ? 0 : gap), rows[r] * size.height + (r == 0 ? 0 : gap),
          cols[c + 1] * size.width - (c == 2 ? 0 : gap), rows[r + 1] * size.height - (r == 2 ? 0 : gap)), block);
      }
    }
    for (final rect in [Rect.fromLTWH(size.width * .76, size.height * .06, size.width * .2, size.height * .2),
      Rect.fromLTWH(size.width * .44, size.height * .43, size.width * .2, size.height * .18),
      Rect.fromLTWH(size.width * .74, size.height * .78, size.width * .18, size.height * .16)]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), park);
    }
  }
  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}

/// Champ qui ouvre un sélecteur d’heure.
class TimeField extends StatelessWidget {
  const TimeField(this.label, {super.key, required this.value, required this.onChanged});
  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: value,
      helpText: label, builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!));
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) => StackColumn(gap: 6, [
    FieldLabel(label),
    Semantics(button: true, label: label, value: pickupTime(value),
      child: Material(color: mint, borderRadius: BorderRadius.circular(11), child: InkWell(
        borderRadius: BorderRadius.circular(11), onTap: () => _pick(context),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(children: [
            const Icon(Icons.schedule_rounded, size: 19, color: success),
            const SizedBox(width: 12),
            Expanded(child: Text(pickupTime(value), style: const TextStyle(fontSize: 14, color: ink))),
          ]))))),
  ]);
}

/// Sélecteur − quantité + (écran 46).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.max = 99});
  final int value, min, max;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 50, padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(11)),
    child: Row(children: [
      IconButton(tooltip: 'Retirer un panier', onPressed: value > min ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove_rounded, color: forest)),
      Expanded(child: Semantics(label: 'Quantité', value: '$value', liveRegion: true,
        child: Text('$value', textAlign: TextAlign.center, style: strongStyle.copyWith(color: forest)))),
      IconButton.filled(tooltip: 'Ajouter un panier', onPressed: value < max ? () => onChanged(value + 1) : null,
        style: IconButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB9C9BF), minimumSize: const Size(34, 34), padding: EdgeInsets.zero),
        icon: const Icon(Icons.add_rounded, size: 20)),
    ]),
  );
}
