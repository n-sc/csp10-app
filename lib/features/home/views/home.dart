import 'package:csp10_app/core/app/bloc/app_bloc.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    try {
      await context.read<UserRepository>().getUsers();
      return 'SUCCESS';
    } catch (_) {
      return 'FAIL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppBloc>().state.themeMode;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

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
              ElevatedButton.icon(
                onPressed:() {
                  if (isDark) {
                    context.read<AppBloc>().add(AppSwitchTheme(mode: ThemeMode.light));
                  } else {
                    context.read<AppBloc>().add(AppSwitchTheme(mode: ThemeMode.dark));
                  }
                },
                icon: isDark ? Icon(Icons.nights_stay) : Icon(Icons.wb_sunny),
                label: isDark ? Text("Dark mode") : Text("Light mode"),
              ),
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
                child: LoadingScreen(),
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
