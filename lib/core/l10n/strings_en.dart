// GENERATED from one table so both languages always have the same keys.
// Edit the table and regenerate, or edit both language files together.

// ignore_for_file: lines_longer_than_80_chars

import '../../data/models/customer.dart';
import '../../data/models/product.dart';
import '../../data/models/records.dart';
import '../../domain/inventory.dart';
import '../result.dart';

import 'strings.dart';

class EnStrings extends Strings {
  const EnStrings();

  @override
  String get aboutBody => 'Tindahan POS for sari-sari stores: sales, stock, utang and income. Data is saved on the phone and in Firebase, so it works even without internet.';

  @override
  String get aboutTitle => 'About';

  @override
  String get accessDisabledBody => 'The store owner turned off this account\'s access. Ask the owner to turn it back on.';

  @override
  String get accessDisabledTitle => 'Access turned off';

  @override
  String get actualCount => 'Actual count';

  @override
  String get actualCountHelper => 'Count what is on the shelf and enter it here.';

  @override
  String get addCashier => 'Add cashier';

  @override
  String get addCashierCaption => 'This creates a login for the cashier. Give them the email and password.';

  @override
  String get addCustomer => 'New customer';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addProduct => 'New product';

  @override
  String get addUtang => 'Add utang';

  @override
  String get addedToUtang => 'Added to utang';

  @override
  String get adjustStock => 'Adjust';

  @override
  String get adjustTitle => 'Adjust stock';

  @override
  String get allCategories => 'All';

  @override
  String get allTypes => 'All';

  @override
  String get amount => 'Amount';

  @override
  String get amountPaid => 'Amount paid';

  @override
  String get appName => 'Tindahan';

  @override
  String get archive => 'Archive';

  @override
  String get archiveProductTitle => 'Archive this product?';

  @override
  String get archivedLabel => 'Archived';

  @override
  String get auditCaption => 'Who changed what';

  @override
  String get auditTitle => 'Audit log';

  @override
  String get averageCostExplainer => 'Old and new stock costs are averaged so the profit on each sale stays accurate.';

  @override
  String get balanceOwed => 'Balance owed';

  @override
  String get balanceShort => 'Balance';

  @override
  String get barcode => 'Barcode';

  @override
  String get barcodeOptional => 'Barcode (optional)';

  @override
  String get bestSellersThisMonth => 'Best sellers this month';

  @override
  String get calculationTitle => 'Calculation';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelSale => 'Cancel sale';

  @override
  String get cancelSaleTitle => 'Cancel the whole sale?';

  @override
  String get cancelledSales => 'Cancelled sales';

  @override
  String get capitalAndIncome => 'Capital and income';

  @override
  String get capitalInStock => 'Capital in stock';

  @override
  String get capitalLabel => 'Capital';

  @override
  String get cartEmpty => 'The cart is empty.';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cashReceived => 'Cash received';

  @override
  String get cashToReturn => 'Cash to return';

  @override
  String get cashierAdded => 'Cashier added.';

  @override
  String get cashierName => 'Cashier name';

  @override
  String get cashierRightsNote => 'Cashiers can sell, view stock and record utang. They cannot see costs or profit, edit products, refund or cancel sales.';

  @override
  String get category => 'Category';

  @override
  String get categoryHint => 'e.g. Drinks, Canned goods, Soap';

  @override
  String get categoryOptional => 'Category (optional)';

  @override
  String get changeCustomer => 'Change';

  @override
  String get changeLabel => 'Change';

  @override
  String get checkoutTitle => 'Payment';

  @override
  String get chooseCustomer => 'Choose customer';

  @override
  String get clearCart => 'Clear all';

  @override
  String get clearCartMessage => 'All items will be removed from the cart.';

  @override
  String get clearCartTitle => 'Remove all items?';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get columnCount => 'Count';

  @override
  String get columnProfit => 'Profit';

  @override
  String get columnSales => 'Sales';

