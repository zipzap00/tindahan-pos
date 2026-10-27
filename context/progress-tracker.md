# Progress Tracker

## Current Status

**Phase:** Connected to Firebase project `tindahan-pos-b57e2` (Firestore `asia-southeast1`, Email/Password auth on, rules and indexes deployed).
**Next step:** Run on a phone and sign up as owner; then rules tests in the emulator and device testing.

## How to Update

Tick an item when it is merged and `flutter analyze` and `flutter test` pass. Add a line under **Decisions Made** whenever you choose between two reasonable options. Keep **Open Questions** short: move an item to Decisions once it is answered.

## Pinned Versions (verified 2026-10-27, Flutter 3.44.6 / Dart 3.12.2)

| Package | Constraint | Note |
|---|---|---|
| Flutter | ≥ 3.29.0 | `DialogThemeData`, `WidgetState` |
| Dart | ^3.7.0 | No null-aware map elements (needs 3.8) |
| firebase_core | ^4.0.0 | resolved 4.15.2 |
| cloud_firestore | ^6.0.0 | resolved 6.10.2; exports its own `Type`, so `app.dart` imports it with `show` |
| firebase_auth | ^6.0.0 | resolved 6.7.1 |
| shared_preferences | ^2.3.0 | Language choice |
| path_provider | ^2.1.5 | CSV temp file |
| share_plus | ^11.0.0 | `SharePlus.instance.share(ShareParams(...))` |
| flutter_lints | ^5.0.0 | |

share_plus resolved 11.1.0. Newer majors exist (firebase_core 5, cloud_firestore 7, firebase_auth 7, share_plus 13); staying on the pinned majors until the app runs against Firebase, then upgrade as a separate task.

## Progress

### Phase 0: Foundation
- [x] Project structure, pubspec, lints
- [x] Money in centavos, Manila time, `Result<T>`, logging
- [x] Taglish + English strings (390 keys), language switch
- [x] `flutter create` (android, ios; org `ph.tindahan`), first successful build (`flutter build apk --debug`)
- [x] `flutterfire configure` (Android `ph.tindahan.tindahan_pos`, iOS `ph.tindahan.tindahanPos`), `.firebaserc` default project, `firebase deploy --only firestore`

### Phase 1: Design System
- [x] Tokens from DESIGN.md, theme, Inter bundled
- [x] Shared widgets: buttons, cards, tags, inputs, layout, states, dialogs

### Phase 2: Auth and Store
- [x] Welcome, sign in, sign up, create store
- [x] Session controller and scopes
- [x] Access disabled and start-up error screens

### Phase 3: Inventory
- [x] Product list with filters, search, sort, value summary
- [x] Product form with total / per-piece cost and live capital and income
- [x] Product detail, archive and restore
- [x] Restock (weighted average) and adjust with reasons
- [x] Movement history per product and store-wide
- [x] CSV export of inventory and movements

### Phase 4: POS and Sales
- [x] Product grid, search, exact-code add
- [x] Cart with stock limits, checkout (cash and utang), receipt
- [x] Stock re-check before save, rules block negative stock
- [x] Sales history and detail
- [x] Refunds (restock or write-off) and cancel, with audit

### Phase 5: Dashboard, Utang, Expenses, Staff
- [x] Dashboard from `dailyStats`
- [x] Customers, ledger, payments, manual charges
- [x] Expenses
- [x] Cashier accounts, enable/disable, audit log

### Phase 6: Verification (open)
- [x] `flutter analyze` clean
- [x] `flutter test` green on a real SDK (39 tests, incl. a smoke test of the no-Firebase start-up path)
- [ ] Rules tests in the Firebase emulator (cashier limits, stock ≥ 0, 15+ item cart)
- [ ] Device test on a low-end Android phone (Android 8+, 2 GB RAM)
- [ ] Offline test: sell with airplane mode on, then reconnect
- [ ] Native review of Filipino strings

## Decisions Made

- No state-management or code-generation packages; ChangeNotifier + InheritedWidget is enough for one store.
- Money stored in centavos; unit cost kept as a fractional double so "₱100 for 12" stays exact.
- Restock uses weighted-average cost.
- Write-off refunds reverse full price from profit; restocked refunds reverse price − cost.
- Cancel only allowed on sales with no refunds, to keep the arithmetic simple and auditable.
- Refund and cancel adjust the **original sale day's** stats, so past days stay correct.
- Dashboard reads aggregated `dailyStats`, not raw sales.
- No red or amber anywhere: DESIGN.md has none. Status uses icon + word.
- Taglish is the default language.
- Export is CSV with UTF-8 BOM (opens in Excel) rather than native `.xlsx`.
- Cashiers created through a secondary FirebaseApp so the owner stays signed in.
- Google sign-in uses `FirebaseAuth.signInWithProvider(GoogleAuthProvider())` (Firebase's browser flow), not the `google_sign_in` package: no new dependency. Needs the Google provider on in the console, the Android SHA-1/SHA-256 registered (debug key done; add the release key before publishing) and the iOS encoded-App-ID URL scheme in `Info.plist` (done). Cashiers still sign in with the email and password the owner set.
- Web added for testing in Chrome (`flutter run -d chrome`): Firebase web app registered, Google sign-in uses `signInWithPopup` on web, CSV export shares in-memory data (`XFile.fromData`) so it works on phones and downloads in the browser; `path_provider` removed.
- Replaced the `flutter create` template `widget_test.dart` with `test/app_smoke_test.dart`, which boots `TindahanApp` with a start-up error (no Firebase needed).
- Android `minSdk` left at `flutter.minSdkVersion` (the Flutter 3.44 default already meets firebase_auth's 23). App label is "Tindahan" on Android and iOS.

## Open Questions

- Should cost fields move to an owner-only subcollection so cashiers cannot read them through the API?
- Add camera barcode scanning (e.g. `mobile_scanner`)?
- Bluetooth receipt printing?
- Track GCash/Maya payments separately from cash?

## Filipino Strings Needing Native Review

All of `lib/core/l10n/strings_fil.dart`. Priority: error messages, refund and cancel confirmations, cashier-creation instructions.
