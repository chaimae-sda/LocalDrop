import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'demo.dart';
import 'navigation.dart';
import 'screens.dart';
import 'ui.dart';

class AuthPage extends StatefulWidget {
  const AuthPage(this.screen, {super.key});
  final DropScreen screen;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final business = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  bool accepted = false;
  bool showTermsError = false;
  String? loginError;

  bool get login => widget.screen == DropScreen.login;
  bool get merchant => widget.screen == DropScreen.signupMerchant;

  @override
  void dispose() {
    for (final c in [name, business, email, phone, password]) { c.dispose(); }
    super.dispose();
  }

  void submit() {
    final valid = form.currentState!.validate();
    setState(() => showTermsError = !login && !accepted);
    if (!valid || (!login && !accepted)) return;
    final account = DemoScope.of(context);
    if (login) {
      if (email.text.trim().toLowerCase() != DemoAccount.demoEmail || password.text != DemoAccount.demoPassword) {
        setState(() => loginError = 'Utilisez le compte de démonstration proposé ci-dessous.');
        return;
      }
      account.openSample();
      final route = context.getInheritedWidgetOfExactType<TeamRoutes>()?.onOpen;
      if (route != null) {
        route(context, TeamScreen.clientHome);
      } else {
        jump(context, DropScreen.profile);
      }
    } else {
      account.register(name.text, email.text, phone.text, merchant ? business.text : null);
      go(context, DropScreen.verify, replace: true);
    }
  }

