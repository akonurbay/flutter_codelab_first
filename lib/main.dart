import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  toggleFavourite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    }
    else{favorites.add(current);}
    notifyListeners();
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    Widget page;
switch (selectedIndex) {
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
  case 2:
    page = AddNotesPage();
  case 3:
    page = ListOfNotesPage();
    break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 700,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.edit_note_sharp, size: 30),
                       label: Text('AddNotes')
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.format_list_numbered_rtl_rounded, size: 30),
                      label: Text('ListOfNotes')
                       )
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
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
    var pair = appState.current;
var iconSize = 24.0; // Стандартный размер иконки
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
      iconSize = 40.0; // Увеличенный размер иконки
    } else {
      icon = Icons.favorite_border;
      iconSize = 24.0; // Стандартный размер иконки
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
              SizedBox(width: 30),
              ElevatedButton.icon(
  onPressed: () { appState.toggleFavourite(); },
  icon: AnimatedSwitcher(
    duration: Duration(milliseconds: 300),
    transitionBuilder: (child, animation) =>
        ScaleTransition(scale: animation, child: child),
    child: Icon(
      icon,
      key: ValueKey(iconSize), // ключ для анимации смены размера
      size: iconSize,
      color: const Color.fromARGB(255, 196, 35, 104),
    ),
  ),
  label: Text('LIKE'),
)
            ],
          ),
        ],
      ),
    );
  }
}
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet, start adding some!'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:',style: TextStyle(fontSize:30 ),),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              tooltip: 'Удалить из избранного',
              onPressed: () {
                appState.favorites.remove(pair);
                appState.notifyListeners();
              },
            ),
          ),
      ],
    );
  }
}

class AddNotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Add Notes Page'),
    );
  }
}
class ListOfNotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('List of Notes Page'),
    );
  }
}
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(
          pair.asLowerCase,
         style: style,
         semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}// test comment