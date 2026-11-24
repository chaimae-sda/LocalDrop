import 'package:flutter/material.dart';

import 'demo.dart';
import 'navigation.dart';
import 'screens.dart';
import 'ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final account = DemoScope.of(context);
    return PageScroll(children: [
      SurfaceCard(color: mint, padding: 16, child: Row(children: [
        Avatar(account.initials, account.avatar), const SizedBox(width: 14),
        Expanded(child: StackColumn(gap: 5, [
          Text(account.name, style: strongStyle.copyWith(fontSize: 19)),
          Text(account.sample ? 'Membre LocalDrop depuis 2026' : 'Membre LocalDrop', style: copyStyle),
        ])),
      ])),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _Metric(Icons.shopping_cart_outlined, account.sample ? '12' : '0', 'Paniers sauvés')),
        const SizedBox(width: 10),
        Expanded(child: _Metric(Icons.trending_up_rounded, account.sample ? '89 €' : '0 €', 'Économisés')),
      ]),
      const SizedBox(height: 22),
      const Text('Mon espace', style: strongStyle),
      const SizedBox(height: 6),
      AccountRow(Icons.person_outline, 'Mes informations', 'Modifier mon profil', () => go(context, DropScreen.editProfile)),
      AccountRow(Icons.favorite_border_rounded, 'Mes favoris', account.sample ? '2 commerces favoris' : 'Retrouver mes commerces', () => openTeam(context, TeamScreen.favorites)),
      AccountRow(Icons.location_on_outlined, 'Mes adresses',
        account.addresses.map((a) => a.label).take(2).join(' et '), () => go(context, DropScreen.addresses)),
      AccountRow(Icons.notifications_none_rounded, 'Mes notifications', 'Gérer les alertes', () => openTeam(context, TeamScreen.notifications)),
      AccountRow(Icons.tune_rounded, 'Paramètres', '', () => openTeam(context, TeamScreen.settings)),
      AccountRow(Icons.help_outline_rounded, 'Centre d’aide', 'Questions fréquentes et support', () => go(context, DropScreen.help)),
    ]);
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.value, this.label);
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => SurfaceCard(color: mint, padding: 12, child: StackColumn(gap: 3, [
    Align(alignment: Alignment.centerLeft, child: Icon(icon, size: 18, color: forest)),
    Text(value, style: headingStyle.copyWith(fontSize: 25, color: forest)),
    Text(label, style: copyStyle.copyWith(fontSize: 11)),
  ]));
}

