import 'dart:developer' show log;

import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/widgets/input_row.dart';
import 'package:csp10_app/core/widgets/loading_screen.dart';
import 'package:flutter/material.dart';

class AutocompleteUser extends StatelessWidget {
  const AutocompleteUser({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.validator,
    required this.users,
    this.isLoading = false,
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String? Function(String?) validator;
  final List<User> users;
  final bool isLoading;
  final String? errorText;

  static String _displayStringForOption(User option) => option.username;

  Widget _fieldViewBuilder(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return InputFormField(
      hintText: hintText,
      inputController: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      validatorFunction: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: LoadingScreen(),
      );
    }

    if (errorText != null) {
      return Text(errorText!);
    }

    return Autocomplete<User>(
      displayStringForOption: AutocompleteUser._displayStringForOption,
      fieldViewBuilder: _fieldViewBuilder,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<User>.empty();
        }
        return users.where((User option) {
          return option
              .toString()
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (User selection) {
        log('You just selected ${AutocompleteUser._displayStringForOption(selection)}');
      },
      textEditingController: controller,
      focusNode: focusNode,
    );
  }
}
