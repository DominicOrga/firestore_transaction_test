import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int count = 0;

  bool isTransactionRunning = false;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore
        .doc('Counter/counter')
        .snapshots()
        .listen((event) => setState(() => count = event.data()['count']));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Transaction Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Count: $count'),
              SizedBox(height: 20),
              Builder(
                builder: (context) => MaterialButton(
                  onPressed: () => doTransaction(context),
                  color: Colors.blue,
                  child: Text(
                    'Test Firestore Transaction',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (isTransactionRunning) CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }

  void doTransaction(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final docRef = firestore.doc('Counter/counter');

    setState(() => isTransactionRunning = true);

    try {
      // Run a transaction.
      await firestore.runTransaction((transaction) async {
        transaction.update(docRef, {'count': FieldValue.increment(1)});
      });
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('An exception was thrown: $e'),
      ));
      print(e);
    }

    setState(() => isTransactionRunning = false);
  }
}
