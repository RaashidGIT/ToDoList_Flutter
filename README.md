# Production-Ready Flutter To-Do & Task Manager

A modern, responsive To-Do application built with Flutter, Material 3, and Flutter Riverpod (`AsyncNotifier`). Demonstrates clean architectural patterns, robust local and remote state management, optimistic UI updates with automatic rollback, and resilient network error handling.

---

## Features

* **Modern State Architecture**: Employs Riverpod 2.x `AsyncNotifier` to handle asynchronous operations (`AsyncLoading`, `AsyncData`, `AsyncError`) and derived computed state.
* **REST API CRUD Integration**: Full remote data synchronization via **Dio** against a REST endpoint (MockAPI / JSONPlaceholder).
* **Optimistic UI with Failure Rollback**: Toggle completion and swipe-to-delete update UI instantly, rolling back to previous state if the remote request fails.
* **Undo Pattern**: Non-blocking `SnackBar` action that restores tasks locally and synchronizes re-creation back to the server without stale closure leaks.
* **Granular Filtering & Live Search**:
* Filter by **All**, **Active**, and **Done** with dynamic count badges via `SegmentedButton`.
* Real-time search bar integrated into the `AppBar`.
* Multi-condition derived provider caching query results.


* **Task Metadata**:
* Date and time scheduling via combined `showDatePicker` and `showTimePicker`.
* Visual category badges (**Work**, **Personal**, **Study**) styled using `ChoiceChip` widgets.
* Overdue indicators for pending tasks past their target deadline.


* **Modular UI Architecture**: Split into atomic, reusable widgets (`TodoItemCard`, `TodoFilterBar`, `TodoErrorView`, `AddTodoDialog`).

---

## Tech Stack & Architecture

| Layer | Technology |
| --- | --- |
| **Framework** | Flutter (Dart 3, Material 3) |
| **State Management** | Flutter Riverpod (`AsyncNotifier`, `Provider`, `StateProvider`) |
| **Networking** | Dio (Timeouts, Custom Headers, Typed Exceptions) |
| **Persistence (Optional Layer)** | Hive (`hive_flutter`) |
| **Date Formatting** | `intl` |

```text
lib/
├── models/
│   └── todo_item.dart          # Domain model, Category enum, JSON mapping
├── providers/
│   └── todo_provider.dart      # AsyncNotifier, derived filter & stats providers
├── services/
│   └── todo_api_service.dart   # Dio HTTP client encapsulating REST operations
├── screens/
│   ├── todo_list_screen.dart   # Screen orchestrator & scaffold
│   └── widgets/
│       ├── add_todo_dialog.dart  # Modal dialog with DateTime pickers & chips
│       ├── todo_error_view.dart  # Error screen with retry triggers
│       ├── todo_filter_bar.dart  # Full-width SegmentedButton with live stats
│       └── todo_item_card.dart   # Dismissible task card with status toggling
└── main.dart                   # Application bootstrap & ProviderScope

```

---

## Getting Started

### Prerequisites

* Flutter SDK (`^3.19.0` or later)
* Dart SDK (`^3.3.0` or later)
* Android Studio / VS Code with Flutter extension
* An active emulator or physical device

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/flutter-todo-riverpod.git
cd flutter-todo-riverpod

```


2. Install dependencies:
```bash
flutter pub get

```


3. Configure your API endpoint:
Open `lib/services/todo_api_service.dart` and set `_baseUrl` to your MockAPI or JSONPlaceholder instance:
```dart
static const String _baseUrl = 'https://YOUR_PROJECT_ID.mockapi.io/api/v1';

```


4. Run the application:
```bash
flutter run

```



---

## Engineering Highlights & Key Patterns

* **Safe State Access (`valueOrNull`)**: Prevents runtime widget crashes during network failures by reading `state.valueOrNull` in derived providers rather than asserting `.value` on an `AsyncError`.
* **Disposed Context Protection**: Resolves Riverpod notifiers prior to widget unmounting inside `Dismissible.onDismissed`, preventing `Cannot use "ref" after the widget was disposed` runtime exceptions.
* **Zero Layout Jitter**: Prevents size fluctuations in `SegmentedButton` by locking container constraints (`width: double.infinity`) and setting `showSelectedIcon: false`.

---

## License

Distributed under the MIT License. See `LICENSE` for details.
