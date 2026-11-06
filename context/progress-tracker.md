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
- [x] Tokens from DESIGN.md, theme, Manrope, Nunito and Source Code Pro bundled
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
- [x] Cart offers Cash or Utang directly; choosing Utang opens the customer picker (pick or add a customer)
- [x] Stock re-check before save, rules block negative stock
- [x] Sales history and detail
- [x] Refunds (restock or write-off) and cancel, with audit

### Phase 5: Dashboard, Utang, Expenses, Staff
- [x] Dashboard from `dailyStats`
- [x] Customers, ledger, payments, manual charges
- [x] Paid up button, paid-up archive with 1-month expiry and Restore, remove a name added by mistake
- [x] Optional name on cash sales
- [x] Expenses
- [x] Cashier accounts, enable/disable, audit log

### Phase 5b: Brand and Polish
- [x] HD vector logo; app icons and launch images generated from it
- [x] Animated loading page with a matching web and native pre-launch screen
- [x] Welcome, dashboard, More and shared panels refreshed; desktop browser column
- [x] Fixed dashboard 7-day chart overflow, wrapped "COUNT" header, and `StatRow` values not reaching the right edge

### Phase 5c: BudgetZen Redesign
- [x] Tokens, theme and shared widgets moved to the new `DESIGN.md` (no feature changes)
- [x] New logo; app icons, launch images and web pre-launch screen regenerated
- [x] Dark mode: More → Appearance (System, Light, Dark), saved on the phone
- [ ] Look through the signed-in screens on a phone, in light and dark (only Welcome, sign-in, loading and the shared widgets were checked by eye)

