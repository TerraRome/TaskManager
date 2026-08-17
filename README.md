# Task Manager

Aplikasi manajemen tugas mobile berbasis Flutter dengan tampilan schedule timeline, form pembuatan task, dan profile screen.

## Tech Stack

- **Flutter** 3.44.9 (via FVM)
- **Dart** 3.12.2
- **Architecture** Feature-First (Level 2)

## Struktur Project

```
lib/
├── app.dart                          # Root app & routing
├── main.dart                         # Entry point
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Semua warna aplikasi
│   │   └── app_text_styles.dart      # Typography styles
│   └── themes/
│       └── app_theme.dart            # MaterialApp theme
└── features/
    ├── home/                         # Dashboard utama
    │   └── presentation/
    │       ├── pages/home_page.dart
    │       └── widgets/
    │           ├── stat_card.dart
    │           └── home_task_card.dart
    ├── schedule/                     # Halaman jadwal
    │   ├── domain/models/task_item.dart
    │   └── presentation/
    │       ├── pages/schedule_page.dart
    │       └── widgets/
    │           ├── day_selector.dart
    │           ├── timeline_list.dart
    │           ├── task_card.dart
    │           └── schedule_bottom_nav.dart
    ├── new_task/                     # Form buat task baru
    │   ├── domain/models/task_form_data.dart
    │   └── presentation/
    │       └── pages/new_task_page.dart
    ├── task_detail/                  # Detail task
    │   └── presentation/
    │       └── pages/task_detail_page.dart
    ├── projects/                     # Daftar project
    │   ├── domain/models/project_item.dart
    │   └── presentation/
    │       ├── pages/projects_page.dart
    │       └── widgets/project_card.dart
    └── profile/                      # Profil user
        └── presentation/
            └── pages/profile_page.dart

docs/
└── wireframes/                       # Wireframe JSON source
    ├── schedule-timeline-scroll.json
    ├── new-task-form.json
    └── profile-stats-card.json
```

## Screens

| Screen | Route | Status |
|---|---|---|
| Splash | `/splash` | ✅ |
| Onboarding | `/onboarding` | ✅ |
| Home Dashboard | `/` | ✅ |
| Schedule Timeline | `/schedule` | ✅ |
| New Task Form | `/new-task` | ✅ |
| Task Detail | `/task-detail` | ✅ |
| Edit Task | `/edit-task` | ✅ |
| Projects | `/projects` | ✅ |
| Project Detail | `/project-detail` | ✅ |
| Messages | `/messages` | ✅ |
| Profile | `/profile` | ✅ |
| Search | `/search` | ✅ |
| Settings | `/settings` | ✅ |
| Statistics | `/statistics` | ✅ |

## Roadmap

### Phase 1 — Foundation ✅
- [x] Setup Flutter 3.44.9 via FVM
- [x] Feature-first folder structure
- [x] Core design system (colors, typography, theme)
- [x] Schedule timeline screen dengan expandable task cards
- [x] New task form screen (title, project, time, color, assignees)
- [x] Profile stats screen (avatar, stats, settings toggles)
- [x] Floating bottom navigation (5 tabs)

