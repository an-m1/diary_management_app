// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DiaryState(),
      child: MaterialApp(
        title: 'Note Taking App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class Note {
  String title;
  String body;
  DateTime created;
  DateTime modified;
  bool isFavorite;

  Note({
    required this.title,
    required this.body,
    required this.created,
    required this.modified,
    this.isFavorite = false,
  });
}

class DiaryState extends ChangeNotifier {
  List<Note> notes = [];

  void addNote(String title, String body) {
    notes.insert(0, Note(
      title: title,
      body: body,
      created: DateTime.now(),
      modified: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateNote(Note note, String newTitle, String newBody) {
    note.title = newTitle;
    note.body = newBody;
    note.modified = DateTime.now();
    notifyListeners();
  }

  void deleteNote(Note note) {
    notes.remove(note);
    notifyListeners();
  }

  void toggleFavorite(Note note) {
    note.isFavorite = !note.isFavorite;
    notifyListeners();
  }

  List<Note> get sortedNotes {
    return notes
      ..sort((a, b) {
        if (a.isFavorite != b.isFavorite) {
          return b.isFavorite ? 1 : -1;
        }
        return b.modified.compareTo(a.modified);
      });
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
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = NotesPage();
        break;
      case 1:
        page = AllNotesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 450) {
              return Column(
                children: [
                  Expanded(child: mainArea),
                  BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Notes',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        label: 'All Notes',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  )
                ],
              );
            } else {
              return Row(
                children: [
                  NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Notes'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.list),
                        label: Text('All Notes'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                  Expanded(child: mainArea),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var diaryState = context.watch<DiaryState>();
    var recentNotes = diaryState.sortedNotes.take(8).toList();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recentNotes.isNotEmpty)
              Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
                child: Text(
                  'Your Recent Notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
                ),
              ),
            if (recentNotes.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                'Create a new note to get started',
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: recentNotes.length,
                  itemBuilder: (context, index) {
                    var note = recentNotes[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(note.modified)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(note.isFavorite ? Icons.favorite : Icons.favorite_border),
                            onPressed: () {
                              diaryState.toggleFavorite(note);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteEditor(
                                    note: note,
                                    onSave: (newTitle, newBody) {
                                      diaryState.updateNote(note, newTitle, newBody);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              diaryState.deleteNote(note);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditor(
                    onSave: (title, body) {
                      diaryState.addNote(title, body);
                    },
                  ),
                ),
              );
            },
            child: Icon(Icons.note_add),
          ),
        ),
      ],
    );
  }
}

class AllNotesPage extends StatefulWidget {
  @override
  State<AllNotesPage> createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var diaryState = context.watch<DiaryState>();
    var favoriteNotes = diaryState.sortedNotes.where((note) => note.isFavorite).toList();
    var otherNotes = diaryState.sortedNotes.where((note) => !note.isFavorite).toList();
    var filteredFavorites = favoriteNotes
        .where((note) => note.title.contains(searchQuery) || note.body.contains(searchQuery))
        .toList();
    var filteredOtherNotes = otherNotes
        .where((note) => note.title.contains(searchQuery) || note.body.contains(searchQuery))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search notes...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              if (filteredFavorites.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Your Favorites',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ...filteredFavorites.map((note) => ListTile(
                    title: Text(note.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Created: ${DateFormat('yyyy-MM-dd HH:mm').format(note.created)}'),
                        Text('Modified: ${DateFormat('yyyy-MM-dd HH:mm').format(note.modified)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite),
                          onPressed: () {
                            diaryState.toggleFavorite(note);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteEditor(
                                  note: note,
                                  onSave: (newTitle, newBody) {
                                    diaryState.updateNote(note, newTitle, newBody);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            diaryState.deleteNote(note);
                          },
                        ),
                      ],
                    ),
                  )),
              if (filteredOtherNotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'All Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ...filteredOtherNotes.map((note) => ListTile(
                    title: Text(note.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Created: ${DateFormat('yyyy-MM-dd HH:mm').format(note.created)}'),
                        Text('Modified: ${DateFormat('yyyy-MM-dd HH:mm').format(note.modified)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: () {
                            diaryState.toggleFavorite(note);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteEditor(
                                  note: note,
                                  onSave: (newTitle, newBody) {
                                    diaryState.updateNote(note, newTitle, newBody);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            diaryState.deleteNote(note);
                          },
                        ),
                      ],
                    ),
                  )),
              if (filteredFavorites.isEmpty && filteredOtherNotes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'There are no notes to display',
                      style: TextStyle(fontSize: 16, color: Colors.black45),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class NoteEditor extends StatelessWidget {
  final Note? note;
  final Function(String title, String body) onSave;

  NoteEditor({this.note, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController(text: note?.title);
    final TextEditingController bodyController =
        TextEditingController(text: note?.body);

    return Scaffold(
      appBar: AppBar(
        title: Text(note == null ? 'New Note' : 'Edit Note'),
        actions: [
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  bodyController.text.isNotEmpty) {
                onSave(titleController.text, bodyController.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: TextField(
                  controller: bodyController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Body',
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          bodyController.text.isNotEmpty) {
                        onSave(titleController.text, bodyController.text);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(note == null ? 'Create Note' : 'Save Note'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
