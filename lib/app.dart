// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'map_clusters_example/map_cluster_example.dart';
import 'map_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(useMaterial3: false),
        debugShowCheckedModeBanner: false,
        home: MapClusteringExample()
        //  MapScreen()

        );
  }
}
