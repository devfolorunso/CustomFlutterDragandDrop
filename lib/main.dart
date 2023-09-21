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

class MyApp extends StatelessWidget {
  final List<User> users = List.generate(
    10,
    (index) => User(index, 'User ${index + 1} Jonathan'),
  );

  final int maxSlots = 5;
  final List<Slot> slots = List.generate(
    20,
    (index) => Slot(index, []),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Drag and Drop Gymnastics'),
        ),
        body: Row(
          children: [
            UserList(users: users),
            SlotList(maxSlots: maxSlots, slots: slots),
          ],
        ),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  final List<User> users;

  UserList({required this.users});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        slivers: [
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
                        feedback: UserTile(user: user),
                        childWhenDragging: UserTile(user: user),
                        child: Column(
                          children: [
                            UserTile(user: user),
                            Text(user.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;

  UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      padding: const EdgeInsets.all(8),
      color: Colors.blue,
      child: Text(user.name),
    );
  }
}

class SlotList extends StatefulWidget {
  final int maxSlots;
  final List<Slot> slots;

  SlotList({required this.maxSlots, required this.slots});

  @override
  createState() => _SlotListState();
}

class _SlotListState extends State<SlotList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                children: widget.slots.map((slot) {
                  return SlotWidget(
                    maxSlots: widget.maxSlots,
                    slot: slot,
                    onSlotUpdated: () {
                      setState(() {}); // Refresh the UI when a slot is updated.
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SlotWidget extends StatefulWidget {
  final int maxSlots;
  final Slot slot;
  final Function onSlotUpdated;

  createState() => _SlotWidgetState();
  SlotWidget(
      {required this.maxSlots,
      required this.slot,
      required this.onSlotUpdated});
}

class _SlotWidgetState extends State<SlotWidget> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<User>(
      builder: (context, List<User?> incoming, List<dynamic> rejected) {
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
                    'Slot ${widget.slot.id + 1}',
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
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.slot.users.length,
                    itemBuilder: (context, index) {
                      final user = widget.slot.users[index];
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
        if (widget.slot.users.length < widget.maxSlots) {
          return true;
        } else {
          print("MaxSlots: reached"); // Display a warning message
          return false;
        }
      },
      onAccept: (data) {
        setState(() {
          widget.slot.users.add(data);
          widget.onSlotUpdated();
        });
      },
    );
  }
}
