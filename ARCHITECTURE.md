# 🧠 Technical Documentation & AI Context (ARCHITECTURE.md)

This document provides a comprehensive architectural, structural, and operational overview of the **Expense Tracker** project. It is specifically structured to give developer-level insights and context to AI models, agentic workflows, and human contributors.

---

## 1. System High-Level Architecture

Expense Tracker is a **local-first, zero-telemetry, offline-by-design** mobile application built using **Flutter (Dart 3)**.

```text
[ Presentation Layer: Screens & Widgets ]
               │
               ▼
   [ Business Logic & Services ]
   ├── LocalizationService (ChangeNotifier)
   ├── BackupService (JSON serialization & system intents)
   ├── AdService (Google AdMob singleton lifecycle)
   └── DatabaseService (SQLite DAO with explicit connection lifecycle)
               │
               ▼
[ Persistence Layer: SQLite (expenses.db) & SharedPreferences ]
```

### Key Architectural Principles:
1. **Local-First & Data Sovereignty**: All records reside solely within a local SQLite database (`expenses.db`). No cloud storage or remote analytics endpoints exist.
2. **Explicit Resource Lifecycle**: All long-lived resources (database connections, ad objects, controllers, listeners) have strict disposal mechanisms to prevent native memory exhaustion and leakages.
3. **Reactive UI with Minimal Overhead**: State management relies primarily on `StatefulWidget` lifecycles and lightweight `ChangeNotifier` streams for global localization updates without heavyweight state frameworks.

---

## 2. Core Modules & Component Breakdown

### 2.1 Persistence Layer (`lib/services/database_service.dart`)
- **Engine**: SQLite via the `sqflite` plugin.
- **Pattern**: Singleton with lazy initialization.
- **Table Definition**:
  ```sql
  CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    amount REAL NOT NULL,
    category TEXT NOT NULL,
    date TEXT NOT NULL,
    notes TEXT
  );
  ```
- **Queries**:
  - `getAllTransactions()`: Retrieves all records sorted descending by ISO8601 date string.
  - `getMonthlyTransactions(int month, int year)`: Uses SQLite's native `strftime` functions (`strftime('%m', date)` and `strftime('%Y', date)`) directly on ISO8601 strings to perform efficient monthly aggregation.
  - `close()`: Idempotent connection termination to release native SQLite handles.

### 2.2 Domain Models (`lib/models/transaction.dart`)
- **`ExpenseTransaction`**:
  - `id`: Optional autoincrementing integer.
  - `title`: Short textual descriptor.
  - `amount`: Double precision numeric value.
  - `category`: Strongly-typed enum `TransactionCategory` (`food`, `transport`, `utilities`, `shopping`, `health`, `other`).
  - `date`: `DateTime` serialized to ISO8601 strings.
  - `notes`: Optional detailed note.
- Implements `toMap()`, `fromMap()`, and immutable `copyWith()` methods.

### 2.3 Localization & RTL (`lib/services/localization_service.dart`)
- Implements `ChangeNotifier`.
- Supports runtime toggling between Arabic (`ar_DZ`) and English (`en_US`).
- When Arabic is active, Flutter automatically switches directionality to **RTL** across all widgets, layouts, and input directions.
- Provides string lookup via simple key indexing: `translate(String key)`.

### 2.4 Monetization & Ad Subsystem
- **Package**: `google_mobile_ads: ^9.1.0`
- **Application ID (Android)**: Configured in `AndroidManifest.xml` via `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" ... />`.
- **Package Identifier**: `com.aggab.exptracker`.
- **`AdService` (`lib/services/ad_service.dart`)**:
  - Singleton managing Interstitial Ads.
  - Frequency control: shows interstitial ad on every $N$ operations (where $N = 4$ through `incrementTransactionCounter()`).
  - Safe disposal checks (`_isDisposed`).
- **`BannerAdWidget` (`lib/widgets/banner_ad.dart`)**:
  - Standalone `StatefulWidget` owning an isolated `BannerAd` instance.
  - **Never shares ad instances** across screens to avoid the Android platform error: `This AdWidget is already in the Widget tree`.
  - Centers ads horizontally (`Alignment.center`) across full device width.
  - Cleans up (`ad.dispose()`) on widget destruction.

### 2.5 Backup & Portability (`lib/services/backup_service.dart`)
- **Export**: Queries all transactions, maps to JSON, writes to app document storage (`path_provider`), and triggers system share sheet (`share_plus`).
- **Import**: Uses `file_picker` to read selected `.json` files, decodes maps into `ExpenseTransaction` instances, and executes batch insertions via SQLite.

---

## 3. UI & Presentation Screens

| File | Purpose & Architecture |
| :--- | :--- |
| `lib/screens/home_dashboard.dart` | Main dashboard displaying monthly spending, budget consumption bar, time progress in billing cycle, category horizontal scroll, recent 5 transactions, and banner ad. |
| `lib/screens/add_transaction_screen.dart` | Form interface for inputting amount, transaction title, date picker, category dropdown, and optional notes. Increments ad counter upon successful save. |
| `lib/screens/transactions_list_screen.dart` | Full searchable chronological list of expenses. Features swipe-to-delete (`Dismissible`), category chip filters, and live search. |
| `lib/screens/stats_screen.dart` | Visual analytics using `fl_chart.PieChart`. Displays category percentages and totals, with dynamic color-coded metrics. |
| `lib/screens/settings_screen.dart` | Configuration screen for setting custom budget billing cycle start date, exporting JSON backups, and importing backups. |

---

## 4. Build Configuration & Platform Details

- **Namespace / App ID**: `com.aggab.exptracker`
- **Android Gradle Plugin / Kotlin**: Kotlin DSL (`android/app/build.gradle.kts`) with Java 17 compatibility.
- **MultiDex**: Explicitly enabled (`multiDexEnabled = true` with `androidx.multidex:multidex:2.0.1`) to support Google Play Services without 64k method limit constraints.
- **R8 / Proguard Compatibility**: `android.enableR8.fullMode=false` set in `android/gradle.properties` to ensure dynamic JavaScript engine loading within Android System WebView for AdMob.

---

## 5. Guidelines for AI Assistants & Automated Tools

When generating or refactoring code in this project:

1. **Do Not Introduce Remote Network Calls**: Keep all financial computation strictly on-device.
2. **Respect Ad Lifecycle**: Never extract `BannerAd` instances into shared singletons or global state. Always maintain self-contained, lifecycle-managed state within `BannerAdWidget`.
3. **Database Date Parsing**: Dates are strictly stored as ISO8601 strings. Maintain SQLite date functions (`strftime('%m', date)`, etc.) when writing query filters.
4. **Bilingual Key Registration**: Whenever a new UI label is added, ensure its corresponding Arabic (`ar`) and English (`en`) keys are registered in `LocalizationService._strings`.
5. **Memory Safety**: Always implement `dispose()` methods on `StatefulWidget` states that instantiate controllers (`TextEditingController`, `AnimationController`) or listen to `LocalizationService`.
