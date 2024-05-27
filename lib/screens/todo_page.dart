import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slite/database/todo_db.dart';
import 'package:slite/model/todo.dart';
import 'package:slite/widget/create_todo_widget.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
//getting all todo
  Future<List<Todo>>? futureTodos;
  final todoDb = TodoDB();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDb.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Todo List"),
        ),
        body: FutureBuilder<List<Todo>>(
          future: futureTodos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final todos = snapshot.data ?? [];
              return todos.isEmpty
                  ? const Center(
                      child: Text("No todos . . ."),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        final subtitle = DateFormat('yyyy/MM/dd').format(
                            DateTime.parse(todo.updatedAt ?? todo.createAt));
                        return ListTile(
                          title: Text(todo.title),
                          subtitle: Text(subtitle),
                          trailing: IconButton(
                              onPressed: () async {
                                await todoDb.delete(todo.id);
                                fetchTodos();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                          onTap: () {
                            showAdaptiveDialog(
                              context: context,
                              builder: (context) => CreateTodoWidget(
                                  todo: todo,
                                  onSubbmit: (title) async {
                                    await todoDb.update(
                                        id: todo.id, title: title);
                                    fetchTodos();
                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                  }),
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                            height: 5,
                          ),
                      itemCount: todos.length);
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => CreateTodoWidget(
                onSubbmit: (title) async {
                  await todoDb.create(title: title);
                  if (!mounted) return;
                  fetchTodos();
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
