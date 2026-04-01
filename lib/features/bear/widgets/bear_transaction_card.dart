import 'dart:async' show Timer, Completer;

import 'package:csp10_app/core/widgets/flushbar.dart';
import 'package:csp10_app/features/bear/bloc/bear_bloc.dart';
import 'package:csp10_app/features/bear/models/beartransaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BearTransactionCard extends StatefulWidget {
  const BearTransactionCard({
    super.key,
    required this.bearTransaction,
    this.isConfirmable = false,
  });

  final BearTransaction bearTransaction;
  final bool isConfirmable;

  @override
  State<BearTransactionCard> createState() => _BearTransactionCardState();
}

class _BearTransactionCardState extends State<BearTransactionCard> {
  late int _timeRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timeRemaining = widget.bearTransaction.remaining;
    final timerEnd = DateTime.now().add(Duration(seconds: _timeRemaining));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = now.difference(timerEnd).inSeconds;
      setState(() {
        if (diff > 0) {
          _timer.cancel();
        } else {
          _timeRemaining = diff * -1;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _confirmTransaction(BuildContext context, int id) async {
    final transactionCompleter = Completer<bool>();
    context.read<BearBloc>().add(BearTransactionConfirmation(
          completer: transactionCompleter,
          transactionId: id,
        ));
    final success = await transactionCompleter.future;
    if (context.mounted) {
      if (success) {
        showFlushbar(context, 'Transaction confirmed');
      } else {
        showFlushbar(context, 'Error while confirming transaction',
            isError: true);
      }
    }
  }

  List<Widget> get _transactionRunning => [
        Text(
          "$_timeRemaining",
        ),
        SizedBox(
          width: 5,
        ),
        Icon(
          Icons.schedule,
        ),
      ];

  List<Widget> get _transactionTimeout => <Widget>[
        Text(
          "${widget.bearTransaction.duration ?? 'N/A'}",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Icon(
          Icons.alarm_off,
          color: Colors.red,
        ),
      ];

  List<Widget> get _transactionFinished => <Widget>[
        Text(
          "${widget.bearTransaction.duration}",
          style: TextStyle(
            color: Colors.green,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Icon(
          Icons.alarm_on,
          color: Colors.green,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final int transactionDuration = widget.bearTransaction.duration ?? -1;
    final bool isTimedOut =
        transactionDuration == -1 || transactionDuration > 300;

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_timeRemaining != 0)
            ..._transactionRunning
          else if (isTimedOut)
            ..._transactionTimeout
          else
            ..._transactionFinished
        ],
      ),
      title: Text(
        "${widget.bearTransaction.sender} hat ${widget.bearTransaction.receiver} gebärt",
        overflow: TextOverflow.clip,
        textAlign: TextAlign.end,
      ),
      subtitle: Text(
        "Genutzter Bär: ${widget.bearTransaction.bear}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
        textAlign: TextAlign.end,
      ),
      trailing: widget.isConfirmable
          ? OutlinedButton(
              onPressed: () async {
                await _confirmTransaction(context, widget.bearTransaction.id);
              },
              style: ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(10))),
              child: const Text('Confirm'),
            )
          : null,
    );
  }
}