  @override
  String get completeSale => 'Complete sale';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmRefund => 'Refund';

  @override
  String get costModePerPiece => 'Per piece';

  @override
  String get costModeTotal => 'Total paid';

  @override
  String get costOfGoodsSold => 'Cost of goods sold';

  @override
  String get costPerPiece => 'Cost per piece';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get costPerPieceHelper => 'What you paid for one piece.';

  @override
  String get costPerPieceLabel => 'Cost per piece';

  @override
  String get createAccount => 'Create account';

  @override
  String get createStoreAccount => 'Create a store account';

  @override
  String get createStoreCaption => 'You will be the owner. You can add cashiers later.';

  @override
  String get createStoreTitle => 'Set up your store';

  @override
  String get csvBarcode => 'Barcode';

  @override
  String get csvBy => 'By';

  @override
  String get csvCategory => 'Category';

  @override
  String get csvDate => 'Date';

  @override
  String get csvMinStock => 'Minimum stock';

  @override
  String get csvMovementType => 'Type';

  @override
  String get csvName => 'Name';

  @override
  String get csvProfit => 'Profit';

  @override
  String get csvQtyChange => 'Change';

  @override
  String get csvReason => 'Reason';

  @override
  String get csvReference => 'Reference';

  @override
  String get csvRevenue => 'Revenue';

  @override
  String get csvSellingPrice => 'Selling price';

  @override
  String get csvSku => 'SKU';

  @override
  String get csvSoldQty => 'Pieces sold';

  @override
  String get csvStatus => 'Status';

  @override
  String get csvStock => 'Stock';

  @override
  String get csvStockAfter => 'Stock after';

  @override
  String get csvStockBefore => 'Stock before';

  @override
  String get csvStockValueCost => 'Stock value (cost)';

  @override
  String get csvStockValueRetail => 'Stock value (price)';

  @override
  String get csvSupplier => 'Supplier';

  @override
  String get csvUnitCost => 'Unit cost';

  @override
  String get currentStock => 'Current stock';

  @override
  String get customer => 'Customer';

  @override
  String get customerName => 'Customer name';

  @override
  String get customerNotFound => 'Customer not found.';

  @override
  String get customerNoteHint => 'e.g. Neighbour at the corner';

  @override
  String get dashboardTitle => 'Today';

  @override
  String get date => 'Date';

  @override
  String get decreaseQty => 'Decrease';

  @override
  String get deductFromUtang => 'Deduct from utang';

  @override
  String get delete => 'Delete';

  @override
  String get deleteExpenseTitle => 'Delete this expense?';

  @override
  String get details => 'Details';

  @override
  String get disable => 'Turn off';

  @override
  String get disableCashierTitle => 'Turn off cashier access?';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get editProduct => 'Edit product';

  @override
  String get email => 'Email';

  @override
  String get enterAmount => 'Enter an amount.';

  @override
  String get enterEmailFirst => 'Enter your email first.';

  @override
  String get enterPassword => 'Enter your password.';

  @override
  String get enterQuantity => 'Enter a quantity.';

  @override
  String get enterSellingPrice => 'Enter the selling price.';

  @override
  String get enterValidEmail => 'Enter a valid email.';

  @override
  String get estimatedProfit => 'Estimated profit';

  @override
  String get exactAmount => 'Exact';

  @override
  String get expectedIncome => 'Expected income';

  @override
  String get expenseDeleted => 'Expense deleted.';

  @override
  String get expenseNotStock => 'Stock purchases are not included (those are restocks).';

  @override
  String get expenseSaved => 'Expense saved.';

  @override
  String get expensesCaption => 'Electricity, water, rent and more';

  @override
  String get expensesThisMonth => 'Expenses this month';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get exportCaption => 'Opens in Excel or Google Sheets. You can send it by Messenger or email.';

  @override
  String get exportFailed => 'The file could not be exported. Try again.';

  @override
  String get exportInventory => 'Product list';

