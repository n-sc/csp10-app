import 'dart:math' as math;

import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/features/bear/bear_repository.dart';
import 'package:csp10_app/features/bear/bloc/bear_bloc.dart';
import 'package:csp10_app/features/bear/widgets/bear_card.dart';
import 'package:csp10_app/features/bear/widgets/bear_transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BearPage extends StatefulWidget {
  const BearPage({super.key});

  @override
  State<BearPage> createState() => _BearPageState();
}

class _BearPageState extends State<BearPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBearTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: _currentBearTab,
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_setBearTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setBearTab() {
    setState(() {
      _currentBearTab = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bär @ CSP10',
          style: theme.textTheme.headlineLarge,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.pets)),
            Tab(icon: Icon(Icons.swap_horiz)),
            Tab(icon: Icon(Icons.timelapse)),
          ],
        ),
      ),
      body: BlocProvider(
        create: (context) => BearBloc(
          bearRepository: context.read<BearRepository>(),
          userRepository: context.read<UserRepository>(),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            const BearOverview(),
            const MyBears(),
            const AllBears(),
          ],
        ),
      ),
    );
  }
}

class BearOverview extends StatelessWidget {
  const BearOverview({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BearBloc>().add(const BearOverviewRequest());

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(MediaQuery.of(context).size.width, 600),
        ),
        child: BlocBuilder<BearBloc, BearState>(
          buildWhen: (previous, current) => current is BearOverviewState,
          builder: (context, state) {
            return switch (state) {
              BearOverviewLoaded _ => RefreshIndicator.adaptive(
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: List<Widget>.generate(
                      state.types.length,
                      (index) => BearCard(
                        beartype: state.types[index],
                      ),
                    ),
                  ),
                  onRefresh: () async =>
                      context.read<BearBloc>().add(const BearOverviewRequest()),
                ),
              BearOverviewError _ => Text(state.error),
              BearState _ => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
            };
          },
        ),
      ),
    );
  }
}

class MyBears extends StatelessWidget {
  const MyBears({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BearBloc>().add(const BearTransactionsRequest());

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: math.min(MediaQuery.of(context).size.width, 600)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Deine Bären",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: BlocBuilder<BearBloc, BearState>(
                buildWhen: (previous, current) =>
                    current is BearTransactionsState,
                builder: (context, state) {
                  return switch (state) {
                    BearTransactionsLoaded _ => RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<BearBloc>()
                            .add(const BearTransactionsRefresh()),
                        child: state.ownTransactions.isNotEmpty
                            ? ListView(
                                padding: EdgeInsets.all(8),
                                children: List<Widget>.generate(
                                  state.ownTransactions.length,
                                  (index) => BearTransactionCard(
                                    bearTransaction:
                                        state.ownTransactions[index],
                                    isConfirmable: true,
                                  ),
                                ),
                              )
                            : Center(child: Text('No transactions here.')),
                      ),
                    BearTransactionsError _ => Text(state.error),
                    BearState _ => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllBears extends StatelessWidget {
  const AllBears({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    context.read<BearBloc>().add(const BearTransactionsRequest());

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: math.min(MediaQuery.of(context).size.width, 600)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Alle Bären",
                style: theme.textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: BlocBuilder<BearBloc, BearState>(
                buildWhen: (previous, current) =>
                    current is BearTransactionsState,
                builder: (context, state) {
                  return switch (state) {
                    BearTransactionsLoaded _ => RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<BearBloc>()
                            .add(const BearTransactionsRefresh()),
                        child: ListView(
                          padding: EdgeInsets.all(8),
                          children: List<Widget>.generate(
                            state.transactions.length,
                            (index) => BearTransactionCard(
                              bearTransaction: state.transactions[index],
                            ),
                          ),
                        ),
                      ),
                    BearTransactionsError _ => Text(state.error),
                    BearState _ => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
