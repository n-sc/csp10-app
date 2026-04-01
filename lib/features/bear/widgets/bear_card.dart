import 'dart:developer' show log;

import 'package:csp10_app/features/bear/bloc/bear_bloc.dart';
import 'package:csp10_app/features/bear/models/beartype.dart';
import 'package:csp10_app/core/widgets/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum SupportedBearTypes {
  braunbaer,
  disabled,
}

class BearCard extends StatelessWidget {
  const BearCard({required this.beartype});

  final BearType beartype;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GridTile(
      child: Card(
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/${validateBearType().name}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Placeholder(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              beartype.displayName,
                              style: theme.textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () => showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 250,
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            'Information zum ${beartype.displayName}',
                                            style: theme.textTheme.titleLarge,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            beartype.description,
                                            textAlign: TextAlign.justify,
                                          ),
                                          ElevatedButton(
                                            child: const Text('Close'),
                                            onPressed: () => context.pop(),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              constraints: BoxConstraints(maxHeight: 32),
                              padding: const EdgeInsets.all(0),
                            ),
                          ],
                        ),
                        BlocBuilder<BearBloc, BearState>(
                          buildWhen: (previous, current) =>
                              current is BearOverviewState,
                          builder: (context, state) {
                            return switch (state) {
                              BearOverviewLoaded _ => Text(
                                  "Du hast noch ${state.countsByTypeName[beartype.name] ?? "?"} Stück"),
                              BearOverviewError _ => Text(state.error),
                              BearState _ => const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                            };
                          },
                        ),
                        Center(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            onPressed: _getDialogBuilder(context),
                            child: Text('Mach den Bär!'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SupportedBearTypes validateBearType() {
    final btype = SupportedBearTypes.values.firstWhere(
        (e) => e.toString() == 'SupportedBearTypes.${beartype.name}',
        orElse: () => SupportedBearTypes.disabled);
    return btype;
  }

  VoidCallback? _getDialogBuilder(BuildContext context) {
    final btype = validateBearType();
    switch (btype) {
      case SupportedBearTypes.braunbaer:
        return () async {
          var dialogResult = await showAdaptiveDialog<String>(
              context: context,
              builder: (_) => BlocProvider.value(
                    value: context.read<BearBloc>(),
                    child: const BrownBearAttackDialog(),
                  ));
          log('Bear attack dialogResult: $dialogResult');
        };
      case SupportedBearTypes.disabled:
        return null;
    }
  }
}

class BrownBearAttackDialog extends StatefulWidget {
  const BrownBearAttackDialog({super.key});

  @override
  State<BrownBearAttackDialog> createState() => _BrownBearAttackDialogState();
}

class _BrownBearAttackDialogState extends State<BrownBearAttackDialog> {
  String? selectedUser;

  @override
  void initState() {
    super.initState();
    context.read<BearBloc>().add(const BrownBearAttackTargetsRequest());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BearBloc, BearState>(
      listenWhen: (previousState, state) => state is BrownBearAttackState,
      listener: (context, state) {
        if (state is BrownBearAttackSuccess) {
          // return to overview and indicate success
          context.pop('success');
          showFlushbar(context, 'Der Bär ist unterwegs :)');
        } else if (state is BrownBearAttackCooldown) {
          showFlushbar(
            context,
            'The target is still on cooldown!',
            isError: true,
          );
        } else if (state is BrownBearAttackActiveTransaction) {
          showFlushbar(
            context,
            'The target is already part of an active transaction!',
            isError: true,
          );
        } else if (state is BrownBearAttackFailure) {
          showFlushbar(
            context,
            state.error,
            isError: true,
          );
        }
      },
      buildWhen: (previous, current) => current is BrownBearAttackTargetsLoaded,
      builder: (context, state) {
        switch (state) {
          case BrownBearAttackTargetsLoaded _:
            List<DropdownMenuEntry<String>> userMenuEntries = [];
            for (var user in state.targets) {
              userMenuEntries.add(DropdownMenuEntry(
                value: user.username,
                label: user.username,
              ));
            }
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      onPressed: () => context.pop('canceled'),
                      icon: Icon(Icons.close)),
                  actions: [
                    IconButton(
                        onPressed: () async {
                          var user = selectedUser;
                          if (user != null) {
                            context
                                .read<BearBloc>()
                                .add(BrownBearAttack(target: user));
                          }
                        },
                        icon: Icon(Icons.check))
                  ],
                ),
                body: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Choose your target:'),
                        DropdownMenu(
                          dropdownMenuEntries: userMenuEntries,
                          onSelected: (value) {
                            selectedUser = value;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          case BrownBearAttackTargetsError _:
            return Text(state.error);
          default:
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
        }
      },
    );
  }
}
