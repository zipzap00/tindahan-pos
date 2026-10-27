# Project Overview

## About the Project

Tindahan POS is a mobile app for a Filipino sari-sari store. It replaces the notebook, the calculator and the utang list with one phone: sell from a POS, keep stock counts right, see what the store earned today, and know who owes what. It is built with Flutter on the front and Firebase (Auth, Firestore, security rules) as the back end.

Currency is the Philippine peso (₱). All dates and times are Philippine time (Asia/Manila). The app defaults to Taglish and can switch to English from **Iba pa → Wika**.

## The Problem It Solves

A sari-sari owner buys stock in bulk ("isang pack, ₱100, 10 piraso") and sells by the piece ("₱12 isa"). Most owners never know the real income per item, lose track of utang, and find out an item ran out only when a customer asks. The app:

- turns "₱100 for 10 pieces, sold at ₱12" into **capital ₱100, expected sales ₱120, income ₱20** the moment the owner types it;
- deducts stock on every sale and refuses to sell what is not on the shelf;
- keeps a running balance for every customer who buys on credit;
- shows today, this week and this month at a glance.

## Users and Roles

| Role | Can do | Cannot do |
|---|---|---|
| **Owner** | Everything: dashboard, POS, products, restock, adjust, refunds, cancel, utang, expenses, staff, audit log, export | — |
| **Cashier** | POS, view stock (without cost), utang charges and payments, view sales | See cost, capital, profit or income; add, edit or archive products; restock or adjust; refund or cancel; manage staff |

A store has one owner. The owner creates cashier accounts inside the app; each cashier signs in on their own phone.

## Pages

Bottom navigation (owner): **Buod** (dashboard) · **Benta** (POS) · **Paninda** (inventory) · **Utang** · **Iba pa** (more). Cashiers do not get Buod.

| Area | Screens |
|---|---|
| Auth | Welcome (black cinematic canvas), sign in, sign up, create store, access disabled, start-up error |
| Dashboard | Today's sales, profit, transactions, expenses · stock counts (tap to open filtered inventory) · today/week/month summary · 7-day bars · best sellers · recent transactions |
| POS | Product grid with search · cart sheet · checkout (cash with quick-cash and change, or utang) · receipt |
| Sales | History by day · sale detail with refund sheet and cancel |
| Inventory | List with filters (all, low, out, archived), category, sort, value summary · product detail with profit preview and movements · product form (total or per-piece cost) · restock and adjust sheets · store-wide movements · export |
| Utang | Customer list with balances · customer detail with ledger, payment and manual charge |
| More | Expenses · staff · audit log · language · sign out |

## Core User Flows

### Add a product
Paninda → Bagong paninda → name, category, codes, supplier → choose **Kabuuang bayad** (total paid) or **Bawat piraso** (per piece) → quantity and selling price. The form shows cost per piece, capital, expected sales and income live, and warns when selling below cost. Saving creates the product and an `initial` stock movement.

### Sell
Benta → tap cards or type a name or code (an exact barcode/SKU adds it straight away) → cart → checkout. The app re-checks stock against the latest data before saving; if a line now asks for more than the shelf has, checkout is blocked and the line is flagged. One batch writes the sale, decrements stock, writes movements, increments the day's stats and, for utang, charges the customer.

### Refund or cancel (owner)
Sale detail → **Mag-refund** → pick items and quantities → leave **Ibalik sa stock** on (back to stock) or turn it off for damaged or expired goods (written off) → reason. Or **Kanselahin ang benta** to cancel the whole sale if it has no refunds. Both reverse the stats of the day the sale happened, adjust the customer's utang if any, and write an audit entry.

### Restock
Product detail → **Mag-restock** → pieces and cost (total or per piece). The unit cost becomes the weighted average of what was on the shelf and what came in.

## Features In Scope

All of the above, plus offline selling (Firestore cache) and CSV export of inventory and stock movements.

## Features Out of Scope (for now)

Camera barcode scanning (a Bluetooth/USB scanner works), printed receipts, multiple stores per account, native `.xlsx`, GCash/Maya payment tracking, supplier purchase orders, Cloud Functions.

## Success Criteria

- A sale takes under 10 seconds from first tap to receipt.
- Stock never goes negative, even with two phones selling the last piece at once.
- The owner can answer "magkano kinita ko ngayon?" (how much did I earn today?) from the first screen.
- A cashier can work a full day without seeing a single cost figure.
