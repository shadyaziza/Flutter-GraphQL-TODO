import 'package:app_boilerplate/components/add_task.dart';
import 'package:app_boilerplate/components/todo_item_tile.dart';
import 'package:app_boilerplate/data/todo_fetch.dart';
import 'package:app_boilerplate/data/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../components/todo_item_tile.dart';
import '../../../data/todo_list.dart';
import '../../../model/todo_item.dart';

class Active extends StatefulWidget {
  Active({Key key}) : super(key: key);

  @override
  _ActiveState createState() => _ActiveState();
}

class _ActiveState extends State<Active> {
  @override
  void initState() {
    super.initState();
  }

  VoidCallback refetchQuery;
  @override
  Widget build(BuildContext context) {
    print("active tab");
    return Column(
      children: <Widget>[
        Mutation(
          options: MutationOptions(document: TodoFetch.addTodo),
          update: (Cache cache, QueryResult result) {
            return cache;
          },
          onCompleted: (dynamic resultData) {
            refetchQuery();
          },
          builder: (
            RunMutation runMutation,
            QueryResult result,
          ) {
            return AddTask(
              onAdd: (value) {
                runMutation({'title': value, 'isPublic': false});
              },
            );
          },
        ),
        Expanded(
          child: Query(
            options: QueryOptions(document: TodoFetch.fetchActive),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              refetchQuery = refetch;
              if (result.hasErrors) {
                final snackBar = SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(result.errors.toString()),
                      Icon(Icons.error)
                    ],
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
                    toggleDocument: TodoFetch.toggleTodo,
                    toggleRunMutaion: {
                      'id': responseData["id"],
                      'isCompleted': !responseData['is_completed']
                    },
                    refetchQuery: refetchQuery,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
