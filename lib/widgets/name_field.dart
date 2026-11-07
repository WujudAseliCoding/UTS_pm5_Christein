import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';

/// Name input with consistent validation and styling.
class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.rs(18));
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: context.palette.optionBorder),
    );

    return TextFormField(
      key: const Key('name-field'),
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      autofillHints: const <String>[AutofillHints.name],
      maxLength: 30,
      buildCounter: (
        context, {
        required currentLength,
        required isFocused,
        required maxLength,
      }) => null,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp(r'[\n\r\t]')),
        LengthLimitingTextInputFormatter(30),
      ],
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Nama kamu',
        hintText: 'Tulis nama untuk memulai kuis',
        prefixIcon: const Icon(Icons.person_outline_rounded),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        final name = value?.trim() ?? '';
        if (name.isEmpty) return 'Masukkan namamu dulu, ya.';
        if (name.length < 2) return 'Nama minimal 2 karakter.';
        return null;
      },
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    );
  }
}