### Phase 2 — More Screens ✅
- [x] Home dashboard (greeting, stats, progress, today's tasks)
- [x] Task Detail page (hero card, members, tags, description)
- [x] Projects page (list, filter, progress bar per project)
- [x] Navigasi terhubung antar semua screen
- [x] VS Code launch.json (Android + macOS config)

### Phase 3 — Remaining Screens ✅
- [x] Messages/Notifications page
- [x] Edit Task page (form pre-filled dari task detail)
- [x] Splash screen & Onboarding (3-step walkthrough)
- [x] Dark mode (ThemeProvider + AppTheme.dark)
- [x] Search page (global search tasks & projects)
- [x] Project Detail page (tabs: tasks & overview)
- [x] Settings page (appearance, notifications, account)
- [x] Fix navigasi: Profile → Settings, Projects card → Project Detail, Task Detail Edit button → Edit Task, Search icon → Search page

### Phase 4 — UI Polish ✅
- [x] Statistics/Analytics page (bar chart, breakdown, productivity score)
- [x] EmptyState widget reusable (noTasks, noProjects, noResults, noMessages)
- [x] FilterBottomSheet widget reusable (sort, status, color, priority)
- [x] Filter button di Schedule & Projects page
- [x] ProfilePage logout dialog & navigate ke /splash
- [x] EmptyState terpasang di SearchPage, MessagesPage, ProjectsPage

### Phase 5 — Audit Fixes ✅
- [x] TaskDetailPage dark mode (AppColors.surface → cs.surface, AppColors.textPrimary → cs.onSurface)
- [x] TaskDetailPage more button (⋯) connected to modal bottom sheet (Edit, Share, Delete)
- [x] ProfilePage dark mode (_buildProfileCard, _buildStat, _buildStatDivider, _buildSettingsCard use cs.surface/cs.onSurface)
- [x] SchedulePage back button fixed (Navigator.pop / fallback to /)
- [x] NewTaskPage back button dark mode fix (cs.surface / cs.onSurface)
- [x] flutter analyze — no issues

### Phase 6 — State Management ✅
- [x] Integrasi Riverpod (`flutter_riverpod: ^2.6.1`) — `ProviderScope` di `main.dart`
- [x] `TaskProvider` — CRUD task, toggleDone, filter by status/color, search, stats (total/done/pending)
- [x] `ProjectProvider` — CRUD project, `projectsWithTaskCountProvider` (live task count per project)
- [x] `HomePage` — live stats & task list dari `taskProvider`
- [x] `SchedulePage` — tasks per tanggal dari `taskProvider`, filter status/color/sort
- [x] `NewTaskPage` — `addTask` via `taskProvider.notifier`
- [x] `TaskDetailPage` — live task, `toggleDone`, `deleteTask`
- [x] `ProjectsPage` — live project list dari `projectsWithTaskCountProvider`
- [x] `SearchPage` — search tasks & projects dari provider (real-time)
- [x] `StatisticsPage` — live total/done/pending dari `taskProvider`
- [x] `flutter analyze` — no issues

### Phase 7 — Local Storage ✅
- [x] `hive_flutter: ^1.1.0` ditambahkan ke dependencies
- [x] `TaskItemAdapter` (typeId 0) — manual TypeAdapter dengan field nullable, Color sebagai ARGB32, DateTime sebagai milliseconds
- [x] `ProjectItemAdapter` (typeId 1) — manual TypeAdapter
- [x] `LocalStorageService` — static wrapper untuk init, loadTasks, saveTask, deleteTask, saveAllTasks, loadProjects, saveProject, deleteProject, saveAllProjects
- [x] `TaskNotifier` — load dari Hive saat init, seed sample data jika box kosong (first launch), persist setiap mutasi (add/update/delete/toggle)
- [x] `ProjectNotifier` — load dari Hive saat init, seed sample data jika box kosong, persist setiap mutasi
- [x] `main.dart` — `async main()`, `WidgetsFlutterBinding.ensureInitialized()`, `LocalStorageService.init()` sebelum `runApp`
- [x] `flutter analyze` — no issues

### Phase 8 — Bug Fixes & Polish ✅
- [x] `EditTaskPage` — diubah ke `ConsumerStatefulWidget`, `_submit()` langsung memanggil `taskProvider.notifier.updateTask()`, dark mode fix (`AppColors.surface/textSecondary` → `cs.*`)
- [x] `ProjectDetailPage` — diubah ke `ConsumerStatefulWidget`, tasks baca dari `taskProvider` filter by `projectId`, filter In Progress/Done pakai `isDone`, tombol ⋯ connect ke modal (Edit/Share/Delete)
- [x] `SettingsPage` — Theme dropdown (System/Light/Dark) connect ke `ThemeProvider.setDark()`
- [x] `flutter analyze` — no issues

### Phase 9 — Polish & Real Data ✅
- [x] `MessagesPage` — dark mode fix `_buildHeader()` + `_buildFilterRow()` (`AppColors.surface/textSecondary` → `cs.*`), filter tabs (All/Unread/Tasks/Projects) sudah fungsional
- [x] `ProfilePage` — edit profile modal (tap avatar), nama & jabatan editable, initials auto-generated dari nama, dark mode `_buildLinkRow` arrow icon
- [x] `StatisticsPage` — `_buildTopProjectsCard()` dari `projectsWithTaskCountProvider` (live data), `_buildProductivityCard()` score dari done/total real, hapus `_ProjectStat` dummy class
- [x] `flutter analyze` — no issues

### Phase 10 — Onboarding & Splash ✅
- [x] `shared_preferences: ^2.3.2` ditambahkan ke `pubspec.yaml`
- [x] `SplashPage` — navigasi cerdas: cek flag `onboarding_done` di SharedPreferences, arahkan ke `/onboarding` (pertama kali) atau `/` (sudah pernah)
- [x] `OnboardingPage` — slide-in + fade animation per halaman (via `AnimationController` per slide), simpan flag `onboarding_done` saat "Get Started" atau "Skip", tombol Next/Get Started dinamis
- [x] `flutter analyze` — no issues

### Phase 11 — Next Steps 🔲
- [ ] Unit & widget tests
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Release build (APK / IPA)Migrasi ke go_router untuk deep linking
- [ ] Animasi transisi antar halaman
- [ ] Pull to refresh

### Phase 8 — Polish & Release 🔲
- [ ] App icon & splash screen asset
- [ ] Internasionalisasi (id/en)
- [ ] Unit & widget tests
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Release build (APK / IPA)

## Setup

```bash
# Clone repo
git clone https://github.com/TerraRome/TaskManager.git
cd TaskManager

# Install FVM (jika belum)
brew install fvm

# Use Flutter versi project
fvm use

# Install dependencies
fvm flutter pub get

# Jalankan app (Android emulator)
fvm flutter run -d emulator-5554 --no-enable-impeller

# Jalankan app (macOS)
fvm flutter run -d macos
```

## VS Code

Project sudah dikonfigurasi untuk FVM dan memiliki 2 launch config:
- **Flutter (Android - No Impeller)** — untuk Android emulator API 36+
- **Flutter (macOS)** — untuk macOS desktop

Tekan `F5` untuk langsung run tanpa perlu ketik command.

> **Note:** Flag `--no-enable-impeller` diperlukan untuk Android emulator API 36 (Android 16) karena ada issue koneksi debug service dengan Impeller renderer.
