import 'package:flutter/material.dart';

import 'theme/mindscroll_theme.dart';
import 'views/dashboard.dart';

void main() {
  runApp(const MindScroll());
}

class MindScroll extends StatelessWidget {
  const MindScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindScroll',
      debugShowCheckedModeBanner: false,
      theme: mindScrollDarkTheme,
      home: const Dashboard(),
    );
  }
}
