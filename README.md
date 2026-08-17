# TaskFlow

Flutter task manager app — 14 screens, dark mode, Riverpod state, Hive persistence.

## Stack

- Flutter 3.44.9 (FVM) · Dart 3.12
- Riverpod 2.6.1 — StateNotifierProvider
- Hive — local persistence, manual TypeAdapters
- SharedPreferences — onboarding flag
- Architecture: Feature-First

## Screens

| Screen | Route |
|--------|-------|
| Splash | `/splash` |
| Onboarding | `/onboarding` |
| Home | `/` |
| Schedule | `/schedule` |
| New Task | `/new-task` |
| Task Detail | `/task-detail` |
| Edit Task | `/edit-task` |
| Projects | `/projects` |
| Project Detail | `/project-detail` |
| Search | `/search` |
| Statistics | `/statistics` |
| Messages | `/messages` |
| Profile | `/profile` |
| Settings | `/settings` |

## Structure

```
lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/          # AppColors, AppTextStyles
│   ├── providers/          # taskProvider, projectProvider
│   ├── storage/            # LocalStorageService (Hive)
│   ├── themes/             # AppTheme, ThemeProvider
│   └── widgets/            # EmptyState, FilterBottomSheet
└── features/
    ├── splash/
    ├── onboarding/
    ├── home/
    ├── schedule/
    ├── new_task/
    ├── task_detail/
    ├── edit_task/
    ├── projects/
    ├── project_detail/
    ├── search/
    ├── statistics/
    ├── messages/
    ├── profile/
    └── settings/
```

## Setup

```bash
git clone https://github.com/TerraRome/TaskManager.git
cd TaskManager

# With FVM
fvm use
fvm flutter pub get
fvm flutter run -d emulator-5554 --no-enable-impeller

# Without FVM
flutter pub get
flutter run --no-enable-impeller
```

## Notes

- First launch shows 3-slide onboarding, skipped on return via SharedPreferences
- Dark mode toggles instantly via custom `ThemeProvider` (InheritedWidget)
- Hive TypeAdapters are written by hand — no build_runner
- `projectsWithTaskCountProvider` derives live task counts from both task and project providers
