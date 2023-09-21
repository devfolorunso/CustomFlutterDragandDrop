import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

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
  const MyApp({super.key});

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

  bool showBodySideBySide = true;

//
  void toggleBody() {
    setState(() {
      showBodySideBySide = !showBodySideBySide;
    });
  }

//
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
        body: showBodySideBySide ? buildBodySideBySide() : buildBodyTopBottom(),
        floatingActionButton: FloatingActionButton(
          onPressed: toggleBody,
          child: const Icon(Icons.swap_horiz),
        ),
      ),
    );
  }

//
  Widget buildBodySideBySide() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              UserList(users: users),
              SlotList(
                maxSlots: maxSlots,
                slots: slots,
                showBodySideBySide: showBodySideBySide,
              ),
            ],
          ),
        ),
        PrintSlotAllocationButton(slots: slots),
      ],
    );
  }

  Widget buildBodyTopBottom() {
    return Column(
      children: [
        UserList(users: users),
        SlotList(
          maxSlots: maxSlots,
          slots: slots,
          showBodySideBySide: showBodySideBySide,
        ),
      ],
    );
  }
}

class UserList extends StatelessWidget {
  final List<User> users;

  const UserList({super.key, required this.users});

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

  const UserTile({super.key, required this.user});

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
  final bool showBodySideBySide;

  const SlotList(
      {super.key,
      required this.maxSlots,
      required this.slots,
      required this.showBodySideBySide});

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
                    showBodySideBySide: widget.showBodySideBySide,
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
  final bool showBodySideBySide;

  @override
  createState() => _SlotWidgetState();
  const SlotWidget(
      {super.key,
      required this.maxSlots,
      required this.slot,
      required this.onSlotUpdated,
      required this.showBodySideBySide});
}

class _SlotWidgetState extends State<SlotWidget> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<User>(
      builder: (context, List<User?> incoming, List<dynamic> rejected) {
        return SizedBox(
          height: 200,
          width: widget.showBodySideBySide
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width / 4,
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

class PrintSlotAllocationButton extends StatelessWidget {
  final List<Slot> slots;

  PrintSlotAllocationButton({super.key, required this.slots});

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
    return ElevatedButton(
      onPressed: printSlotAllocation,
      child: const Text('Print Slot Allocation'),
    );
  }
}
