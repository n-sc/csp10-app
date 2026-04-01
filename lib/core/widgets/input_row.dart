import 'package:flutter/material.dart';

class InputFormField extends StatelessWidget {
  const InputFormField({
    super.key,
    required this.hintText,
    required this.inputController,
    this.focusNode,
    this.onFieldSubmitted,
    this.validatorFunction,
  });

  final String hintText;
  final TextEditingController inputController;

  final FocusNode? focusNode;
  final VoidCallback? onFieldSubmitted;
  final String? Function(String?)? validatorFunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: TextFormField(
        controller: inputController,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        focusNode: focusNode,
        onFieldSubmitted: (String value) {
          if (onFieldSubmitted != null) {
            onFieldSubmitted!();
          }
        },
        textInputAction: TextInputAction.next,
        validator: validatorFunction,
      ),
    );
  }
}
