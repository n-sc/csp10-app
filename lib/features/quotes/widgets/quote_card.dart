import 'package:csp10_app/features/quotes/bloc/quotes_bloc.dart';
import 'package:csp10_app/features/quotes/models/quote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

@immutable
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    this.color,
    this.isExpanded = false,
    required this.quote,
  });
  final Color? color;
  final bool isExpanded;
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.teal,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          top: 10,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote,
                  size: 50,
                  color: Colors.black,
                ),
                if (isExpanded)
                  Expanded(
                    child: Container(),
                  ),
                if (isExpanded)
                  IconButton(
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<QuotesBloc>(),
                          child: AlertDialog.adaptive(
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => context.pop('canceled'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<QuotesBloc>()
                                      .add(QuotesQuoteDelete(quote.id));
                                  context.pop('success');
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                            content: const Text(
                                'Do you really want to delete this quote?'),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                quote.quote,
                textAlign: TextAlign.start,
                maxLines: isExpanded ? 10 : 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  quote.author,
                )
              ],
            ),
            const SizedBox(height: 20),
            if (isExpanded) Text('Location: ${quote.city}, ${quote.location}'),
            const SizedBox(height: 5),
            if (isExpanded) Text('Context: ${quote.context}'),
          ],
        ),
      ),
    );
  }
}
