import 'package:flutter/material.dart';
import 'package:service_test_new/Service/comment_service.dart';
import 'package:service_test_new/view/comment_view.dart';

void main() {
  final service = CommentService();
  print(service.fakeApiKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yorumlar',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const CommentView(),
    );
  }
}
