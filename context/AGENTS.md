# AGENTS.md

Instructions for any AI coding agent (and any new team member) working on Tindahan POS. Read this file first, every session.

## Do Not Assume You Know This Stack

Flutter and the FlutterFire packages change their APIs between major versions. Check `pubspec.lock` for the installed versions and read the changelog of any package before using an API you remember from training. The versions in `pubspec.yaml` were chosen without access to pub.dev and are planning references until `flutter pub get` succeeds.

This project uses **no state-management package** (no Provider, Riverpod, Bloc or GetX) and **no code generation** (no freezed, json_serializable or build_runner). Do not add them.

## What Tindahan POS Is

A phone app for one sari-sari store: POS, inventory, daily sales, utang and expenses, with an owner and optional cashiers. Firebase Auth and Firestore are the whole back end; security rules enforce the business rules that must never be broken (stock never below zero, cashiers never edit products). See `project-overview.md`.

## Read Order

1. `AGENTS.md` (this file)
2. `project-overview.md`: what the app does and for whom
3. `architecture.md`: layers, data model, write paths
4. `ui-mapping.md` and `../DESIGN.md`: how the design source maps to Flutter
5. `progress-tracker.md`: what is done, what is open

When two files disagree: `DESIGN.md` wins on visual properties, `firestore.rules` wins on data permissions, this file wins on process.

## Session Workflow

1. Read `progress-tracker.md` and pick the next open item.
2. Run `flutter analyze` and `flutter test` before touching code, so you know the starting state.
3. Make the change in the right layer (see Golden Rules).
4. Add or update a unit test for any change in `lib/core` or `lib/domain`.
5. Run `flutter analyze` and `flutter test` again.
6. Update `progress-tracker.md`: tick the item, record any decision.

## Golden Rules

### Money and time
- Money is **centavos**. Selling prices are `int`; unit cost is `double` because "₱100 for 12 pieces" is 833.33 centavos each. Never store pesos as `double`.
- Format with `formatPeso` / `formatPesoCompact`; parse with `parsePesoToCents`. Never build `₱` strings by hand.
- All dates go through `ManilaTime` (UTC+8, no DST). Day keys are `YYYY-MM-DD`, weeks start on Monday. Never call `DateTime.now()` directly; use `ManilaTime.now()` so tests can inject a clock.

### Data
- Every write that touches stock, money or balances is **one `WriteBatch`** that also writes the stock movement, the `dailyStats` increment and the audit entry. Never update stock alone.
- Stock changes use `FieldValue.increment`, never read-modify-write.
- Repositories return `Result<T>`; they never throw to the UI. Log with a `[file/function]` context string.
- `commitBatch` returns `Ok(false)` when the write was queued offline. Screens must tell the user it will sync later, not show an error.

### Roles
- Cashiers never see cost, capital, profit or income anywhere in the UI, never edit or archive products, never refund or cancel. Check `member.isOwner` before showing those.
- Any new collection needs a rule in `firestore.rules` before the app writes to it.

### UI
- Use the tokens in `lib/core/theme/tokens.dart` and the shared widgets in `lib/ui/widgets/`. Never hard-code a colour, radius, font size or shadow in a screen.
- `DESIGN.md` has no red or amber. Status is shown with an icon **and** a word, on aloe, shade or ink pills.
- Every user-facing string goes in the translation generator (`Strings`, `FilStrings`, `EnStrings`) and is read with `context.s`. Taglish is the default.
- Every screen handles loading, empty and error states with the widgets in `states.dart`.
- Touch targets are at least 48 px (`AppSpace.minTouch`).

## Repository Map

```
lib/core/        money, manila_time, result, log, theme/, l10n/
lib/data/        models/, repositories/, session_controller, store_session, live_query, firestore_*
lib/domain/      pricing, cart, inventory, dashboard_summary, csv_export (pure Dart, tested)
lib/ui/          scopes, shell/, widgets/, screens/<area>/
test/            unit tests for core and domain
firestore.rules, firestore.indexes.json, firebase.json
```

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
firebase emulators:start --only firestore,auth   # test rules locally
firebase deploy --only firestore                 # rules + indexes
```

## When Unsure

Ask the owner rather than guess on anything that changes money, stock or who can see what. For everything else, follow the nearest existing screen and record the decision in `progress-tracker.md`.
