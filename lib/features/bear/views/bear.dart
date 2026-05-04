import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/widgets/loading_screen.dart';
import 'package:csp10_app/features/bear/bear_repository.dart';
import 'package:csp10_app/features/bear/bloc/bear_bloc.dart';
import 'package:csp10_app/core/widgets/page_constraint.dart';
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

class BearOverview extends StatefulWidget {
  const BearOverview({super.key});

  @override
  State<BearOverview> createState() => _BearOverviewState();
}

class _BearOverviewState extends State<BearOverview> {
  @override
  void initState() {
    super.initState();
    context.read<BearBloc>().add(const BearOverviewRequest());
  }

  @override
  Widget build(BuildContext context) {
    return PageConstraint(
      child: BlocBuilder<BearBloc, BearState>(
          buildWhen: (previous, current) =>
              previous.overviewStatus != current.overviewStatus ||
              previous.types != current.types ||
              previous.countsByTypeName != current.countsByTypeName,
          builder: (context, state) {
            return switch (state.overviewStatus) {
              BearOverviewStatus.success => RefreshIndicator.adaptive(
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
              BearOverviewStatus.failure =>
                Text(state.overviewError ?? 'Could not load bear overview.'),
              _ => const Center(
                  child: LoadingScreen(),
                ),
            };
          },
        ),
    );
  }
}

class MyBears extends StatefulWidget {
  const MyBears({super.key});

  @override
  State<MyBears> createState() => _MyBearsState();
}

class _MyBearsState extends State<MyBears> {
  @override
  void initState() {
    super.initState();
    context.read<BearBloc>().add(const BearTransactionsRequest());
  }

  @override
  Widget build(BuildContext context) {
    return PageConstraint(
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
                    previous.transactionsStatus != current.transactionsStatus ||
                    previous.ownTransactions != current.ownTransactions,
                builder: (context, state) {
                  return switch (state.transactionsStatus) {
                    BearTransactionsStatus.success => RefreshIndicator.adaptive(
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
                    BearTransactionsStatus.failure =>
                      Text(state.transactionsError ?? 'Could not load transactions.'),
                    _ => const Center(
                        child: LoadingScreen(),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
    );
  }
}

class AllBears extends StatefulWidget {
  const AllBears({super.key});

  @override
  State<AllBears> createState() => _AllBearsState();
}

class _AllBearsState extends State<AllBears> {
  @override
  void initState() {
    super.initState();
    context.read<BearBloc>().add(const BearTransactionsRequest());
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return PageConstraint(
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
                    previous.transactionsStatus != current.transactionsStatus ||
                    previous.transactions != current.transactions,
                builder: (context, state) {
                  return switch (state.transactionsStatus) {
                    BearTransactionsStatus.success => RefreshIndicator.adaptive(
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
                    BearTransactionsStatus.failure =>
                      Text(state.transactionsError ?? 'Could not load transactions.'),
                    _ => const Center(
                        child: LoadingScreen(),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
    );
  }
}
