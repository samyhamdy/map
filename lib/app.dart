// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'map_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MapScreen());
  }
}
