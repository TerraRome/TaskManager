import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'features/schedule/presentation/pages/schedule_page.dart';
import 'features/new_task/presentation/pages/new_task_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const SchedulePage(),
        '/new-task': (_) => const NewTaskPage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
