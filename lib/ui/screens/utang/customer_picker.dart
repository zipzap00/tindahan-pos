import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/customer.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

/// Pick an utang customer, or add a new one on the spot.
Future<Customer?> showCustomerPicker(BuildContext context) {
  return showAppSheet<Customer>(context, builder: (_) => const _CustomerPicker());
}

class _CustomerPicker extends StatefulWidget {
  const _CustomerPicker();

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addNew() async {
    final created = await showCustomerForm(context, initialName: _query.trim());
    if (created != null && mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    return ListenableBuilder(
      listenable: session.customers,
      builder: (context, _) {
        final query = _query.trim().toLowerCase();
        final customers = (session.customers.value ?? const <Customer>[])
            .where((c) => !c.archived && (query.isEmpty || c.name.toLowerCase().contains(query) || c.phone.contains(query)))
            .toList();
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.md),
                child: Text(s.chooseCustomer, style: AppType.headingLg),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                child: SearchField(
                  controller: _search,
                  hint: s.searchCustomerHint,
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                child: PillButton(
                  label: s.addCustomer,
                  icon: Icons.person_add_alt_1_outlined,
                  variant: PillVariant.outline,
                  onPressed: _addNew,
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Flexible(
                child: customers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpace.xl),
                        child: Text(s.noCustomersFound, style: AppType.caption, textAlign: TextAlign.center),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.xl),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return ListRow(
                            leading: InitialsAvatar(name: customer.name),
                            title: customer.name,
                            subtitle: customer.phone,
                            trailing: Text(
                              formatPeso(customer.balance),
                              style: AppType.tabular(AppType.bodyStrong),
                            ),
                            onTap: () => Navigator.of(context).pop(customer),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Add or edit a customer. Returns the new customer when adding.
Future<Customer?> showCustomerForm(BuildContext context, {Customer? existing, String initialName = ''}) {
  return showAppSheet<Customer>(
    context,
    builder: (_) => _CustomerForm(existing: existing, initialName: initialName),
  );
}

class _CustomerForm extends StatefulWidget {
  const _CustomerForm({this.existing, this.initialName = ''});

  final Customer? existing;
  final String initialName;

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? widget.initialName);
  late final TextEditingController _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final TextEditingController _note = TextEditingController(text: widget.existing?.note ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final repo = StoreScope.of(context).customerRepo;
    setState(() => _busy = true);
    final existing = widget.existing;
    if (existing == null) {
      final result = await repo.create(name: _name.text, phone: _phone.text, note: _note.text);
      if (!mounted) return;
      setState(() => _busy = false);
      result.when<void>(
        ok: (customer) => Navigator.of(context).pop(customer),
        err: (error) => showMessage(context, describeError(s, error)),
      );
    } else {
      final result = await repo.updateDetails(existing, name: _name.text, phone: _phone.text, note: _note.text);
      if (!mounted) return;
      setState(() => _busy = false);
      result.when<void>(
        ok: (_) => Navigator.of(context).pop(),
        err: (error) => showMessage(context, describeError(s, error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.existing == null ? s.addCustomer : s.editCustomer, style: AppType.headingLg),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.customerName,
              controller: _name,
              autofocus: widget.existing == null,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) => (value ?? '').trim().isEmpty ? s.required : null,
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.phoneOptional,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.noteOptional,
              controller: _note,
              hint: s.customerNoteHint,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpace.xl),
            PillButton(label: s.save, onPressed: _save, loading: _busy, expand: true),
          ],
        ),
      ),
    );
  }
}
