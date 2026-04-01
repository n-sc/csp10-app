import 'package:csp10_app/core/services/service_locator.dart';
import 'package:csp10_app/core/widgets/autocomplete_user.dart';
import 'package:csp10_app/core/widgets/flushbar.dart';
import 'package:csp10_app/core/widgets/input_row.dart';
import 'package:csp10_app/features/quotes/bloc/quotes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class QuoteAddScreen extends StatefulWidget {
  const QuoteAddScreen({super.key});

  @override
  State<QuoteAddScreen> createState() => _QuoteAddScreenState();
}

class _QuoteAddScreenState extends State<QuoteAddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _authorController = TextEditingController();
  final _authorFocusNode = FocusNode();
  final _contextController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationController = TextEditingController();
  final _quoteController = TextEditingController();

  @override
  void dispose() {
    _authorController.dispose();
    _contextController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  String? _stringValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty.';
    }
    return null;
  }

  void _onSubmit(BuildContext context) async {
    // Providing a default value in case this was called on the
    // first frame, the [fromKey.currentState] will be null.
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // return if not all fields could be validated
      return;
    }

    final Map<String, String> data = <String, String>{
      "author": _authorController.text,
      "context": _contextController.text,
      "city": _cityController.text,
      "location": _locationController.text,
      "quote": _quoteController.text,
    };

    // submit data to backend here
    context.read<QuotesBloc>().add(QuotesQuoteCreate(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator.get<QuotesBloc>(),
      child: Builder(
          // using a builder to make the above context with the bloc available for everything below here
          builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("New quote"),
            elevation: 0,
            leading: CloseButton(
              onPressed: () => context.pop(),
            ),
            actions: [
              UnconstrainedBox(
                child: TextButton(
                  onPressed: () => _onSubmit(context),
                  child: Text(
                    "Done",
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          body: BlocListener<QuotesBloc, QuotesState>(
            listener: (context, state) {
              if (state is QuotesCreationSuccess) {
                context.pop('success');
                showFlushbar(context, 'Quote created!');
              } else if (state is QuotesCreationError) {
                showFlushbar(
                  context,
                  'Error while trying to create the quote!',
                  isError: true,
                );
              }
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 20.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: TextFormField(
                          controller: _quoteController,
                          maxLines: null,
                          minLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Write a quote here',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          validator: _stringValidator,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      AutocompleteUser(
                        controller: _authorController,
                        focusNode: _authorFocusNode,
                        hintText: 'Who said it?',
                        validator: _stringValidator,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InputFormField(
                        hintText: 'Context',
                        inputController: _contextController,
                        validatorFunction: _stringValidator,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      InputFormField(
                        hintText: 'City',
                        inputController: _cityController,
                        validatorFunction: _stringValidator,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      InputFormField(
                        hintText: 'Location',
                        inputController: _locationController,
                        validatorFunction: _stringValidator,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