  @override
  String get exportInventoryCaption => 'All products, prices, costs and stock (CSV)';

  @override
  String get exportInventoryFile => 'inventory';

  @override
  String get exportMovements => 'Stock movements';

  @override
  String get exportMovementsCaption => 'Sales, restocks, adjustments and refunds (CSV)';

  @override
  String get exportMovementsFile => 'stock-movements';

  @override
  String get exportTitle => 'Export';

  @override
  String get fixCartFirst => 'Fix the items without enough stock first.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get goToInventory => 'Go to Products';

  @override
  String get haveAccountSignIn => 'Have an account? Sign in';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get incomeLabel => 'Income';

  @override
  String get incomePerPiece => 'Income per piece';

  @override
  String get increaseQty => 'Increase';

  @override
  String get inventoryTitle => 'Products';

  @override
  String get inventoryValueTitle => 'Inventory value';

  @override
  String get itemsInSale => 'Items';

  @override
  String get languageTitle => 'Language';

  @override
  String get lastSevenDays => 'Sales, last 7 days';

  @override
  String get loading => 'Loading';

  @override
  String get lowStock => 'Low stock';

  @override
  String get minStockHelper => 'Shows under “Low stock” at or below this many pieces.';

  @override
  String get minStockLevel => 'Minimum stock level';

  @override
  String get moreActions => 'More actions';

  @override
  String get moreTitle => 'More';

  @override
  String get netSales => 'Net sales';

  @override
  String get newAverageCost => 'New average cost';

  @override
  String get newBalanceLabel => 'New balance';

  @override
  String get newSale => 'New sale';

  @override
  String get nextDay => 'Next day';

  @override
  String get nextMonth => 'Next month';

  @override
  String get noAuditYet => 'No records yet.';

  @override
  String get noCustomersFound => 'No matching customers.';

  @override
  String get noCustomersYet => 'No utang customers yet. Add them here or while selling.';

  @override
  String get noExpenses => 'No expenses this month.';

  @override
  String get noMovementsYet => 'No stock movements yet.';

  @override
  String get noProductsCashier => 'No products yet. Ask the owner to add some.';

  @override
  String get noProductsOwner => 'No products yet. Add some to start selling.';

  @override
  String get noSalesThisDay => 'No sales on this day.';

  @override
  String get noSalesThisMonth => 'No sales this month yet.';

  @override
  String get noSalesYet => 'No sales yet.';

  @override
  String get noSearchResults => 'Nothing matches your search.';

  @override
  String get noStockAlerts => 'Stock is fine. Nothing is low or out.';

  @override
  String get noUtangHistory => 'No utang records yet.';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get onHand => 'On hand';

  @override
  String get openStore => 'Open the store';

  @override
  String get openingStore => 'Opening the store…';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get paidUp => 'Paid up';

  @override
  String get password => 'Password';

  @override
  String get passwordRule => 'At least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get paymentRecorded => 'Payment recorded.';

  @override
  String get paymentUtang => 'Utang (credit)';

  @override
  String get periodMonth => 'This month';

  @override
  String get periodToday => 'Today';

  @override
  String get periodWeek => 'This week';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get piecesSoldLabel => 'Pieces sold';

  @override
  String get posTitle => 'Sell';

  @override
  String get previousDay => 'Previous day';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get priceAndStockSection => 'Price and quantity';

  @override
  String get priceBelowCost => 'The price is below cost. You lose money on every sale.';

  @override
  String get priceSection => 'Price';

  @override
  String get productAdded => 'Product added.';

  @override
  String get productArchived => 'Product archived.';

  @override
  String get productDetailsSection => 'Product details';

  @override
  String get productName => 'Product name';

  @override
  String get productNameHint => 'e.g. Kopiko 3-in-1';

  @override
  String get productNotFound => 'Product not found.';

  @override
  String get productRestored => 'Product restored.';

  @override
  String get productSaved => 'Changes saved.';

  @override
  String get productsInStock => 'Products in stock';

