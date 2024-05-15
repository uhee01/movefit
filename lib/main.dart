import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_goal_hive_object.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_hive_object.dart';
import 'package:movefit_app/view/home_view.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WorkHistoryHiveObjectAdapter());
  Hive.registerAdapter(WorkGoalHiveObjectAdapter());
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
