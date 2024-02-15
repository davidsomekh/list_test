import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:list_test/auth.dart';
import 'package:list_test/firebase_options.dart';

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
      //  showMessage(e.message!, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        onReorder: onReorder,
        children: _itemOrder
            .map((index) => ListTile(
                  key: Key('$index'),
                  title: Text('Item $index'),
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          signOut();
        },
        tooltip: 'Signout',
        child: const Icon(Icons.logout),
      ),
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _bLoginProgress = false;
  String _loginError = "";

  @override
  void initState() {
    super.initState();
    // _itemOrder = List.generate(25, (index) => index);
  }

  Widget loginPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body:
          loginWidget(), // This already returns a Form widget wrapped in a Column
    );
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
          return loginPage();
        }
      },
    );
  }
}