  @override
  String get quantityBought => 'How many pieces did you buy?';

  @override
  String get quantityBoughtHelper => 'This becomes the starting stock.';

  @override
  String get quantityNeededForTotal => 'Enter the quantity to work out the cost per piece.';

  @override
  String get quantityReceived => 'Quantity received';

  @override
  String get realizedIncome => 'Income earned';

  @override
  String get reason => 'Reason';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get refundCaption => 'Choose what came back and how many.';

  @override
  String get refundItems => 'Refund';

  @override
  String get refundReasonHint => 'e.g. Expired, damaged, wrong item';

  @override
  String get refunded => 'Refunded';

  @override
  String get refunds => 'Refunds';

  @override
  String get removeItem => 'Remove';

  @override
  String get required => 'This is required.';

  @override
  String get resetEmailSent => 'We sent an email to reset your password.';

  @override
  String get restock => 'Restock';

  @override
  String get restockTitle => 'Restock';

  @override
  String get restore => 'Restore';

  @override
  String get restoreProductTitle => 'Restore this product?';

  @override
  String get retry => 'Try again';

  @override
  String get returnToStock => 'Put back in stock';

  @override
  String get returnToStockOff => 'Cannot be sold again (damaged or expired). Comes off profit.';

  @override
  String get returnToStockOn => 'Still good and can be sold again.';

  @override
  String get returnedToStock => 'Put back in stock';

  @override
  String get revenue => 'Revenue';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleOwner => 'Owner';

  @override
  String get saleCancelled => 'Sale cancelled and stock returned.';

  @override
  String get saleComplete => 'Sale complete!';

  @override
  String get saleNotFound => 'Sale not found.';

  @override
  String get salesHistoryCaption => 'Every sale, day by day';

  @override
  String get salesHistoryTitle => 'Sales';

  @override
  String get salesIfAllSold => 'Sales if all sold';

  @override
  String get salesSoFar => 'Sold so far';

  @override
  String get salesSummary => 'Sales summary';

  @override
  String get save => 'Save';

  @override
  String get saveAdjustment => 'Save adjustment';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveProduct => 'Save product';

  @override
  String get saveRestock => 'Save restock';

  @override
  String get savedOffline => 'Saved on the phone. It will sync when you are back online.';

  @override
  String get searchCustomerHint => 'Search name or number';

  @override
  String get searchInventoryHint => 'Name, barcode, SKU or category';

  @override
  String get searchProductHint => 'Search or scan a barcode';

  @override
  String get seeAll => 'See all';

  @override
  String get sellingPricePerPiece => 'Selling price per piece';

  @override
  String get setupNeededBody => 'The app is not connected to Firebase yet. In the project folder, run:';

  @override
  String get setupNeededTitle => 'Setup needed';

  @override
  String get showPassword => 'Show password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInCaption => 'Use your store email and password.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutCartMessage => 'The cart still has items. They will be cleared if you sign out.';

  @override
  String get signOutMessage => 'You will need to sign in again to use the store.';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signUpCaption => 'You will use this to sign in.';

  @override
  String get signUpTitle => 'Create an account';

  @override
  String get sku => 'SKU / code';

  @override
  String get skuHelper => 'Your own code, e.g. KOP-01. Can be typed in the POS.';

  @override
  String get skuOptional => 'SKU / code (optional)';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get sortBy => 'Sort by';

  @override
  String get staffCaption => 'Cashiers and their access';

  @override
  String get staffTitle => 'Staff';

  @override
  String get startSelling => 'Start selling';

  @override
  String get startupFailedBody => 'The app could not start. Close and reopen it, or check the internet.';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Paid';

  @override
  String get statusPartRefund => 'Part refund';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get stepOneOfTwo => 'Step 1 of 2';

  @override
  String get stepTwoOfTwo => 'Step 2 of 2';

  @override
  String get stockAfter => 'Stock after';

