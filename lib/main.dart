import 'package:flutter/material.dart';

import 'homepage.dart';

void main() {
  runApp(const BrickBreaker());
}

class BrickBreaker extends StatelessWidget {
  const BrickBreaker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
