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
    ├── schedule/                     # Halaman jadwal utama
    │   ├── domain/models/
    │   │   └── task_item.dart
    │   └── presentation/
    │       ├── pages/schedule_page.dart
    │       └── widgets/
    │           ├── day_selector.dart
    │           ├── timeline_list.dart
    │           ├── task_card.dart
    │           └── schedule_bottom_nav.dart
    ├── new_task/                     # Form buat task baru
    │   ├── domain/models/
    │   │   └── task_form_data.dart
    │   └── presentation/
    │       └── pages/new_task_page.dart
    └── profile/                      # Halaman profil user
        └── presentation/
            └── pages/profile_page.dart

docs/
└── wireframes/                       # Wireframe JSON source
    ├── schedule-timeline-scroll.json
    ├── new-task-form.json
    └── profile-stats-card.json
```

## Screens

| Screen | Route | Wireframe |
|---|---|---|
| Schedule Timeline | `/` | `schedule-timeline-scroll` |
| New Task Form | `/new-task` | `new-task-form` |
| Profile | `/profile` | `profile-stats-card` |

## Roadmap

### Phase 1 — Foundation ✅
- [x] Setup Flutter 3.44.9 via FVM
- [x] Feature-first folder structure
- [x] Core design system (colors, typography, theme)
- [x] Schedule timeline screen
- [x] New task form screen
- [x] Profile stats screen
- [x] Floating bottom navigation

### Phase 2 — State Management 🔲
- [ ] Integrasi state management (Riverpod / Bloc)
- [ ] TaskProvider untuk CRUD task
- [ ] Filter task berdasarkan tanggal
- [ ] Validasi form dengan feedback

### Phase 3 — Local Storage 🔲
- [ ] Setup sqflite / Hive untuk persistensi data
- [ ] Repository pattern untuk data layer
- [ ] Offline-first support

### Phase 4 — Navigation & UX 🔲
- [ ] Setup go_router untuk deep linking
- [ ] Animasi transisi antar halaman
- [ ] Pull to refresh di timeline
- [ ] Search & filter tasks

### Phase 5 — Polish & Release 🔲
- [ ] App icon & splash screen
- [ ] Dark mode support
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

# Jalankan app
fvm flutter run
```

## VS Code

Project sudah dikonfigurasi untuk FVM. SDK path otomatis ter-set ke `.fvm/flutter_sdk`.

Pastikan ekstensi **Dart** dan **Flutter** ter-install di VS Code.