### Phase 6: Verification (open)
- [x] `flutter analyze` clean
- [x] `flutter test` green on a real SDK (62 tests, incl. a smoke test of the no-Firebase start-up path and the loading screen)
- [ ] Rules tests in the Firebase emulator (cashier limits, stock ≥ 0, 15+ item cart)
- [ ] Device test on a low-end Android phone (Android 8+, 2 GB RAM), including the new launch screen and adaptive icon
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
- Redesign (2026-11-05, owner's request): `DESIGN.md` is now BudgetZen, replacing the black, cream and aloe look. Features unchanged; the app keeps the name Tindahan. The older branding notes below describe the previous look. Status still uses icon + word, now on DESIGN.md's green, amber and red chips; red only for failed or blocked things, so refunds stay neutral and short cash at checkout is amber. Departures from DESIGN.md are listed in `ui-mapping.md`. White on mint (#10B981) is DESIGN.md's button spec and is followed as written, though its contrast is only about 2.5:1.
- Dark mode (2026-11-05, owner's request): follows the phone by default, because that is what people expect and light-phone users see no change. `DESIGN.md` has no dark theme, so the palette is derived from its stone greys (see `ui-mapping.md`). `AppColors` reads a swappable palette rather than `Theme.of(context)`, so screens stayed almost untouched and no package was added; the cost is that colours are no longer compile-time constants. Filipino labels (Itsura, Sistema, Maliwanag, Madilim) need native review.
- New logo (2026-11-05, owner gave free choice): rounded sari-sari store front, mint and sky awning, peso coin in the hatch. The coin lights up in the loading animation. The icon is white and sky on a mint tile. Money and quantity figures use Manrope because Nunito has no tabular figures.
- Branding (2026-11-03, owner's request): the Welcome screen uses the cream canvas like every other screen instead of DESIGN.md's black cinematic welcome. The owner's logo (`photo/logo.png`, navy/red/yellow) was recoloured to ink + aloe with a transparent background as `assets/images/logo.png` and shown top-left on Welcome via `AppLogo`. Start-up shows a branded loading screen (logo, spinner, "Opening the store…") for at least 1.5 s (`AuthGate.minSplash`), then fades to the next screen. Android launch background and web page background are cream to avoid a white flash.
- Logo and start-up (2026-11-05, owner's request for an HD logo and a better loading page): the raster logo is replaced by vector painters in `brand.dart`, redrawn from the same design with five awning stripes instead of six so both ends match. `tool/generate_brand_assets.dart` renders every Android, iOS and web icon and launch image from those painters, replacing the Flutter defaults; `assets/brand/` holds full-size exports and is not bundled. App icon is ink and white on an aloe tile, because aloe stripes vanish on aloe. Loading page: the store opens (pale awning fills in stripe by stripe, lights come on, name appears, 1.3 s, shown complete at once when animations are off). `web/index.html` and the native launch images show the same closed store in the same place, so the hand-over is not visible; keep those numbers in step with `SplashScreen`.
- Awning band added as the brand's one decorative shape (`AwningPanel`), on Welcome and the dashboard hero only. DESIGN.md does not define it; it comes from the logo. It replaces the featured card there, using the same aloe fill.
- `AppViewport` keeps the app in a 560 px column in wide browser windows rather than building a separate desktop layout: this is a phone app and the web build is for testing.
- English is the default language (changed 2026-11-03, was Taglish); Filipino (Taglish) stays selectable under More → Language and on the welcome screen. A saved choice of Filipino is kept.
- Export is CSV with UTF-8 BOM (opens in Excel) rather than native `.xlsx`.
- Cashiers created through a secondary FirebaseApp so the owner stays signed in.
- Utang from the cart (2026-11-06, owner's request): the cart's Pay button became Cash and Utang buttons, so credit sales go through checkout and count in sales, stock and daily stats. The checkout, ledger and rules were already correct, so only the UI changed. Manual "Add utang" on the customer screen is kept until the owner decides, because it is the only way to enter old notebook debts.
- Utang archive (2026-11-06, owner's request): Paid up records any balance left as a payment and archives the customer in one batch. The archive lists them until one calendar month later (`archiveRemovalDate`), checked when the list is drawn, so no server job is needed. "Removed" means hidden: the customer, ledger and sales stay in Firestore, because the rules forbid deleting customers and sales still point at them. A customer with a non-zero balance stays listed past the month. After the month a returning customer is added as a new name.
- Remove name (2026-11-06, owner's request): offered only with ₱0 balance and no ledger entries, and sets `removed: true` rather than deleting, so no rules change or deploy was needed. Cashiers can use Paid up and Remove, as they can already record payments.
- Cash sales may carry an optional name in `customerName` with no `customerId`, so it never touches a utang balance.
- Screen fades use `ScreenSwitcher` in `app.dart`, not a bare `AnimatedSwitcher`: signing in passes through two unkeyed screens into keyed `HomeShell` within the fade, which threw "Duplicate keys found". Each screen change now gets its own key (`test/screen_switcher_test.dart`).
- Welcome headline is "Busssssseng" in both languages (2026-11-06, owner's request).
- Expense category is typed by hand (2026-11-06, owner's request), required, stored as text. Older expenses keep their enum names and still show translated through `expenseCategoryLabelByName`.
- Dashboard and More polish (2026-11-06, owner request): all four dashboard tiles open a page (profit and transactions go to Sales, as there is no separate profit page); the Sales date opens a calendar; the Summary header shows the store name and the More header shows the member name instead of the words Today and More.
- A new store opens only once the server has confirmed the membership (`hasPendingWrites`), or after `serverWait` when offline. Starting earlier made every store listener fail with permission denied until Try again.
- Email confirmation (2026-11-06, owner request): nothing can tell whether an email exists, so new email-and-password sign-ups must open a Firebase link before they can create a store (`NeedsEmailVerification`). The check sits at store creation only, so existing owners and cashiers, whose emails the owner typed in, are never locked out. Google logins arrive confirmed. `firestore.rules` also requires `email_verified` to create a store.
- My account (2026-11-06, owner request): anyone can edit their own name, and owners can edit the store name. Past sales keep the name they were made under. `firestore.rules` lets a member change only their own `displayName`; `Actor.name` updates live so new records use the new name.
- Google sign-in uses `FirebaseAuth.signInWithProvider(GoogleAuthProvider())` (Firebase's browser flow), not the `google_sign_in` package: no new dependency. Needs the Google provider on in the console, the Android SHA-1/SHA-256 registered (debug key done; add the release key before publishing) and the iOS encoded-App-ID URL scheme in `Info.plist` (done). Cashiers still sign in with the email and password the owner set.
- Web added for testing in Chrome (`flutter run -d chrome`): Firebase web app registered, Google sign-in uses `signInWithPopup` on web, CSV export shares in-memory data (`XFile.fromData`) so it works on phones and downloads in the browser; `path_provider` removed.
- **Iba pa → Aking account** (owners and cashiers): name, email, sign-in method (Google / email and password), role, store. Email-and-password logins can change their password after re-entering the current one (`reauthenticateWithCredential` then `updatePassword`), or send a reset email. Google-only logins see a note that their password is managed by Google. Passwords are never shown: Firebase keeps only a one-way hash.
- Replaced the `flutter create` template `widget_test.dart` with `test/app_smoke_test.dart`, which boots `TindahanApp` with a start-up error (no Firebase needed).
- Android `minSdk` left at `flutter.minSdkVersion` (the Flutter 3.44 default already meets firebase_auth's 23). App label is "Tindahan" on Android and iOS.

## Open Questions


- Should cost fields move to an owner-only subcollection so cashiers cannot read them through the API?
- Add camera barcode scanning (e.g. `mobile_scanner`)?
- Bluetooth receipt printing?
- Track GCash/Maya payments separately from cash?

## Filipino Strings Needing Native Review

All of `lib/core/l10n/strings_fil.dart`. Priority: error messages, refund and cancel confirmations, cashier-creation instructions.