  @override
  String get stockAlerts => 'Stock alerts';

  @override
  String get stockChange => 'Change';

  @override
  String get stockChangesHint => 'To change stock, use Restock or Adjust.';

  @override
  String get stockHistory => 'Stock history';

  @override
  String get stockInApp => 'Stock in the app';

  @override
  String get stockMovementsCaption => 'Everything that came in or went out';

  @override
  String get stockMovementsTitle => 'Stock movements';

  @override
  String get storeName => 'Store name';

  @override
  String get storeNameHint => 'e.g. Aling Nena Sari-Sari Store';

  @override
  String get supplier => 'Supplier';

  @override
  String get supplierOptional => 'Supplier (optional)';

  @override
  String get tabDashboard => 'Summary';

  @override
  String get tabInventory => 'Products';

  @override
  String get tabMore => 'More';

  @override
  String get tabPos => 'Sell';

  @override
  String get tabUtang => 'Utang';

  @override
  String get temporaryPassword => 'Temporary password';

  @override
  String get timeZoneNote => 'All dates and times are Philippine time (Asia/Manila).';

  @override
  String get todayExpenses => 'Expenses today';

  @override
  String get todayProfit => 'Estimated profit today';

  @override
  String get todaySales => 'Sales today';

  @override
  String get todayTransactions => 'Transactions';

  @override
  String get total => 'Total';

  @override
  String get totalCostHelper => 'What you paid for all the pieces together.';

  @override
  String get totalCostLabel => 'Total cost';

  @override
  String get totalDue => 'Total due';

  @override
  String get totalReceivable => 'Total owed to the store';

  @override
  String get totalSalesLabel => 'Total sales';

  @override
  String get utangAdded => 'Added to utang.';

  @override
  String get utangCaption => 'Who owes the store';

  @override
  String get utangHistory => 'Utang history';

  @override
  String get utangSummary => 'Utang';

  @override
  String get utangTitle => 'Utang';

  @override
  String get valueAtSellingPrice => 'Value at selling price';

  @override
  String get valueLost => 'Value lost';

  @override
  String get viewCart => 'View cart';

  @override
  String get welcomeEyebrow => 'For sari-sari stores';

  @override
  String get welcomeHeadline => 'Sales, stock and utang in one app.';

  @override
  String get welcomeLead => 'Know the capital and income on every item, even without internet.';

  @override
  String get whatWasItFor => 'What was it for?';

  @override
  String get writtenOff => 'Written off';

  @override
  String get yourName => 'Your name';

  @override
  String get yourNameHelper => 'Shown on receipts and records.';

  @override
  String adjustSaved(String name) => 'Stock updated for $name.';

  @override
  String afterExpenses(String amount) => 'After expenses: $amount';

  @override
  String archiveProductMessage(String name) => '$name will no longer show in the POS. Its past sales and records stay.';

  @override
  String calculationCaption(int qty) => 'For $qty ${qty == 1 ? 'piece' : 'pieces'}';

  @override
  String cancelSaleMessage(String total) => "All items go back into stock and $total is removed from that day's sales.";

  @override
  String cancelledBecause(String reason) => 'Cancelled: $reason';

  @override
  String capitalForStock(int stock) => 'Capital for $stock ${stock == 1 ? 'piece' : 'pieces'}';

  @override
  String cartLineTooMany(String name, int available) => 'Only $available left of $name.';

  @override
  String cartLineUnavailable(String name) => '$name can no longer be sold.';

  @override
  String cashShort(String amount) => 'Still $amount short.';

  @override
  String codeAlreadyUsed(String productName) => 'Already used by “$productName”.';

  @override
  String costShort(String amount) => 'cost $amount';

  @override
  String currentBalance(String amount) => 'Current balance: $amount';

  @override
  String customersWithBalance(int count) => '$count ${count == 1 ? 'customer owes' : 'customers owe'}';

  @override
  String deleteExpenseMessage(String amount, String category) => 'This deletes the $amount $category expense.';

