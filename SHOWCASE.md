# TaskFlow — App Showcase

> Flutter task manager app · 14 screens · Riverpod · Hive · Dark mode · Onboarding

---

## Screenshots

> Run `bash scripts/capture.sh screenshots` to capture all screens from the emulator.

| Screen | File |
|--------|------|
| Splash | `docs/screenshots/01_splash.png` |
| Onboarding 1 | `docs/screenshots/02_onboarding_1.png` |
| Onboarding 2 | `docs/screenshots/03_onboarding_2.png` |
| Onboarding 3 | `docs/screenshots/04_onboarding_3.png` |
| Home | `docs/screenshots/05_home.png` |
| Schedule | `docs/screenshots/06_schedule.png` |
| New Task | `docs/screenshots/07_new_task.png` |
| Task Detail | `docs/screenshots/08_task_detail.png` |
| Edit Task | `docs/screenshots/09_edit_task.png` |
| Projects | `docs/screenshots/10_projects.png` |
| Project Detail | `docs/screenshots/11_project_detail.png` |
| Search | `docs/screenshots/12_search.png` |
| Statistics | `docs/screenshots/13_statistics.png` |
| Messages | `docs/screenshots/14_messages.png` |
| Profile | `docs/screenshots/15_profile.png` |
| Settings | `docs/screenshots/16_settings.png` |

---

## Screen Recordings (GIF)

> Run `bash scripts/capture.sh gif <screen_name>` to record a specific flow.
> Run `bash scripts/capture.sh gif all` to record all flows.

| Flow | File |
|------|------|
| Splash → Onboarding → Home | `docs/gifs/onboarding_flow.gif` |
| Create new task | `docs/gifs/new_task_flow.gif` |
| Task detail & edit | `docs/gifs/task_detail_flow.gif` |
| Dark mode toggle | `docs/gifs/dark_mode_flow.gif` |
| Project detail | `docs/gifs/project_detail_flow.gif` |
| Statistics | `docs/gifs/statistics_flow.gif` |
| Search | `docs/gifs/search_flow.gif` |
| Profile edit | `docs/gifs/profile_edit_flow.gif` |

---

## Features

### Splash & Onboarding
- Animated splash screen (scale + fade + slide) with `AppColors.primary` background
- Smart navigation: first launch → Onboarding, returning user → Home
- 3-slide onboarding with per-slide slide-in + fade animation
- Skip / Next / Get Started with `shared_preferences` flag persistence

### Home
- Greeting with current date
- Live task summary: Total / Done / Pending from `taskProvider`
- Today's task list from Riverpod state
- Quick add task FAB → `NewTaskPage`
- Bottom navigation (5 tabs)

### Schedule
- Day selector (Mon–Sun) with animated active indicator
- Task list filtered by selected day via `startTime`
- Mark task done toggle
- Swipe or tap to open `TaskDetailPage`

### New Task
- Full form: title, project selector, time pickers, priority, color, assignees, description
- Validation with `GlobalKey<FormState>`
- Calls `taskProvider.notifier.addTask()` on submit

### Task Detail
- Full task info: time range, project badge, members, tags, description
- Mark as done toggle (persisted to Hive)
- Edit button → `EditTaskPage`
- More (⋯) modal: share, delete

### Edit Task
- Pre-filled form from existing `TaskItem`
- `taskProvider.notifier.updateTask()` on save
- Full dark mode support

### Projects
- Grid of project cards with color, progress bar, member avatars, task count
- Live data from `projectsWithTaskCountProvider`
- Summary row: total projects, tasks, completion rate

### Project Detail
- `NestedScrollView` with `SliverAppBar` (project color header)
- Tasks tab: filter All / In Progress / Done via `isDone`
- Overview tab: description, deadline, member list
- More (⋯) modal: Edit / Share / Delete

### Search
- Real-time search across tasks and projects
- Sectioned results with task color indicators and project badges
- Empty state illustration

### Statistics
- Summary cards: Total / Completed / Pending (live from `taskProvider`)
- Bar chart: Week / Month / Year period selector
- Task breakdown: Done vs Pending percentage
- Productivity Score: calculated from real done/total ratio
- Top Projects: live from `projectsWithTaskCountProvider`, sorted by completedTasks

### Messages (Notifications)
- Filter tabs: All / Unread / Tasks / Projects
- Mark all as read
- Grouped by Today / Yesterday / N days ago
- Notification types: task, mention, project, reminder

### Profile
- Editable name & role via bottom sheet modal
- Auto-generated initials from name
- Stats: Completed / Ongoing / On-Time
- Settings card: notifications toggle, account links
- Logout with confirmation dialog

### Settings
- Theme dropdown: System / Light / Dark — connected to `ThemeProvider.setDark()`
- Language, notification, privacy, and account options
- About section with app version

### Dark Mode
- `ThemeProvider` (`InheritedWidget`) — no external library
- `AppTheme.light` / `AppTheme.dark` with full `ColorScheme`
- All screens use `Theme.of(context).colorScheme.*` — no hardcoded colors

### State Management (Riverpod)
- `taskProvider` — `StateNotifierProvider<TaskNotifier, TaskState>`
- `projectProvider` — `StateNotifierProvider<ProjectNotifier, ProjectState>`
- `projectsWithTaskCountProvider` — derived `Provider<List<ProjectItem>>`

### Local Storage (Hive)
- `TaskItemAdapter` (typeId 0) — manual `TypeAdapter`
- `ProjectItemAdapter` (typeId 1) — manual `TypeAdapter`
- `LocalStorageService` — static wrapper: init, load, save, delete
- Seed data on first launch if box empty
- Persist every mutation (add, update, delete)

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.44.9 (FVM) |
| Language | Dart 3.12 |
| State | flutter_riverpod ^2.6.1 |
| Storage | hive_flutter ^1.1.0 |
| Preferences | shared_preferences ^2.3.2 |
| Architecture | Feature-First (Level 2) |
| Theme | Custom `ThemeProvider` (InheritedWidget) |
| Fonts | Inter (via AppTextStyles) |

---

## Project Structure

```
lib/
├── app.dart                    # Route registration (14 routes)
├── main.dart                   # Async init: Hive + ProviderScope
├── core/
│   ├── constants/              # AppColors, AppTextStyles
│   ├── providers/              # taskProvider, projectProvider, themeProvider
│   ├── storage/                # LocalStorageService, TypeAdapters
│   ├── themes/                 # AppTheme.light / AppTheme.dark
│   └── widgets/                # EmptyState, FilterBottomSheet
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
