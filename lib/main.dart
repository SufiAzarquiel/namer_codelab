import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00392F5A)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var currentWordPair = WordPair.random();
  void getNextWordPair() {
    currentWordPair = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>{}; // Use set -> no need to use index
  void toggleFavorite() {
    if (favorites.contains(currentWordPair)) {
      favorites.remove(currentWordPair);
    } else {
      favorites.add(currentWordPair);
    }
    notifyListeners();
  }

  var navIndex = 0;
  void updateIndex(value) {
    navIndex = value;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var navIndex = appState.navIndex;

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: navIndex,
              onDestinationSelected: (value) {
                appState.updateIndex(value);
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: GeneratorPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.currentWordPair;
    var getNextWordPair = appState.getNextWordPair;

    var toggleFavorite = appState.toggleFavorite;
    IconData icon;
    ButtonStyle favBtnStyle;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WordPairCard(
              pairParam: pair,
              getNext: getNextWordPair
          ),
          SizedBox(height: 10), // Works as a margin/separator
          ElevatedButton.icon(
            onPressed: toggleFavorite,
            icon: Icon(icon),
            label: Text('Like'),
          ),
        ],
      ),
    );
  }
}

class WordPairCard extends StatelessWidget {

  const WordPairCard({
    super.key,
    required this.pairParam,
    required this.getNext,
  });

  final Function() getNext;
  final WordPair pairParam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // get theme from context

    final styleBtnText = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    final styleBtn = ElevatedButton.styleFrom(
      foregroundColor: theme.colorScheme.onPrimary,
      backgroundColor: theme.colorScheme.primary,
      textStyle: styleBtnText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );

    return ElevatedButton(
      onPressed: getNext,
      style: styleBtn,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pairParam.asLowerCase,
          style: styleBtnText,
          semanticsLabel: "${pairParam.first} ${pairParam.second}",
        ),
      ),
    );
  }
}