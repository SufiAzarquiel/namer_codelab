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

  // initialize word pair
  var currentWordPair = WordPair.random();

  // generate new random word pair
  void getNextWordPair() {
    currentWordPair = WordPair.random();
    notifyListeners();
  }

  // add or remove word pair from favorites list
  var favorites = <WordPair>{}; // Use set -> no need to use index
  void toggleFavorite() {
    if (favorites.contains(currentWordPair)) {
      favorites.remove(currentWordPair);
    } else {
      favorites.add(currentWordPair);
    }
    notifyListeners();
  }
  void removeFromFav(WordPair wordPair) {
    if (favorites.contains(wordPair)) {
      favorites.remove(wordPair);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // position within the nav rail -> State
  var navIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (navIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $navIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 800,
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
                  onDestinationSelected: (destinationValue) {
                    setState(() {
                      navIndex = destinationValue;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: SafeArea(
                      child: page
                  ),
                ),
              ),
            ],
          ),
        );
      }
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

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var removeFromFav = appState.removeFromFav;
    var favList = appState.favorites;

    final theme = Theme.of(context); // get theme from context

    final styleTextHeader = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onTertiaryContainer,
    );

    final styleTextListTile = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.tertiaryContainer,
    );

    return Center(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
                'You have ${appState.favorites.length} favorites:',
                style: styleTextHeader,
            ),
          ),
          ...favList.map((wordPair) =>
              Container(
                color: theme.colorScheme.onTertiaryContainer,
                child: ListTile(
                    title: Text(
                      wordPair.asLowerCase,
                      style: styleTextListTile,
                    ),
                    leading: Icon(
                        Icons.favorite,
                      size: 30.0,
                      color: theme.colorScheme.tertiaryContainer,
                    ),
                    onTap: () => removeFromFav(wordPair)
                ),
              )
          ).toList()
        ]
      ),
    );
  }
}