  @override
  String disableCashierMessage(String name) => '$name will not be able to sign in until you turn access back on.';

  @override
  String estimatedProfitShort(String amount) => 'Profit $amount';

  @override
  String highestDay(String amount) => 'Highest: $amount';

  @override
  String inCartCount(int count) => '$count in cart';

  @override
  String itemCount(int count) => '$count ${count == 1 ? 'item' : 'items'}';

  @override
  String markupPercent(double percent) => '${percent.toStringAsFixed(0)}% markup';

  @override
  String minLevel(int count) => 'Minimum: $count';

  @override
  String notEnoughStockFor(String names) => 'Not enough stock: $names.';

  @override
  String onlyNInStock(int count, String name) => 'Only $count of $name in stock.';

  @override
  String outOfStockMessage(String name) => '$name is out of stock.';

  @override
  String payAmount(String amount) => 'Pay · $amount';

  @override
  String payFullBalance(String amount) => 'Full balance ($amount)';

  @override
  String paymentOverBalance(String amount) => 'More than the $amount balance.';

  @override
  String piecesSold(int count) => '$count ${count == 1 ? 'piece' : 'pieces'} sold';

  @override
  String priceEach(String amount) => '$amount each';

  @override
  String productCount(int count) => '$count ${count == 1 ? 'product' : 'products'}';

  @override
  String productUnavailable(String name) => '$name is no longer for sale.';

  @override
  String receiptNo(String number) => 'Receipt #$number';

  @override
  String refundSaved(String amount) => '$amount refunded.';

  @override
  String refundableOf(int qty, String price) => 'Refundable: $qty · $price each';

  @override
  String refundedQty(int count) => '$count refunded';

  @override
  String refundsToday(String amount) => 'Refunds: $amount';

  @override
  String restockSaved(int qty, String name) => 'Added $qty to $name.';

  @override
  String restockSpend(String amount) => 'Spent on stock: $amount';

  @override
  String restoreProductMessage(String name) => '$name will show in the POS again.';

  @override
  String soldBy(String name) => 'Sold by $name';

  @override
  String stockCount(int count) => 'Stock: $count';

  @override
  String stockLeftOfMin(int stock, int minimum) => '$stock left · minimum $minimum';

  @override
  String stockNow(int count) => 'stock $count';

  @override
  String storeOwesCustomer(String amount) => 'The store owes this customer $amount.';

  @override
  String todayWithDate(String date) => 'Today, $date';

  @override
  String transactionCount(int count) => '$count ${count == 1 ? 'transaction' : 'transactions'}';

  @override
  String unitsOnHand(int count) => '$count ${count == 1 ? 'piece' : 'pieces'} on hand';

  @override
  String useAvailable(int count) => 'Change to $count';

  @override
  String utangFor(String name) => 'Utang · $name';

  @override
  String adjustReasonLabel(AdjustReason value) => switch (value) {
        AdjustReason.recount => 'Recount',
        AdjustReason.damaged => 'Damaged',
        AdjustReason.expired => 'Expired',
        AdjustReason.lost => 'Lost',
        AdjustReason.personalUse => 'Used at home',
        AdjustReason.other => 'Other',
      };

  @override
  String auditActionLabel(AuditAction value) => switch (value) {
        AuditAction.productCreated => 'Product added',
        AuditAction.productEdited => 'Product edited',
        AuditAction.priceChanged => 'Price changed',
        AuditAction.productArchived => 'Product archived',
        AuditAction.productRestored => 'Product restored',
        AuditAction.stockRestocked => 'Restock',
        AuditAction.stockAdjusted => 'Stock adjusted',
        AuditAction.saleRefunded => 'Refund',
        AuditAction.saleCancelled => 'Sale cancelled',
        AuditAction.utangPayment => 'Utang payment',
        AuditAction.utangManualCharge => 'Utang added',
        AuditAction.expenseAdded => 'Expense added',
        AuditAction.expenseDeleted => 'Expense deleted',
        AuditAction.staffAdded => 'Cashier added',
        AuditAction.staffDisabled => 'Cashier turned off',
        AuditAction.staffEnabled => 'Cashier turned on',
      };

