import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Welcome ${widget.userName}\n to the Tasks App",
        textAlign: TextAlign.center,
      ),
    );
  }
}
