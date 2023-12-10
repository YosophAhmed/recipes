import 'package:flutter/material.dart';
import 'package:recipes/data/memory_repository.dart';
import 'package:recipes/ui/main_screen.dart';
import 'dart:developer';
import 'package:logging/logging.dart';
import 'mock_service/mock_service.dart';
import 'package:provider/provider.dart';

void main() {
  _setupLogging();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MemoryRepository>(
          lazy: false,
          create: (_) => MemoryRepository(),
        ),
        Provider(
          lazy: false,
          create: (_) => MockService()..create(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recipes',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(
    (rec) {
      log('${rec.level.name}: ${rec.time}: ${rec.message}');
    },
  );
}
