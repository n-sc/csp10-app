import 'dart:developer' show log;
import 'dart:math' as math;

import 'package:csp10_app/core/services/service_locator.dart';
import 'package:csp10_app/core/widgets/flushbar.dart';
import 'package:csp10_app/features/quotes/bloc/quotes_bloc.dart';
import 'package:csp10_app/features/quotes/models/quote.dart';
import 'package:csp10_app/features/quotes/widgets/quote_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return BlocProvider.value(
      value: locator.get<QuotesBloc>(),
      child: Builder(builder: (context) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await context.push<String?>('/quotes/add');
              log('Result from quote_add: $result');
              if (context.mounted) {
                context.read<QuotesBloc>().add(const QuotesOverviewRequest());
              }
            },
            child: const Icon(Icons.add),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  // TODO set default constraints in a central place?
                  maxWidth: math.min(MediaQuery.of(context).size.width, 600)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Zitate",
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                  Expanded(
                    child: QuotesStack(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class QuotesStack extends StatefulWidget {
  const QuotesStack({super.key});

  @override
  State<QuotesStack> createState() => _QuotesStackState();
}

class _QuotesStackState extends State<QuotesStack> {
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<QuotesBloc>().add(const QuotesOverviewRequest());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuotesBloc, QuotesState>(
      listener: (context, state) {
        if (state is QuotesDeletionSuccess) {
          showFlushbar(context, 'Quote deleted!');
          _expandedIndex = -1;
        } else if (state is QuotesDeletionError) {
          showFlushbar(
            context,
            'Error while trying to delete the quote!',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          QuotesLoaded _ => Stack(
              children: [
                RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<QuotesBloc>()
                      .add(const QuotesOverviewRefresh()),
                  child: ListView(
                    padding: EdgeInsets.all(5),
                    children: List<Widget>.generate(
                      state.quotes.length,
                      (index) => InkWell(
                        onTap: () {
                          setState(() {
                            _expandedIndex = index;
                          });
                        },
                        child: QuoteCard(
                          quote: state.quotes[index],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_expandedIndex >= 0 && _expandedIndex < state.quotes.length)
                  _buildExpandedCard(state.quotes[_expandedIndex])
              ],
            ),
          QuotesError _ => Text(state.error),
          QuotesState _ => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
        };
      },
    );
  }

  Widget _buildExpandedCard(Quote quote) {
    return AnimatedPositioned(
      curve: Curves.easeInOut,
      top: 5,
      bottom: 100,
      left: 5,
      right: 5,
      duration: Duration(milliseconds: 400),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedIndex = -1;
          });
        },
        child: QuoteCard(
          isExpanded: true,
          quote: quote,
        ),
      ),
    );
  }
}