  @override
  String errorMessage(AppErrorCode value) => switch (value) {
        AppErrorCode.permissionDenied => 'You do not have permission for this.',
        AppErrorCode.notFound => 'Not found.',
        AppErrorCode.offline => 'No internet. Try again when you are connected.',
        AppErrorCode.insufficientStock => 'Not enough stock.',
        AppErrorCode.invalidInput => 'Something entered is not right. Please check.',
        AppErrorCode.emailInUse => 'This email already has an account.',
        AppErrorCode.wrongCredentials => 'Wrong email or password.',
        AppErrorCode.weakPassword => 'Password too weak. Use 6 or more characters.',
        AppErrorCode.invalidEmail => 'That email does not look right.',
        AppErrorCode.tooManyAttempts => 'Too many attempts. Wait a moment and try again.',
        AppErrorCode.notConfigured => 'Firebase is not set up yet.',
        AppErrorCode.unknown => 'Something went wrong. Try again.',
      };

  @override
  String expenseCategoryLabel(ExpenseCategory value) => switch (value) {
        ExpenseCategory.electricity => 'Electricity',
        ExpenseCategory.water => 'Water',
        ExpenseCategory.rent => 'Rent',
        ExpenseCategory.transport => 'Transport and delivery',
        ExpenseCategory.supplies => 'Store supplies',
        ExpenseCategory.food => 'Food',
        ExpenseCategory.other => 'Other',
      };

  @override
  String inventorySortLabel(InventorySort value) => switch (value) {
        InventorySort.name => 'Name A–Z',
        InventorySort.stockLowFirst => 'Lowest stock',
        InventorySort.priceHighFirst => 'Highest price',
        InventorySort.bestSelling => 'Best selling',
        InventorySort.newest => 'Newest',
      };

  @override
  String ledgerTypeLabel(LedgerType value) => switch (value) {
        LedgerType.charge => 'Utang',
        LedgerType.payment => 'Payment',
        LedgerType.refund => 'Refund',
        LedgerType.cancel => 'Cancelled',
      };

  @override
  String movementTypeLabel(MovementType value) => switch (value) {
        MovementType.initial => 'Starting stock',
        MovementType.sale => 'Sale',
        MovementType.restock => 'Restock',
        MovementType.adjustment => 'Adjustment',
        MovementType.refund => 'Refund',
        MovementType.cancel => 'Cancelled sale',
      };

  @override
  String stockStatusLabel(StockStatus value) => switch (value) {
        StockStatus.inStock => 'In stock',
        StockStatus.low => 'Low',
        StockStatus.out => 'Out',
      };

  @override
  String inventoryFilterLabel(InventoryFilter filter, int count) => switch (filter) {
        InventoryFilter.all => 'All ($count)',
        InventoryFilter.inStock => 'In stock ($count)',
        InventoryFilter.low => 'Low ($count)',
        InventoryFilter.out => 'Out ($count)',
        InventoryFilter.archived => 'Archived ($count)',
      };

  @override
  String monthName(int month) {
    const values = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final index = month < 1 ? 0 : (month > values.length ? values.length - 1 : month - 1);
    return values[index];
  }

  @override
  String monthShort(int month) {
    const values = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final index = month < 1 ? 0 : (month > values.length ? values.length - 1 : month - 1);
    return values[index];
  }

  @override
  String weekdayName(int weekday) {
    const values = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final index = weekday < 1 ? 0 : (weekday > values.length ? values.length - 1 : weekday - 1);
    return values[index];
  }

  @override
  String weekdayShort(int weekday) {
    const values = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final index = weekday < 1 ? 0 : (weekday > values.length ? values.length - 1 : weekday - 1);
    return values[index];
  }

}