  @override
  Widget build(BuildContext context) => PageScroll(children: [
    Padding(padding: EdgeInsets.only(top: login ? 23 : 2, bottom: login ? 36 : 24),
      child: Intro(login ? 'Heureux de vous retrouver !' : 'Créer mon compte ${merchant ? 'commerçant' : 'client'}',
        login ? 'Connectez-vous à votre compte LocalDrop.' : merchant ? 'Lancez votre vitrine en quelques minutes.'
        : 'Commencez à sauver de bons paniers.', logo: true)),
    Form(key: form, child: AutofillGroup(onDisposeAction: AutofillContextAction.cancel, child: StackColumn(gap: 14, [
      if (!login) DropField(merchant ? 'Nom et prénom' : 'Nom complet', controller: name,
        hint: 'Votre nom', icon: Icons.person_outline, validate: requiredText, keyboard: TextInputType.name,
        autofill: const [AutofillHints.name]),
      if (merchant) DropField('Nom de commerce', controller: business,
        hint: 'Ex. Boulangerie de la Place', icon: Icons.storefront_outlined, validate: requiredText),
      DropField('Adresse e-mail', controller: email, hint: 'votre@email.com', icon: Icons.mail_outline_rounded,
        validate: validEmail, keyboard: TextInputType.emailAddress, autofill: const [AutofillHints.email]),
      if (!login) DropField('Téléphone', controller: phone, hint: '06 00 00 00 00', icon: Icons.phone_android_rounded,
        validate: validPhone, keyboard: TextInputType.phone, autofill: const [AutofillHints.telephoneNumber]),
      DropField('Mot de passe', controller: password, hint: login ? '••••••••' : '8 caractères minimum',
        icon: Icons.lock_outline_rounded, validate: validPassword, secret: true, action: TextInputAction.done,
        autofill: [login ? AutofillHints.password : AutofillHints.newPassword]),
      if (login)
        Align(alignment: Alignment.centerRight, child: TextButton(
          onPressed: () => go(context, DropScreen.reset), child: const Text('Mot de passe oublié ?')))
      else ...[
        CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
          activeColor: success, value: accepted, dense: true, title: const Text('J’accepte les conditions d’utilisation.',
            style: TextStyle(fontSize: 13, color: muted)),
          onChanged: (value) => setState(() {accepted = value ?? false; showTermsError = !accepted;})),
        if (showTermsError) Text('Cochez la case pour continuer.', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ],
      if (login && loginError != null) Text(loginError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      DropButton(login ? 'Se connecter' : 'Créer mon compte', icon: Icons.chevron_right_rounded, onPressed: submit),
    ]))),
    if (login) ...[
      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: Text('ou', style: copyStyle))),
      DropButton('Créer un compte', style: ActionStyle.outline, onPressed: () => go(context, DropScreen.roles)),
      TextButton(onPressed: () {
        email.text = DemoAccount.demoEmail;
        password.text = DemoAccount.demoPassword;
        setState(() => loginError = null);
      }, child: const Text('Remplir avec le compte de démonstration')),
    ] else Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
      const Text('Déjà un compte ?', style: copyStyle),
      TextButton(onPressed: () => go(context, DropScreen.login), child: const Text('Se connecter')),
    ]),
  ]);
}

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});
  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  static const demoCode = '8419';
  final code = TextEditingController();
  final focus = FocusNode();
  Timer? timer;
  late DateTime expires;
  int seconds = 300;
  String? error;

  @override
  void initState() {
    super.initState();
    startTimer();
    focus.addListener(refresh);
  }

  void refresh() => setState(() {});
  void startTimer() {
    timer?.cancel();
    expires = DateTime.now().add(const Duration(minutes: 5));
    seconds = 300;
    timer = Timer.periodic(const Duration(seconds: 1), (tick) {
      final left = expires.difference(DateTime.now()).inMilliseconds;
      setState(() => seconds = (left / 1000).ceil().clamp(0, 300).toInt());
      if (seconds == 0) tick.cancel();
    });
  }

  void verify() {
    if (!DateTime.now().isBefore(expires) || code.text != demoCode) {
      setState(() => error = !DateTime.now().isBefore(expires)
          ? 'Le code a expiré. Touchez « Renvoyer ».'
          : 'Saisissez le code de démonstration 8419.');
      return;
    }
    go(context, DropScreen.location, replace: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    focus.removeListener(refresh);
    focus.dispose();
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final address = DemoScope.of(context).email;
    final time = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return PageScroll(children: [
      const SizedBox(height: 20),
      Intro('Confirmez votre adresse e-mail', 'Pour vérifier $address, utilisez le code de démonstration 8419.', kicker: 'Sécurité'),
      const SizedBox(height: 30),
      SurfaceCard(child: StackColumn(gap: 12, [
        const Icon(Icons.mail_outline_rounded, color: success, size: 30),
        Center(child: SizedBox(width: 234, height: 55, child: Stack(fit: StackFit.expand, children: [
          ExcludeSemantics(child: Row(children: [for (var i = 0; i < 4; i++) Expanded(child: Container(
            alignment: Alignment.center, margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(9),
              border: Border.all(color: focus.hasFocus && (code.text.length.clamp(0, 3) == i) ? forest : const Color(0xFF9ABDA6))),
            child: Text(i < code.text.length ? code.text[i] : '·',
              style: headingStyle.copyWith(fontSize: 24, color: forest)),
          ))])),
          Semantics(label: 'Code de vérification à quatre chiffres', child: TextField(
            key: const ValueKey('otp'), controller: code, focusNode: focus,
            keyboardType: TextInputType.number, textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.oneTimeCode], showCursor: false,
            enableInteractiveSelection: true, style: const TextStyle(color: Colors.transparent),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
            decoration: const InputDecoration(filled: false, border: InputBorder.none,
              enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
            onChanged: (_) => setState(() => error = null), onSubmitted: (_) => verify())),
        ]))),
        Text('Le code expire dans $time', style: copyStyle, textAlign: TextAlign.center),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
        DropButton('Valider mon code', icon: Icons.check_rounded, onPressed: verify),
      ])),
      Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
        const Text('Code non reçu ?', style: copyStyle),
        TextButton(onPressed: () {
          code.clear();
          setState(() { error = null; startTimer(); });
          focus.requestFocus();
          feedback(context, 'Code de démonstration renouvelé : 8419.');
        }, child: const Text('Renvoyer')),
      ]),
    ]);
  }
}

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});
  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  bool complete = false;

  @override
  void dispose() { email.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => PageScroll(children: [
    const SizedBox(height: 20),
    const Intro('Réinitialiser le mot de passe', 'Entrez votre e-mail pour simuler une demande de réinitialisation.', kicker: 'Compte'),
    const SizedBox(height: 30),
    SurfaceCard(child: complete
      ? StackColumn([
          const Icon(Icons.mark_email_read_outlined, size: 36, color: success),
          const Text('Demande simulée', style: strongStyle, textAlign: TextAlign.center),
          Text('Adresse utilisée dans cette démonstration : ${email.text.trim()}.', style: copyStyle, textAlign: TextAlign.center),
        ])
      : Form(key: form, child: StackColumn([
          DropField('Adresse e-mail', controller: email, hint: 'votre@email.com', icon: Icons.mail_outline_rounded,
            keyboard: TextInputType.emailAddress, validate: validEmail, action: TextInputAction.done),
          DropButton('Envoyer le lien', icon: Icons.mail_outline_rounded, onPressed: () {
            if (form.currentState!.validate()) {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => complete = true);
            }
          }),
        ]))),
    TextButton(onPressed: () => jump(context, DropScreen.login), child: const Text('Retour à la connexion')),
  ]);
}
