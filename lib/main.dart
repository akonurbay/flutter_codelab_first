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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 56, 56, 209)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  //List<String> notes = ['hello', 'world', 'this', 'is', 'a', 'test'];
  List<Note> notes = [];
void addNote(String title, String content) {
  notes.add(Note(title: title, content: content));
  notifyListeners();
}
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
  case 4:
    page = Settings();
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
                       ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
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

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Settings Page',
        style: TextStyle(fontSize: 24),
      ),
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
class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool selectionMode = false;
  Set<WordPair> selected = {};

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet, start adding some!'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 20, top: 80, bottom: 0),
          child: Text(
            'You have ${appState.favorites.length} favorites:',
            style: TextStyle(fontSize: 30),
          ),
        ),
        if (selectionMode)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 175, 137, 135)),
                    onPressed: () {
                      setState(() {
                        appState.favorites.removeWhere((pair) => selected.contains(pair));
                        selected.clear();
                        selectionMode = false;
                        appState.notifyListeners();
                      });
                    },
                    child: Text('Удалить'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 0, left: 0, top: 0, bottom: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selected.clear();
                        selectionMode = false;
                      });
                    },
                    child: Text('Отмена'),
                  ),
                ),
              ),
            ],
          ),
        Expanded(
          child: ListView(
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: selectionMode
                      ? Checkbox(
                          value: selected.contains(pair),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selected.add(pair);
                              } else {
                                selected.remove(pair);
                              }
                            });
                          },
                        )
                      : Icon(Icons.favorite),
                  title: Text(pair.asLowerCase),
                  onLongPress: () {
                    setState(() {
                      selectionMode = true;
                      selected.add(pair);
                    });
                  },
                  trailing: !selectionMode
                      ? IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Удалить из избранного',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Удалить из избранного?'),
                                content: Text('Вы действительно хотите удалить это слово из избранного?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Нет'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Да'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              setState(() {
                                appState.favorites.remove(pair);
                                appState.notifyListeners();
                              });
                            }
                          },
                        )
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}


  Set<WordPair> selected = {};
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
              onPressed: () async{
                final confirm  = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete favorite?'),
                    content: Text('Are you sure you want to delete this favorite?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete'),
                      ),
                    ],
                  )
                );
                if(confirm == true){
                  appState.favorites.remove(pair);
                  appState.notifyListeners();
                }
              },
            ),
          ),
      ],
    );
  }
class AddNotesPage extends StatefulWidget {
  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: 'Content'),
            maxLines: 3,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                appState.addNote(_titleController.text, _contentController.text);
                _titleController.clear();
                _contentController.clear();
              }
            },
            child: Text('Add Note'),
          ),
        ],
      ),
    );
  }
}
class Note {
  String title;
  String content;
  Note({required this.title, required this.content});
}

class ListOfNotesPage extends StatefulWidget {
  @override
  State<ListOfNotesPage> createState() => _ListOfNotesPageState();
}

class _ListOfNotesPageState extends State<ListOfNotesPage> {
  bool selectionMode = false;
  Set<int> selected = {};
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  void _editNote(BuildContext context, int index, Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                note.title = titleController.text;
                note.content = contentController.text;
                context.read<MyAppState>().notifyListeners();
              });
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  var appState = context.watch<MyAppState>();

  final filteredNotes = appState.notes
      .where((note) =>
          note.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchText.toLowerCase()))
      .toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'You have ${filteredNotes.length} notes:',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search notes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          if (selectionMode)
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        setState(() {
                          appState.notes = [
                            for (int i = 0; i < appState.notes.length; i++)
                              if (!selected.contains(i)) appState.notes[i]
                          ];
                          selected.clear();
                          selectionMode = false;
                          appState.notifyListeners();
                        });
                      },
                      child: Text('Удалить выбранные'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selected.clear();
                          selectionMode = false;
                        });
                      },
                      child: Text('Отмена'),
                    ),
                  ),
                ),
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                final realIndex = appState.notes.indexOf(note);
                return ListTile(
                  leading: selectionMode
                      ? Checkbox(
                          value: selected.contains(realIndex),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selected.add(realIndex);
                              } else {
                                selected.remove(realIndex);
                              }
                            });
                          },
                        )
                      : Icon(Icons.note),
                  title: Text(note.title),
                  subtitle: Text(
                    note.content.length > 30
                        ? note.content.substring(0, 30) + '...'
                        : note.content,
                  ),
                  onTap: () {
                    _editNote(context, realIndex, note);
                  },
                  onLongPress: () {
                    setState(() {
                      selectionMode = true;
                      selected.add(realIndex);
                    });
                  },
                  trailing: !selectionMode
                      ? IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editNote(context, realIndex, note);
                          },
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} // ← закрывает _ListOfNotesPageState

// Дальше твой следующий класс:
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
}