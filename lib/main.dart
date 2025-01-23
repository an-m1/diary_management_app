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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
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
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
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
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var diaryState = context.watch<DiaryState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              reverse: true,
              itemCount: diaryState.notes.length,
              itemBuilder: (context, index) {
                var note = diaryState.notes[index];
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final TextEditingController _titleController = TextEditingController(text: note.title);
                              final TextEditingController _bodyController = TextEditingController(text: note.body);

                              return AlertDialog(
                                title: Text('Edit Note'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Title',
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: _bodyController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Body',
                                      ),
                                      maxLines: 5,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
                                        diaryState.updateNote(note, _titleController.text, _bodyController.text);
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
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
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController _titleController = TextEditingController();
                  final TextEditingController _bodyController = TextEditingController();

                  return AlertDialog(
                    title: Text('New Note'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Title',
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _bodyController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Body',
                            ),
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
                            diaryState.addNote(
                              _titleController.text,
                              _bodyController.text,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Add Note'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Add Note'),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class AllNotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var diaryState = context.watch<DiaryState>();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: diaryState.sortedNotes.map((note) {
        return ListTile(
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
                icon: Icon(note.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  diaryState.toggleFavorite(note);
                },
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final TextEditingController _titleController = TextEditingController(text: note.title);
                      final TextEditingController _bodyController = TextEditingController(text: note.body);

                      return AlertDialog(
                        title: Text('Edit Note'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Title',
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: _bodyController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Body',
                                ),
                                maxLines: 5,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
                                diaryState.updateNote(note, _titleController.text, _bodyController.text);
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text('Save'),
                          ),
                        ],
                      );
                    },
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
      }).toList(),
    );
  }
}
