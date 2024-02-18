import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:list_test/auth.dart';
import 'package:list_test/firebase_options.dart';
import 'package:list_test/firestore.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Assuming _onReorder and _itemOrder are part of MyListWidget's state or passed in some way
class MyListWidget extends StatefulWidget {
  final String title;

  const MyListWidget({Key? key, required this.title}) : super(key: key);

  @override
  MyListWidgetState createState() => MyListWidgetState();
}

class MyListWidgetState extends State<MyListWidget> {
  List<int> _itemOrder = [];
  List<Task> gTasks = [];
  bool isInputBoxVisible =
      false; // Step 1: State variable for input box visibility

  final TextEditingController _newTaskController = TextEditingController();
  final FocusNode _newTaskFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _itemOrder = List.generate(25, (index) => index);
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final int item = _itemOrder.removeAt(oldIndex);
      _itemOrder.insert(newIndex, item);
    });
  }

  Future<void> signOut() async {
    try {
      await Auth().signOut();
      // ignore: unused_catch_clause
    } on FirebaseAuthException catch (e) {
      // Handle the sign-out error
    }
  }

  List<Widget> _buildListTiles() {
    if (gTasks.isEmpty) {
      return [];
    }
    return gTasks.map((task) {
      return ListTile(
        key: Key(task.id),
        title: Text(task.name),
      );
    }).toList();
  }

  Widget newTaskWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            // Use Expanded to ensure the TextField takes up most of the row
            child: TextField(
              controller: _newTaskController,
              focusNode: _newTaskFocusNode,
              decoration: const InputDecoration(
                labelText: 'Enter task',
                border: OutlineInputBorder(),
                // Adjusted to include only the left, top, and bottom borders since the button will be on the right
                // This is optional and can be adjusted according to your UI design
              ),
            ),
          ),
          IconButton(
            // Using an IconButton for a more compact layout, but you can use any button widget
            icon: const Icon(Icons.send),
            onPressed: () {
              // Add your send task logic here
              // For example, you could call a method to add the task to a list or database
              _addTask(_newTaskController.text);
              // Optionally, clear the text field and unfocus after sending
              _newTaskController.clear();
              _newTaskFocusNode.requestFocus();
            },
          ),
        ],
      ),
    );
  }

  void _addTask(String taskText) {
    String name = taskText.trim();
    if (name.isEmpty) return;
    DB().addTaskRecord(taskText, "", "", false, false, 0, "", false, null);
    // Implement task sending logic here
    // For example, adding the task to a list or sending it to a database
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DB().streamTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasData) gTasks = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Column(
            children: [
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  onReorder: onReorder,
                  children: _buildListTiles(),
                ),
              ),
              Visibility(
                // Step 3: Input box with Visibility control
                visible: isInputBoxVisible,
                child: newTaskWidget(),
              ),
            ],
          ),
          floatingActionButton: Visibility(
            visible: !isInputBoxVisible,
            child: FloatingActionButton(
              onPressed: () {
                _newTaskFocusNode.requestFocus();
                // Step 2: Toggle input box visibility
                setState(() {
                  isInputBoxVisible = !isInputBoxVisible;
                });
              },
              tooltip: 'Add Task',
              child: Icon(isInputBoxVisible ? Icons.close : Icons.add),
            ),
          ),
        );
      },
    );
  }
}

class LoginWidget extends StatefulWidget {
  final String title;

  const LoginWidget({Key? key, required this.title}) : super(key: key);

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _bLoginProgress = false;
  String _loginError = "";

  Future<void> signInWithEmailAndPassword() async {
    try {
      setState(() {
        _bLoginProgress = true;
      });

      await Auth().signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );

      setState(() {
        _bLoginProgress = false;
      });
    } on FirebaseAuthException catch (e) {
      //  showMessage(e.message!, true);
      setState(() {
        _bLoginProgress = false;
        _loginError = e.message!;
      });
    }
  }

  Widget loginWidget() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null; // Return null if the entered username is valid
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.password),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null; // Return null if the entered username is valid
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, otherwise false.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a Snackbar.
                  setState(() {
                    _bLoginProgress = true;
                  });
                  signInWithEmailAndPassword();
                }
              },
              child: const Text('Submit'),
            ),
          ),
          const SizedBox(height: 10),
          _bLoginProgress
              ? const CircularProgressIndicator()
              : Text(_loginError)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Please login"),
      ),
      body: loginWidget(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // _itemOrder = List.generate(25, (index) => index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return const MyListWidget(title: "Test List");
        } else {
          return const LoginWidget(title: "Login");
        }
      },
    );
  }
}
