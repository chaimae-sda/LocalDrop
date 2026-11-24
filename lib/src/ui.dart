import 'package:flutter/material.dart';

const forest = Color(0xFF1F4D36);
const mint = Color(0xFFEAF4EE);
const orange = Color(0xFFFF6A2B);
const success = Color(0xFF2E9E63);
const ink = Color(0xFF0F1915);
const muted = Color(0xFF5C6D63);
const line = Color(0xFFE1E9E3);
const canvas = Color(0xFFF2F5F1);
const pale = Color(0xFFF7FAF8);

ThemeData dropTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: forest).copyWith(
    primary: forest, secondary: orange, surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    visualDensity: VisualDensity.standard,
    dividerColor: line,
    textTheme: ThemeData.light().textTheme.apply(bodyColor: ink, displayColor: ink),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: forest),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: mint,
      hintStyle: const TextStyle(color: muted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: _border(Colors.transparent),
      enabledBorder: _border(Colors.transparent),
      focusedBorder: _border(success, 1.6),
      errorBorder: _border(const Color(0xFFAA322B)),
      focusedErrorBorder: _border(const Color(0xFFAA322B), 1.6),
      errorMaxLines: 2,
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
      foregroundColor: forest,
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    )),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: forest, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

OutlineInputBorder _border(Color color, [double width = 1]) =>
    OutlineInputBorder(borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color, width: width));

const headingStyle = TextStyle(color: ink, fontSize: 28, height: 1.10,
    fontWeight: FontWeight.w800, letterSpacing: -1.15);
const copyStyle = TextStyle(color: muted, fontSize: 14, height: 1.5);
const strongStyle = TextStyle(color: ink, fontSize: 16, height: 1.2,
    fontWeight: FontWeight.w700, letterSpacing: -.3);

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 48});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: Container(
    width: size, height: size, alignment: Alignment.center,
    decoration: BoxDecoration(color: orange,
      borderRadius: BorderRadius.circular(size * .25),
      boxShadow: const [BoxShadow(color: Color(0x25FF6A2B), blurRadius: 12, offset: Offset(0, 4))]),
    child: CustomPaint(size: Size.square(size * .58), painter: const _Bolt()),
  ));
}

class _Bolt extends CustomPainter {
  const _Bolt();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final path = Path()..moveTo(13, 2)..lineTo(4, 14)..lineTo(11, 14)
      ..lineTo(10, 22)..lineTo(20, 10)..lineTo(13, 10)..close();
    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke
      ..strokeWidth = 1.9..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_Bolt oldDelegate) => false;
}

class PageScroll extends StatelessWidget {
  const PageScroll({super.key, required this.children, this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 26),
    this.spread = false, this.center = false});
  final List<Widget> children;
  final EdgeInsets padding;
  final bool spread;
  final bool center;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, bounds) {
    final minHeight = (bounds.maxHeight - padding.vertical).clamp(0.0, double.infinity).toDouble();
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: padding,
      child: ConstrainedBox(constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: spread ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
          children: children,
        )),
    );
  });
}

class StackColumn extends StatelessWidget {
  const StackColumn(this.children, {super.key, this.gap = 12, this.center = false});
  final List<Widget> children;
  final double gap;
  final bool center;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
    children: [for (var i = 0; i < children.length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      children[i],
    ]],
  );
}

enum ActionStyle { primary, outline, white }

class DropButton extends StatelessWidget {
  const DropButton(this.label, {super.key, required this.onPressed, this.icon,
    this.style = ActionStyle.primary});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final ActionStyle style;
  @override
  Widget build(BuildContext context) {
    final foreground = style == ActionStyle.primary ? Colors.white : forest;
    return SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: style == ActionStyle.primary ? orange : Colors.white,
        foregroundColor: foreground,
        elevation: 0, shadowColor: Colors.transparent,
        minimumSize: const Size(0, 48), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11),
          side: style == ActionStyle.outline ? const BorderSide(color: forest) : BorderSide.none),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
        ]),
    ));
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.color = Colors.white, this.padding = 16});
  final Widget child;
  final Color color;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: line),
      boxShadow: color == Colors.white ? const [BoxShadow(color: Color(0x070F251A),
          offset: Offset(0, 3), blurRadius: 10)] : null),
    child: child,
  );
}

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
    style: const TextStyle(color: Color(0xFFC54C1A), fontSize: 11,
      letterSpacing: 1.55, fontWeight: FontWeight.w800));
}

