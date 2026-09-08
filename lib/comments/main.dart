import 'package:flutter/material.dart';

// ============================================================================
// ENTRY POINT
// ============================================================================
// main() initializes the Dart VM execution context.
// runApp() inflates the given widget and attaches it to the screen via the
// root RenderView in Flutter's rendering pipeline.
void main() {
  runApp(const TodoApp());
}

// ============================================================================
// 1. DATA MODEL LAYER
// ============================================================================
// WHAT IT DOES: Represents the business data blueprint for an individual task.
//
// FRESHER INTERVIEW CONCEPT:
// - Data Encapsulation & Identity: Using a unique `id` (instead of relying on
//   list indices) is critical when items can be dynamically deleted, inserted,
//   or reordered.
class TodoItem {
  final String id;
  final String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

// ============================================================================
// 2. ROOT APPLICATION WIDGET (StatelessWidget)
// ============================================================================
// WHAT IT DOES: Sets up global app configuration: routing, theming, localization.
//
// FRESHER INTERVIEW CONCEPT:
// - StatelessWidget vs StatefulWidget:
//   StatelessWidget is immutable; its configuration does not change over time.
//   It delegates the actual state-bearing UI to child widgets.
// - const Constructors: Tells Flutter this subtree can be canonicalized at
//   compile time, skipping unnecessary rebuilds during garbage collection passes.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

// ============================================================================
// 3. MAIN SCREEN WIDGET (StatefulWidget)
// ============================================================================
// WHAT IT DOES: Defines a screen that holds mutable internal data that alters
// what appears on screen during runtime.
//
// FRESHER INTERVIEW CONCEPT:
// - Two-class Separation: Why is StatefulWidget split into two classes?
//   The Widget class (`TodoListScreen`) is lightweight and recreated constantly
//   whenever its parent rebuilds. The `State` class (`_TodoListScreenState`)
//   persists across rebuilds in the Element tree to preserve user data.
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

// ============================================================================
// 4. STATE IMPLEMENTATION & LIFECYCLE MANAGEMENT
// ============================================================================
// WHAT IT DOES: Manages the local array of todos, controls dialog inputs,
// coordinates mutations, and builds the visual widget tree.
class _TodoListScreenState extends State<TodoListScreen> {
  // In-memory data source
  final List<TodoItem> _todos = [];

  // Controller to read and manipulate text field input
  final TextEditingController _textController = TextEditingController();

  // --------------------------------------------------------------------------
  // LIFECYCLE: dispose()
  // --------------------------------------------------------------------------
  // WHAT IT DOES: Called when this State object is permanently removed from
  // the widget tree.
  //
  // FRESHER INTERVIEW CONCEPT:
  // - Memory Leaks: Controllers, Streams, and AnimationControllers register
  //   listeners on the native OS message loop. Failing to call `.dispose()`
  //   keeps those native bridges alive even after leaving the screen.
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // BUSINESS LOGIC: _addTodo()
  // --------------------------------------------------------------------------
  // WHAT IT DOES: Validates input text, creates a new TodoItem, and inserts it
  // at the top of the list.
  //
  // FRESHER INTERVIEW CONCEPT:
  // - setState() Mechanism: `setState()` does NOT immediately redraw the screen.
  //   It marks the current Element as "dirty" and schedules a build frame with
  //   the Engine. All mutations to internal state variables must happen inside
  //   or immediately before setState().
  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.insert(
        0,
        TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text,
        ),
      );
    });

    _textController.clear();
    Navigator.of(context).pop(); // Closes the modal bottom sheet/dialog
  }

  // --------------------------------------------------------------------------
  // BUSINESS LOGIC: _toggleTodo()
  // --------------------------------------------------------------------------
  // WHAT IT DOES: Inverts the completion status of a selected task.
  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  // --------------------------------------------------------------------------
  // BUSINESS LOGIC: _deleteTodo()
  // --------------------------------------------------------------------------
  // WHAT IT DOES: Removes an item and displays an interactive SnackBar with
  // an "UNDO" action.
  //
  // FRESHER INTERVIEW CONCEPT:
  // - Context and ScaffoldMessenger: `ScaffoldMessenger.of(context)` searches
  //   up the Element tree for the nearest ScaffoldMessenger ancestor to display
  //   snackbars reliably across asynchronous events.
  void _deleteTodo(int index) {
    final removed = _todos[index];
    setState(() {
      _todos.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removed.title}"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _todos.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // UI DIALOG BUILDER: _showAddDialog()
  // --------------------------------------------------------------------------
  // WHAT IT DOES: Pops an alert dialog modally on top of the current screen.
  //
  // FRESHER INTERVIEW CONCEPT:
  // - Modal Route Context: `showDialog` pushes a new Route to the Navigator stack.
  //   The `ctx` passed into the builder belongs to the dialog route itself,
  //   not the parent screen.
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What needs to be done?',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _addTodo(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textController.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _addTodo,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BUILD METHOD: UI RENDERING PIPELINE
  // --------------------------------------------------------------------------
  // WHAT IT DOES: Converts the current state configuration into a tree of Widgets.
  //
  // FRESHER INTERVIEW CONCEPT:
  // - Keep Build Pure: Never execute network calls, database queries, or heavy
  //   loops directly inside `build()`. `build()` can be invoked 60 to 120 times
  //   per second during animations or ancestor rebuilds.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 1,
      ),
      // Conditional rendering: Switch views based on state
      body: _todos.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet. Tap + to add one!',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              // --------------------------------------------------------------
              // FRESHER INTERVIEW CONCEPT: ListView.builder (Virtualization)
              // --------------------------------------------------------------
              // Unlike ListView(children: [...]), which instantiates EVERY child
              // in memory immediately, ListView.builder only renders tiles that
              // are currently inside (or immediately bordering) the viewport.
              // This maintains an O(1) memory footprint regardless of list size.
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final item = _todos[index];

                return Dismissible(
                  // ----------------------------------------------------------
                  // FRESHER INTERVIEW CONCEPT: Flutter Keys
                  // ----------------------------------------------------------
                  // Why ValueKey(item.id) instead of ValueKey(index)?
                  // If you delete an item at index 0, the next item slides into
                  // index 0. If you keyed by index, Flutter's element reconciliation
                  // assumes the widget didn't change and duplicates/mismatches
                  // animation or swipe states. A stable unique ID prevents this.
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteTodo(index),
                  child: CheckboxListTile(
                    value: item.isCompleted,
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    onChanged: (_) => _toggleTodo(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}