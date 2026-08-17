# TaskFlow

A task manager built with Flutter. 14 screens, dark mode, local persistence, Riverpod state management.

**Stack:** Flutter 3.44.9 · Dart 3.12 · Riverpod · Hive · SharedPreferences  
**Repo:** https://github.com/TerraRome/TaskManager

---

## Screenshots

### Onboarding

| Splash | Home | Schedule | New Task |
|--------|------|----------|---------|
| <img src="docs/screenshots/01_splash.png" width="180"> | <img src="docs/screenshots/05_home.png" width="180"> | <img src="docs/screenshots/06_schedule.png" width="180"> | <img src="docs/screenshots/07_new_task.png" width="180"> |

### Tasks & Projects

| Task Detail | Edit Task | Projects | Project Detail |
|------------|----------|---------|---------------|
| <img src="docs/screenshots/08_task_detail.png" width="180"> | <img src="docs/screenshots/09_edit_task.png" width="180"> | <img src="docs/screenshots/10_projects.png" width="180"> | <img src="docs/screenshots/11_project_detail.png" width="180"> |

### More Screens

| Search | Statistics | Messages | Profile | Settings |
|--------|-----------|---------|---------|---------|
| <img src="docs/screenshots/12_search.png" width="150"> | <img src="docs/screenshots/13_statistics.png" width="150"> | <img src="docs/screenshots/14_messages.png" width="150"> | <img src="docs/screenshots/15_profile.png" width="150"> | <img src="docs/screenshots/16_settings.png" width="150"> |

### Dark Mode

| Home | Schedule | Projects | Profile | Messages |
|------|----------|---------|---------|---------|
| <img src="docs/screenshots/17_home_dark.png" width="150"> | <img src="docs/screenshots/18_schedule_dark.png" width="150"> | <img src="docs/screenshots/19_projects_dark.png" width="150"> | <img src="docs/screenshots/20_profile_dark.png" width="150"> | <img src="docs/screenshots/21_messages_dark.png" width="150"> |

---

## Flows

| Onboarding | New Task |
|-----------|---------|
| <img src="docs/gifs/onboarding_flow.gif" width="200"> | <img src="docs/gifs/new_task_flow.gif" width="200"> |

---

## How it works

**Navigation**  
Splash checks `onboarding_done` in SharedPreferences. First launch goes to onboarding, subsequent launches go straight to home. Onboarding has 3 slides with per-slide slide-in and fade animations.

**State**  
Riverpod `StateNotifierProvider` for tasks and projects. `projectsWithTaskCountProvider` is a derived provider that computes live task counts from both providers — used across Projects, Project Detail, and Statistics without duplication.

**Storage**  
Hive with hand-written TypeAdapters (no build_runner). Tasks and projects persist across launches. Seed data loads on first run when boxes are empty.

**Dark mode**  
Custom `ThemeProvider` using `InheritedWidget`. No external library. All screens use `Theme.of(context).colorScheme.*` — switching is instant and doesn't restart the app.

**Architecture**  
Feature-first: each screen lives in its own folder with `domain/models/`, `presentation/pages/`, and `presentation/widgets/`. The core layer holds shared providers, storage, themes, and widgets.

---

## Running locally

```bash
git clone https://github.com/TerraRome/TaskManager.git
cd TaskManager
flutter pub get
flutter run --no-enable-impeller   # Android
flutter run                        # iOS
```

Flutter 3.44.9+ required. With FVM: `fvm flutter run`.
