import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:csp10_app/core/services/service_locator.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _liked = false;
  Icon _heart = const Icon(Icons.favorite_border);
  late Future<String> futureData;

  @override
  void initState() {
    super.initState();
    futureData = _getProtectedData();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      if (_liked) {
        _heart = const Icon(Icons.favorite);
      } else {
        _heart = const Icon(Icons.favorite_border);
      }
    });
  }

  Future<String> _getProtectedData() async {
    var response = await locator.get<API>().getProtected('/users');
    switch (response) {
      case ContentListAPIResponse _:
        return 'SUCCESS';
      default:
        return 'FAIL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleLike,
                icon: _heart,
                label: Text("Like"),
              ),
              SizedBox(width: 10),
            ],
          ),
          FutureBuilder(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            },
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          "CSP10",
          semanticsLabel: "CSP10",
          style: style,
        ),
      ),
    );
  }
}
