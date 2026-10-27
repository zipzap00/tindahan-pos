import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/language.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';

/// Text field with its label above (never a placeholder-only label).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixText,
    this.suffix,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? prefixText;
  final Widget? suffix;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppType.caption.copyWith(color: AppColors.ink)),
        const SizedBox(height: AppSpace.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          obscureText: obscureText,
          autofocus: autofocus,
          enabled: enabled,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          style: AppType.bodyMd,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            helperMaxLines: 3,
            errorMaxLines: 3,
            prefixText: prefixText,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Peso amount field: "₱" prefix, decimal keypad, up to 2 decimal places.
class PesoField extends StatelessWidget {
  const PesoField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint ?? '0.00',
      helper: helper,
      prefixText: '$pesoSign ',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [PesoInputFormatter()],
      validator: validator,
      onChanged: onChanged,
      autofocus: autofocus,
      textInputAction: textInputAction ?? TextInputAction.next,
    );
  }
}

/// Whole pieces.
class QuantityField extends StatelessWidget {
  const QuantityField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint ?? '0',
      helper: helper,
      keyboardType: TextInputType.number,
      inputFormatters: [QuantityInputFormatter()],
      validator: validator,
      onChanged: onChanged,
      autofocus: autofocus,
      textInputAction: TextInputAction.next,
    );
  }
}

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      style: AppType.bodyMd,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.ink),
        suffixIcon: hasText
            ? IconButton(
                tooltip: context.s.clearSearch,
                icon: const Icon(Icons.close_rounded, color: AppColors.ink),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}

/// Horizontally scrolling pill chips; one selected at a time.
class ChoiceChipRow<T> extends StatelessWidget {
  const ChoiceChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpace.screen),
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final option in options) ...[
            ChoicePill(
              label: labelOf(option),
              selected: option == selected,
              onTap: () => onSelected(option),
            ),
            const SizedBox(width: AppSpace.sm),
          ],
        ],
      ),
    );
  }
}

/// One selectable pill; selected pills are ink with a check mark.
class ChoicePill extends StatelessWidget {
  const ChoicePill({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.ink : AppColors.canvasLight,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? AppColors.ink : AppColors.hairlineLight),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.sm + 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check_rounded, size: 16, color: AppColors.onPrimary),
                    const SizedBox(width: AppSpace.xs),
                  ],
                  Text(
                    label,
                    style: AppType.caption.copyWith(color: selected ? AppColors.onPrimary : AppColors.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two or three equal options in one pill track.
class SegmentedPills<T> extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.iconOf,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final IconData Function(T option)? iconOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final icons = iconOf;
    return Container(
      padding: const EdgeInsets.all(AppSpace.xs),
      decoration: BoxDecoration(
        color: AppColors.canvasLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.hairlineLight),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                selected: option == selected,
                button: true,
                child: Material(
                  color: option == selected ? AppColors.ink : Colors.transparent,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => onSelected(option),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.xs),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icons != null) ...[
                                Icon(
                                  icons(option),
                                  size: 18,
                                  color: option == selected ? AppColors.onPrimary : AppColors.ink,
                                ),
                                const SizedBox(width: AppSpace.xs),
                              ],
                              Flexible(
                                child: Text(
                                  labelOf(option),
                                  textAlign: TextAlign.center,
                                  style: AppType.bodyStrong.copyWith(
                                    color: option == selected ? AppColors.onPrimary : AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// − qty + control. The plus button is disabled at the stock limit.
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.canIncrement = true,
    this.canDecrement = true,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool canIncrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.remove_rounded, tooltip: s.decreaseQty, onTap: canDecrement ? onDecrement : null),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppType.tabular(AppType.bodyStrong),
          ),
        ),
        _StepButton(icon: Icons.add_rounded, tooltip: s.increaseQty, onTap: canIncrement ? onIncrement : null),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: AppColors.ink,
        disabledForegroundColor: AppColors.shade40,
        side: BorderSide(color: enabled ? AppColors.ink : AppColors.shade30),
        shape: const CircleBorder(),
      ),
    );
  }
}
