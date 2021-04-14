import 'package:app_boilerplate/components/add_task.dart';
import 'package:app_boilerplate/components/todo_item_tile.dart';
import 'package:app_boilerplate/data/todo_fetch.dart';
import 'package:app_boilerplate/data/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../components/todo_item_tile.dart';
import '../../../data/todo_list.dart';
import '../../../model/todo_item.dart';

class All extends StatefulWidget {
  All({Key key}) : super(key: key);

  @override
  _AllState createState() => _AllState();
}

class _AllState extends State<All> {
  @override
  void initState() {
    super.initState();
  }

  VoidCallback refetchQuery;
  @override
  Widget build(BuildContext context) {
    print("All tab");
    return Column(
      children: <Widget>[
        AddTask(
          onAdd: (value) {
            todoList.addTodo(value);
          },
        ),
        Expanded(
          child: Query(
            options: QueryOptions(document: TodoFetch.fetchAll),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              refetchQuery = refetch;
              if (result.hasErrors) {
                final snackBar = SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [Text("Error"), Icon(Icons.error)],
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return Container();
              }
              if (result.loading) {
                final snackBar = SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [Text("Loading"), CircularProgressIndicator()],
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return Container();
              }
              final List<LazyCacheMap> todos =
                  (result.data['todos'] as List<dynamic>).cast<LazyCacheMap>();
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  dynamic responseData = todos[index];
                  return TodoItemTile(
                      item: TodoItem.fromElements(responseData["id"],
                          responseData['title'], responseData['is_completed']),
                      delete: () {},
                      toggleIsCompleted: () {});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
