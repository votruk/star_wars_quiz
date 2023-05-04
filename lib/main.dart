import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:star_wars_quiz/account/account_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDhUH-EAzSpLbuHfGN_GPkG1L-CparKCK8",
      appId: "1:1010433636082:web:c169fc74ec41115cf9826b",
      messagingSenderId: "1010433636082",
      projectId: "flutter-star-wars-quiz",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Wars Quiz',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const AccountPage(),
    );
  }
}
