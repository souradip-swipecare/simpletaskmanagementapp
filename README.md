# taskmanagementsouradip

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---


## Firebase Setup & Initialization

This project uses Firebase Authentication and Firestore for user management and data storage. To get started, follow these steps:

1. **Install FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase:**
   From the project root, run:
   ```bash
   flutterfire configure
   ```
   This will generate `lib/firebase_options.dart` and register your Android/iOS apps with Firebase.

3. **Add Platform Files:**
   - For Android: Place your `google-services.json` in `android/app/`.
   - For iOS: Place your `GoogleService-Info.plist` in `ios/Runner/`.
   - Template files are available at `android/app/google-services.json.template` and `ios/GoogleService-Info.plist.template`.

4. **Install dependencies and run:**
   ```bash
   flutter pub get
   flutter run
   ```

**Note:**
If you use your own Firebase project, make sure to enable Email/Password and Google sign-in providers in the Firebase console.

---

## Authentication & Role-based Task Permissions

The app supports two user roles:

- **Admin:**
  - Can create new tasks.
  - Can update any task.
  - Has access to user management features.

- **Member:**
  - Can view and update existing tasks assigned to them.
  - Cannot create new tasks.

**Login Flow:**
- Users can log in using Google Sign-In or as a local guest (for testing).
- After login, the app determines the user's role and adjusts available features accordingly.

---

## Current Screens Overview

- **Login Screen:**
  - Allows users to sign in with Google or as a guest.
  - Displays authentication errors if sign-in fails.

- **Task List Screen:**
  - Shows a list of tasks from Firestore (with offline support).
  - Admins see a button to create new tasks.
  - Members can only update tasks assigned to them.

- **Task Details/Edit Screen:**
  - Allows editing of task details.
  - Only admins can create new tasks; members can update but not create.

- **Check-in Screen:**
  - Users can check in for tasks (offline-first, syncs when online).

- **User Management (Admin only):**
  - Admins can manage user roles and permissions.

---

## Local Data & Sync

- Local persistence uses Hive boxes: `tasks`, `checkins`, `users`, `session`.
- Check-ins are created locally first with `syncStatus = pending` and stored in Hive. A background sync service uploads pending items when online and marks them as `synced` or `failed`.
- Conflict policy: **client-wins** for check-ins. For tasks, last-write-wins is used unless otherwise specified.

---



- Complete offline-first sync for check-ins.
- Implement full CRUD for tasks.
- Finalize role-based authorization.
- Add form validation and comprehensive tests.

If you have a different priority, please let me know.

### Offline & Sync (current plan)

- Local persistence uses Hive boxes: `tasks`, `checkins`, `users`, `session`.
- Check-ins are created locally first with `syncStatus` = `pending` and stored in Hive. A background sync service (in `lib/data/sync/checkin_sync_service.dart`) uploads pending items when online and marks them `synced` or `failed`.
- Conflict policy: **client-wins** for check-ins. For tasks we will implement last-write-wins unless you prefer a different policy.



