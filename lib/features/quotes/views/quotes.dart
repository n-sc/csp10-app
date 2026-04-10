import 'dart:developer' show log;

import 'package:csp10_app/core/widgets/flushbar.dart';
import 'package:csp10_app/core/widgets/page_constraint.dart';
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<String?>('/quotes/add');
          log('Result from quote_add: $result');
          // The bloc already dispatches QuotesOverviewRefresh after a
          // successful creation. Only re-request when the user cancelled
          // (no quote was created), to ensure the list is up to date.
          if (context.mounted && result != 'success') {
            context.read<QuotesBloc>().add(const QuotesOverviewRequest());
          }
        },
        child: const Icon(Icons.add),
      ),
      body: PageConstraint(
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
                child: const QuotesStack(),
              ),
            ],
          ),
      ),
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
      listenWhen: (previous, current) =>
          previous.deleteStatus != current.deleteStatus &&
          (current.deleteStatus == QuotesActionStatus.success ||
              current.deleteStatus == QuotesActionStatus.failure),
      listener: (context, state) {
        if (state.deleteStatus == QuotesActionStatus.success) {
          showFlushbar(context, 'Quote deleted!');
          _expandedIndex = -1;
        } else if (state.deleteStatus == QuotesActionStatus.failure) {
          showFlushbar(
            context,
            'Error while trying to delete the quote!',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return switch (state.loadStatus) {
          QuotesLoadStatus.success => Stack(
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
          QuotesLoadStatus.failure => Text(state.loadError ?? 'Unknown error'),
          _ => const Center(
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
