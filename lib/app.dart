import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/schedule/presentation/pages/schedule_page.dart';
import 'features/new_task/presentation/pages/new_task_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/projects/presentation/pages/projects_page.dart';
import 'features/messages/presentation/pages/messages_page.dart';
import 'features/edit_task/presentation/pages/edit_task_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/search/presentation/pages/search_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/project_detail/presentation/pages/project_detail_page.dart';
import 'features/projects/domain/models/project_item.dart';
import 'features/task_detail/presentation/pages/task_detail_page.dart';
import 'features/schedule/domain/models/task_item.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.isDark(context);
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/': (_) => const HomePage(),
        '/schedule': (_) => const SchedulePage(),
        '/new-task': (_) => const NewTaskPage(),
        '/profile': (_) => const ProfilePage(),
        '/projects': (_) => const ProjectsPage(),
        '/messages': (_) => const MessagesPage(),
        '/search': (_) => const SearchPage(),
        '/settings': (_) => const SettingsPage(),
        '/statistics': (_) => const StatisticsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/task-detail') {
          final task = settings.arguments as TaskItem;
          return MaterialPageRoute(
            builder: (_) => TaskDetailPage(task: task),
          );
        }
        if (settings.name == '/edit-task') {
          final task = settings.arguments as TaskItem;
          return MaterialPageRoute(
            builder: (_) => EditTaskPage(task: task),
          );
        }
        if (settings.name == '/project-detail') {
          final project = settings.arguments as ProjectItem;
          return MaterialPageRoute(
            builder: (_) => ProjectDetailPage(project: project),
          );
        }
        return null;
      },
    );
  }
}