class Intro extends StatelessWidget {
  const Intro(this.title, this.subtitle, {super.key, this.kicker, this.logo = false});
  final String title, subtitle;
  final String? kicker;
  final bool logo;
  @override
  Widget build(BuildContext context) {
    final align = logo ? TextAlign.center : TextAlign.start;
    return StackColumn(center: logo, gap: 12, [
      if (logo) const Padding(padding: EdgeInsets.only(bottom: 6), child: LogoMark()),
      if (kicker != null) Kicker(kicker!),
      Semantics(header: true, child: Text(title, style: headingStyle, textAlign: align)),
      Text(subtitle, style: copyStyle, textAlign: align),
    ]);
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(50)),
    child: Text(label, style: const TextStyle(color: forest, fontSize: 10, fontWeight: FontWeight.w800)),
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: const TextStyle(
    color: Color(0xFF526259), fontSize: 10, letterSpacing: .8, height: 1.3, fontWeight: FontWeight.w800));
}

class DropField extends StatefulWidget {
  const DropField(this.label, {super.key, required this.controller, this.hint, this.icon,
    this.keyboard, this.secret = false, this.lines = 1, this.validate, this.autofill,
    this.action = TextInputAction.next});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboard;
  final bool secret;
  final int lines;
  final String? Function(String?)? validate;
  final Iterable<String>? autofill;
  final TextInputAction action;
  @override
  State<DropField> createState() => _DropFieldState();
}

class _DropFieldState extends State<DropField> {
  bool visible = false;
  @override
  Widget build(BuildContext context) => StackColumn(gap: 6, [
    FieldLabel(widget.label),
    Semantics(label: widget.label, child: TextFormField(
      controller: widget.controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validate, obscureText: widget.secret && !visible,
      enableSuggestions: !widget.secret, autocorrect: !widget.secret && widget.keyboard != TextInputType.emailAddress,
      autofillHints: widget.autofill,
      textCapitalization: widget.keyboard == TextInputType.name ? TextCapitalization.words : TextCapitalization.none,
      keyboardType: widget.keyboard ?? (widget.lines > 1 ? TextInputType.multiline : TextInputType.text),
      textInputAction: widget.lines > 1 ? TextInputAction.newline : widget.action,
      maxLines: widget.lines, style: const TextStyle(fontSize: 14, color: ink),
      decoration: InputDecoration(hintText: widget.hint, alignLabelWithHint: true,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 19, color: success),
        suffixIcon: !widget.secret ? null : IconButton(
          tooltip: visible ? 'Masquer le mot de passe' : 'Afficher le mot de passe',
          icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19),
          onPressed: () => setState(() => visible = !visible))),
    )),
  ]);
}

String? requiredText(String? value) =>
    (value ?? '').trim().isEmpty ? 'Renseignez ce champ.' : null;
String? validEmail(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((value ?? '').trim()) ? null : 'Saisissez une adresse e-mail valide.';
String? validPassword(String? value) =>
    (value ?? '').length < 8 ? 'Utilisez au moins 8 caractères.' : null;
String? validPhone(String? value) {
  final phone = (value ?? '').replaceAll(RegExp(r'[\s().-]'), '');
  return RegExp(r'^\+?\d{8,15}$').hasMatch(phone) ? null : 'Vérifiez votre numéro de téléphone.';
}

void feedback(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message), width:
      MediaQuery.sizeOf(context).width >= 750 ? 360 : null));
}

class Avatar extends StatelessWidget {
  const Avatar(this.initials, this.index, {super.key, this.size = 58});
  final String initials;
  final int index;
  final double size;
  static const colors = [forest, Color(0xFF8F421D), Color(0xFF235F6A), Color(0xFF5C4A30)];
  @override
  Widget build(BuildContext context) => CircleAvatar(radius: size / 2,
    backgroundColor: colors[index], child: Text(initials,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * .34)));
}
