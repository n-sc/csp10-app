import 'dart:developer' show log;

import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/widgets/input_row.dart';
import 'package:csp10_app/features/quotes/bloc/quotes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AutocompleteUser extends StatefulWidget {
  AutocompleteUser({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String? Function(String?) validator;

  static String _displayStringForOption(User option) => option.username;

  @override
  State<AutocompleteUser> createState() => _AutocompleteUserState();
}

class _AutocompleteUserState extends State<AutocompleteUser> {
  @override
  void initState() {
    super.initState();
    context.read<QuotesBloc>().add(const QuotesAuthorsRequest());
  }

  Widget _fieldViewBuilder(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return InputFormField(
      hintText: widget.hintText,
      inputController: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      validatorFunction: widget.validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuotesBloc, QuotesState>(
      builder: (context, state) {
        return switch (state) {
          QuotesAuthorsLoaded _ => Autocomplete<User>(
              displayStringForOption: AutocompleteUser._displayStringForOption,
              fieldViewBuilder: _fieldViewBuilder,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<User>.empty();
                }
                return state.users.where((User option) {
                  return option
                      .toString()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (User selection) {
                log('You just selected ${AutocompleteUser._displayStringForOption(selection)}');
              },
              textEditingController: widget.controller,
              focusNode: widget.focusNode,
            ),
          QuotesAuthorsError _ => Text(state.error),
          QuotesState _ => const Center(
              child: CircularProgressIndicator.adaptive(),
            )
        };
      },
    );
  }
}
