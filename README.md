# Tindahan POS

A Flutter + Firebase app for running a sari-sari store from one phone: point of sale, inventory, daily sales, utang (credit) and expenses. Money is in Philippine pesos (₱) and every date follows Philippine time (Asia/Manila, UTC+8). The app speaks Taglish by default and can switch to English.

> **Status:** Compiles on Flutter 3.44.6, `flutter analyze` is clean, `flutter test` passes and a debug APK builds. It is connected to Firebase project `tindahan-pos-b57e2`, with rules and indexes deployed. See [Known gaps](#known-gaps).

---

## What it does

| Area | Features |
|---|---|
| **Dashboard** (owner) | Today's sales, estimated profit, transactions and expenses · products in stock, low stock, out of stock · best sellers this month · recent transactions · today / this week / this month summary · 7-day bars |
| **POS** | Search by name, barcode or SKU (an exact code adds the item straight away) · product cards · cart with +/−, remove, subtotal and total · cash with quick-cash buttons and change, or utang to a customer · checkout is blocked when the cart asks for more than the stock · receipt screen |
| **Sales** | History by day · sale detail · refunds (owner) per item, either back to stock or written off · cancel a whole sale (owner) when it has no refunds · every refund and cancel is audited |
| **Inventory** | Add, edit, view, archive and restore products · name, category, barcode, SKU, supplier, cost, selling price, stock, minimum level · low / out / archived views · search, category filter, sorting · restock (weighted-average cost) and adjustments with reasons · stock movement history per product and for the store · inventory cost and retail value · CSV export (opens in Excel) |
| **Capital and income** | Enter what you paid as a **total** ("₱100 for 10 pieces") or **per piece**. The form shows the cost per piece, capital, expected sales (price × pieces) and expected income (sales − capital) as you type. |
| **Utang** | Customers with balances · charge a sale to a customer · record payments and manual charges · full ledger · refunds and cancels lower the balance |
| **Expenses** | Daily expenses by category, counted against the day's profit |
| **Staff** | Owner creates cashier accounts and can turn them off · cashiers sell and view stock but never see cost or profit, never edit products, refund or cancel |
| **Audit log** | Product edits, archives, restocks, adjustments, refunds, cancels, staff changes |

The POS keeps working without internet: Firestore caches the whole store on the phone and syncs when it is back online. A sale saved offline says so on the receipt.

---

## Setup

You need Flutter **3.29 or newer** (Dart 3.7+), the Firebase CLI and the FlutterFire CLI.

```bash
# 1. Platform folders (android/, ios/) are already generated.
cd tindahan_pos

# 2. Packages
flutter pub get
#    If pub can't resolve a version, run `flutter pub upgrade --major-versions`
#    — the versions in pubspec.yaml were chosen without access to pub.dev.

# 3. Firebase project
#    In the Firebase console: create a project, then enable
#    Authentication → Email/Password, and Firestore (production mode,
#    region asia-southeast1 is closest to the Philippines).
dart pub global activate flutterfire_cli
flutterfire configure        # replaces lib/firebase_options.dart

# 4. Security rules and indexes
firebase login
firebase use --add           # pick the same project
firebase deploy --only firestore

# 5. Run
flutter analyze
flutter test
flutter run
```

**Android:** if the build complains about `minSdkVersion`, set `minSdk = 23` in `android/app/build.gradle(.kts)`.

### First run

1. **Gumawa ng account** (create account) with email and password.
2. Name the store. You become its owner.
3. Add products under **Paninda** → **Bagong paninda**.
4. Sell from **Benta** (the POS tab).
5. To add a cashier: **Iba pa → Mga tauhan → Magdagdag ng cashier**. The cashier signs in on their own phone with the email and password you set.

---

## Project layout

```
lib/
  main.dart, app.dart          start-up, Firebase init, routing by session state
  core/                        money (centavos), Manila time, Result type, theme, translations
  data/                        Firestore models, repositories, session, live queries
  domain/                      pure logic: pricing, cart, inventory filters, dashboard, CSV
  ui/                          shell, shared widgets, screens
test/                          unit tests for money, time, pricing, cart, inventory, dashboard, CSV
firestore.rules                who can read and write what; stock can never go below zero
firestore.indexes.json         composite indexes the queries need
context/                       project docs for anyone (or any AI agent) continuing the work
DESIGN.md                      the design source the UI follows
```

Read `context/AGENTS.md` before changing code.

---

## Data model (Firestore)

```
users/{uid}                          → storeId
stores/{storeId}                     name, ownerUid
  members/{uid}                      role (owner|cashier), active, displayName
  products/{id}                      name, category, barcode, sku, supplier,
                                     unitCost (centavos, may be fractional), sellingPrice (centavos),
                                     stock, minStock, archived, soldQty, revenue, cogs
  sales/{id}                         items[], total, cogs, paymentType, customerId, status, dayKey…
  refunds/{id}                       saleId, items[], amount, restock|write-off
  stockMovements/{id}                productId, type, qtyChange, stockAfter, reason, note
  dailyStats/{YYYY-MM-DD}            salesTotal, profit, txnCount, refundTotal, expenses, items{}
  customers/{id}                     name, phone, balance
    ledger/{id}                      charge | payment | refund | cancel
  expenses/{id}                      category, amount, note, dayKey, monthKey
  auditLogs/{id}                     action, actor, target, details
```

Every sale, refund, restock and adjustment is **one atomic batch**: the sale, the stock decrements (`FieldValue.increment`), the movements, the day's stats and the audit entry succeed or fail together. The dashboard reads a handful of `dailyStats` documents instead of every sale, so it stays fast and cheap.

---

## Known gaps

- **Rules untested in the emulator.** The app is connected to Firebase project `tindahan-pos-b57e2` and the rules are deployed, but there is no emulator test suite for them yet.
- **Package majors.** Built against `firebase_core` 4, `cloud_firestore` 6, `firebase_auth` 6 and `share_plus` 11. Newer majors exist; upgrading is a separate task.
- **Cashiers can read cost fields through the API.** Firestore rules work per document, not per field, so a cashier who bypasses the app could read `unitCost`. The app hides cost and profit from cashiers. To truly hide them, move cost into an owner-only subcollection or a Cloud Function.
- **Very large carts.** Rules allow at most 20 document lookups per batch. Test a 15+ item cart in the Firebase emulator; if it is refused, add a limit on cart lines in `CartController` or move member checks to custom claims.
- **Excel export is CSV.** It opens in Excel and Google Sheets (UTF-8 with BOM so ₱ and ñ show correctly), but it is not a native `.xlsx`.
- **Filipino copy** was written by the developer, not a native reviewer. The strings live in `lib/core/l10n/strings_fil.dart`.
- **No barcode camera scanning yet.** The search box accepts codes from a Bluetooth/USB scanner, which types like a keyboard.

---

## Design

The UI follows the light, transactional track of `DESIGN.md`: cream canvas `#fbfbf5`, black pill buttons, aloe `#c1fbd4` featured cards, pistachio `#d4f9e0` bands, Inter at weights 330 / 420 / 550 with `ss03`, 12 px card radius, 8 px input radius. The welcome screen alone uses the black cinematic canvas. `DESIGN.md` has no red or amber, so stock and status use an icon plus a word on aloe, shade or ink pills, never colour alone. The token mapping is in `context/ui-mapping.md`.

Inter is bundled under the SIL Open Font License (`assets/fonts/Inter-LICENSE.txt`).
