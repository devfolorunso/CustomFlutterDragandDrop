import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Slot {
  final int id;
  final List<User> users;

  Slot(this.id, this.users);
}

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}

class MyApp extends StatefulWidget {
  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<User> users = List.generate(
    10,
    (index) => User(index, 'User ${index + 1} Jonathan'),
  );

  final int maxSlots = 5;
  final List<Slot> slots = List.generate(
    20,
    (index) => Slot(index, []),
  );

  void printSlotAllocation() {
    final Map<String, List<String>> slotAllocation = {};

    for (int i = 0; i < slots.length; i++) {
      final slot = slots[i];
      final List<String> userNames = [];

      for (int j = 0; j < slot.users.length; j++) {
        final user = slot.users[j];
        userNames.add("${user.id}");
      }

      slotAllocation["Slot ${slot.id + 1}"] = userNames;
    }

    print(slotAllocation);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Drag and Drop Gymnastics'),
          ),
          body: Row(
            children: [
              // User on the left side
              Expanded(
                  flex: 1,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true, slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.deepOrange,
                        padding: const EdgeInsets.all(16),
                        width: (MediaQuery.of(context).size.width) - 300,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: users
                              .map(
                                (user) => Draggable<User>(
                                  data: user,
                                  feedback: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.blue.withOpacity(0.7),
                                    child: Text(user.name),
                                  ),
                                  childWhenDragging: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.blue.withOpacity(0.7),
                                    child: Text(user.name),
                                  ),
                                  child: Column(children: [
                                    Container(
                                        height: 50,
                                        width: 50,
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.blue,
                                        child: Text(user.name)),
                                    Text(user.name),
                                  ]),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ])),

              Expanded(
                flex: 1,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  slivers: [
                    SliverToBoxAdapter(
                        child: Container(
                      padding: const EdgeInsets.all(16),
                      width: (MediaQuery.of(context).size.width / 2) - 8,
                      child: Wrap(
                        children: List.generate(
                          slots.length,
                          (slotIndex) {
                            final slot = slots[slotIndex];

                            return DragTarget<User>(
                              builder: (
                                context,
                                List<User?> incoming,
                                List<dynamic> rejected,
                              ) {
                                return SizedBox(
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  child: Card(
                                    elevation: 2,
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            'Slot ${slot.id + 1}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 155,
                                          padding: const EdgeInsets.all(4),
                                          color: Colors.blueAccent,
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: slot.users.length,
                                            itemBuilder: (context, index) {
                                              final user = slot.users[index];
                                              return ListTile(
                                                key: ValueKey(user.id),
                                                title: Text(
                                                  user.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              onWillAccept: (data) {
                                if(slot.users.length < maxSlots){
                                  return true;
                                }else{
                                  print("MaxSlots: reached"); // Display a waning message
                                  return false;
                                }
                              },
                            
                              onAccept: (data) {
                                setState(() {
                                  slot.users.add(data);
                                });
                              },
                            );
                          },
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
