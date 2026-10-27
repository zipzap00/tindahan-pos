# Architecture

## Layers

```
ui/        screens and widgets          reads StoreScope / LanguageScope, calls repositories
domain/    pure Dart logic              pricing, cart, inventory queries, dashboard, CSV — no Flutter, no Firebase
data/      models, repositories,        talks to Firestore and Auth, returns Result<T>
           session, live queries
core/      money, time, result,         shared by everyone
           theme, translations
```

Dependencies point downward only: `ui → domain/data → core`. `domain` never imports `data/repositories`, and nothing in `data` or `domain` imports Flutter widgets.

## State

No state-management package. Three building blocks:

| Piece | What it is |
|---|---|
| `ChangeNotifier` + `ListenableBuilder` | Local and shared state (cart, language, session) |
| `LiveQuery<T>` | A `ChangeNotifier` wrapper over a Firestore stream with `loading / data / error`. Shared queries (products, customers, store name) live on `StoreSession` so every tab reads the same subscription. |
| `InheritedWidget` scopes | `AppServices` (Firebase handles, session controller), `StoreScope` (current `StoreSession`), `LanguageScope`, `ShellScope` (tab switching) |

### Session

`SessionController` follows: Firebase Auth user → `users/{uid}.storeId` → `stores/{storeId}/members/{uid}`. It exposes a sealed `SessionState`:

| State | Screen |
|---|---|
| `SessionLoading` | Centered loader |
| `SignedOut` | Welcome |
| `NeedsStore` | Create store (sign-up step two) |
| `AccessDisabled` | Access turned off by owner |
| `SessionReady` | `HomeShell` with a `StoreSession` |
| `SessionFailed` | Error with retry |

`StoreScope` sits above the Navigator (via `MaterialApp.builder`) so pushed routes can read it. When the session type changes the app pops to the first route; the old `StoreSession` is disposed after the frame.

## Data Model

See the README for the full tree. Key points:

- **One store per account.** Everything lives under `stores/{storeId}`.
- **Products** hold `unitCost` (double centavos), `sellingPrice` (int centavos), `stock`, `minStock` and running totals `soldQty`, `revenue`, `cogs`.
- **Sales** copy each item's name, price and unit cost at the moment of sale, so later price edits never change history.
- **`dailyStats/{YYYY-MM-DD}`** are increment-only counters (sales, profit, transactions, refunds, expenses, and an `items` map for best sellers). The dashboard reads at most ~38 of them (this month plus the last seven days).
- **Stock movements** record every change with `qtyChange` and `stockAfter`: `initial`, `sale`, `restock`, `adjustment`, `refund`, `cancel`.

## Write Paths

Every write below is one `WriteBatch`, committed through `commitBatch`:

| Action | Writes |
|---|---|
| Create product | product, `initial` movement, audit |
| Checkout | sale, per-item product increment (stock −, soldQty +, revenue +, cogs +), per-item `sale` movement, dailyStats increment, and for utang: customer balance + ledger `charge` |
| Refund | refund doc, sale status/refunded totals, per-item product increment (stock + only if restocked), `refund` movements, dailyStats of the **sale's** day, utang ledger `refund`, audit |
| Cancel | sale status, stock back, `cancel` movements, reverse dailyStats of the sale's day, utang ledger `cancel`, audit |
| Restock | product stock + and new weighted-average `unitCost`, `restock` movement, audit |
| Adjust | product stock ±, `adjustment` movement with reason, audit |
| Expense | expense doc, dailyStats `expenses` increment |

### Profit rules
- Sale profit = Σ (price − unit cost) × qty.
- Refund back to stock reverses price − cost (the item is on the shelf again).
- Refund written off reverses the full price (the money went back, the item is gone).
- Cancel reverses everything of that sale.

### Offline
Firestore persistence is on with an unlimited cache. `commitBatch` waits up to 3 s for the server; if it times out the batch is already queued locally and `Ok(false)` is returned so the screen can say "Naka-save sa phone. Isi-sync kapag may internet na."

### Stock never below zero
The app checks stock before checkout, but the guarantee is in `firestore.rules`: a product write is refused if `stock` after the increment is below zero. Two phones selling the last piece at once: one batch succeeds, the other is refused and the cashier sees the item flagged.

## Security Rules Summary

- Only active members of a store can read it.
- Owners can write products, restock, adjust, refund, cancel, manage members and expenses.
- Cashiers can create sales and, on products, change only `stock`, `soldQty`, `revenue`, `cogs`, `updatedAt`, and only by lowering stock.
- Audit logs are create-only.
- Rules cannot hide single fields: cashiers can technically read `unitCost` through the API. The UI hides it.

## Cashier Accounts

`StaffRepository.createCashier` uses a secondary `FirebaseApp` named `staff-creator` to create the Auth user without signing the owner out, then writes the member and `users/{uid}` docs from the owner's session.

## Testing

Pure logic in `core/` and `domain/` has unit tests in `test/`. Rules should be tested with the Firebase emulator (`@firebase/rules-unit-testing`); that suite is not written yet.