class AccountRow extends StatelessWidget {
  const AccountRow(this.icon, this.title, this.subtitle, this.onTap, {super.key, this.trailing});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final IconData? trailing;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: line))),
    child: ListTile(contentPadding: EdgeInsets.zero, onTap: onTap,
      leading: CircleAvatar(radius: 18, backgroundColor: mint, child: Icon(icon, color: forest, size: 18)),
      title: Text(title, style: strongStyle.copyWith(fontSize: 14)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, style: copyStyle.copyWith(fontSize: 12)),
      trailing: Icon(trailing ?? Icons.chevron_right_rounded, size: 17, color: muted),
    ));
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  var initialized = false;
  var avatar = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = DemoScope.of(context);
    if (initialized) return;
    initialized = true;
    name.text = account.name;
    email.text = account.email;
    phone.text = account.phone;
    avatar = account.avatar;
  }
  @override
  void dispose() {
    name.dispose(); email.dispose(); phone.dispose();
    super.dispose();
  }

  Future<void> chooseAvatar() async {
    final initials = DemoScope.of(context).initials;
    const colors = ['Forêt', 'Terre cuite', 'Bleu pétrole', 'Cacao'];
    final value = await showDialog<int>(context: context, builder: (dialog) => SimpleDialog(
      title: const Text('Choisir mon avatar'), children: [for (var i = 0; i < colors.length; i++)
        SimpleDialogOption(onPressed: () => Navigator.pop(dialog, i), child: Row(children: [
          Avatar(initials, i, size: 36), const SizedBox(width: 12), Text(colors[i]),
          if (i == avatar) ...[const Spacer(), const Icon(Icons.check_rounded, color: forest)],
        ])),
      ]));
    if (value != null && mounted) setState(() => avatar = value);
  }

  @override
  Widget build(BuildContext context) {
    final account = DemoScope.of(context);
    return PageScroll(children: [
      Center(child: Avatar(account.initials, avatar, size: 62)),
      TextButton.icon(onPressed: chooseAvatar, icon: const Icon(Icons.photo_camera_outlined, size: 16),
        label: const Text('Changer l’avatar')),
      const SizedBox(height: 10),
      Form(key: form, child: StackColumn(gap: 15, [
        DropField('Nom complet', controller: name, icon: Icons.person_outline, validate: requiredText, keyboard: TextInputType.name),
        DropField('E-mail', controller: email, icon: Icons.mail_outline_rounded, validate: validEmail, keyboard: TextInputType.emailAddress),
        DropField('Téléphone', controller: phone, icon: Icons.phone_android_rounded, validate: validPhone,
          keyboard: TextInputType.phone, action: TextInputAction.done),
        DropButton('Enregistrer les modifications', icon: Icons.check_rounded, onPressed: () {
          if (!form.currentState!.validate()) return;
          account.updateProfile(name.text, email.text, phone.text, avatar);
          jump(context, DropScreen.profile);
        }),
      ])),
    ]);
  }
}

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});
  Future<void> edit(BuildContext context, DemoAccount account, [int? index]) async {
    final selection = await showDialog<({LocalAddress address, bool isDefault})>(
      context: context, builder: (dialog) => _AddressDialog(
        address: index == null ? null : account.addresses[index],
        isDefault: index == account.defaultAddress));
    if (selection != null && context.mounted) {
      account.saveAddress(selection.address, index: index, makeDefault: selection.isDefault);
    }
  }
  @override
  Widget build(BuildContext context) {
    final account = DemoScope.of(context);
    final addresses = account.addresses;
    return PageScroll(children: [
      const SizedBox(height: 8), const Text('Adresses enregistrées', style: strongStyle),
      const SizedBox(height: 12),
      if (addresses.isEmpty) const Padding(padding: EdgeInsets.only(bottom: 16),
        child: Text('Ajoutez une première adresse à votre profil.', style: copyStyle)),
      for (var i = 0; i < addresses.length; i++) Padding(padding: const EdgeInsets.only(bottom: 10),
        child: SurfaceCard(child: InkWell(onTap: () => edit(context, account, i), borderRadius: BorderRadius.circular(9),
          child: StackColumn(gap: 7, [
            Row(children: [
              Icon(i == account.defaultAddress ? Icons.home_outlined : Icons.location_on_outlined, color: forest, size: 19),
              const SizedBox(width: 6), Expanded(child: Text(addresses[i].label, style: strongStyle)),
              if (i == account.defaultAddress) const Pill('Par défaut'),
            ]),
            Text('${addresses[i].street}\n${addresses[i].city}', style: copyStyle.copyWith(color: ink)),
          ])))),
      DropButton('Ajouter une adresse', icon: Icons.add_rounded, style: ActionStyle.outline,
        onPressed: () => edit(context, account)),
    ]);
  }
}

class _AddressDialog extends StatefulWidget {
  const _AddressDialog({this.address, required this.isDefault});
  final LocalAddress? address;
  final bool isDefault;
  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  final form = GlobalKey<FormState>();
  late final label = TextEditingController(text: widget.address?.label ?? '');
  late final street = TextEditingController(text: widget.address?.street ?? '');
  late final city = TextEditingController(text: widget.address?.city ?? '');
  late bool isDefault = widget.isDefault;
  @override
  void dispose() {
    label.dispose(); street.dispose(); city.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true, insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    title: Text(widget.address == null ? 'Ajouter une adresse' : 'Modifier l’adresse', style: strongStyle.copyWith(fontSize: 22)),
    content: SizedBox(width: 330, child: Form(key: form, child: StackColumn([
      DropField('Libellé', controller: label, hint: 'Ex. Domicile', validate: requiredText),
      DropField('Adresse', controller: street, hint: 'Numéro et rue', validate: requiredText),
      DropField('Ville et code postal', controller: city, hint: 'Ex. 75001 Paris', validate: requiredText, action: TextInputAction.done),
      CheckboxListTile(contentPadding: EdgeInsets.zero, dense: true, value: isDefault,
        title: const Text('Adresse par défaut'), onChanged: widget.isDefault ? null : (v) => setState(() => isDefault = v ?? false)),
    ]))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
      FilledButton(onPressed: () {
        if (form.currentState!.validate()) {
          Navigator.pop(context, (address: LocalAddress(label.text.trim(), street.text.trim(), city.text.trim()), isDefault: isDefault));
        }
      }, child: const Text('Enregistrer')),
    ]);
}
