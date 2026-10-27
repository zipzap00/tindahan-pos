import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/theme/tokens.dart';
import '../../scopes.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

/// Step 2 of owner sign-up. Also shown if step 2 was interrupted earlier.
class CreateStoreScreen extends StatefulWidget {
  const CreateStoreScreen({super.key, required this.user});

  final User user;

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeName = TextEditingController();
  final _ownerName = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _ownerName.text = widget.user.displayName ?? '';
  }

  @override
  void dispose() {
    _storeName.dispose();
    _ownerName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await AppServices.of(context).authRepository.createStore(
          user: widget.user,
          storeName: _storeName.text,
          ownerName: _ownerName.text,
        );
    if (!mounted) return;
    final error = result.errorOrNull;
    setState(() {
      _busy = false;
      _message = error == null ? null : describeError(s, error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final message = _message;
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xl),
            children: [
              PageHeader(eyebrow: s.stepTwoOfTwo, title: s.createStoreTitle, caption: s.createStoreCaption),
              PagePadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: s.storeName,
                      controller: _storeName,
                      hint: s.storeNameHint,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value ?? '').trim().isEmpty ? s.required : null,
                    ),
                    const SizedBox(height: AppSpace.lg),
                    AppTextField(
                      label: s.yourName,
                      controller: _ownerName,
                      helper: s.yourNameHelper,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (value) => (value ?? '').trim().isEmpty ? s.required : null,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpace.lg),
                      InlineNotice(message: message, icon: Icons.error_outline_rounded),
                    ],
                    const SizedBox(height: AppSpace.xl),
                    PillButton(label: s.openStore, onPressed: _submit, loading: _busy, expand: true),
                    const SizedBox(height: AppSpace.sm),
                    PillButton(
                      label: s.signOut,
                      variant: PillVariant.ghost,
                      onPressed: _busy ? null : () => AppServices.of(context).sessionController.signOut(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
