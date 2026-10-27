// GENERATED from one table so both languages always have the same keys.
// Edit the table and regenerate, or edit both language files together.

// ignore_for_file: lines_longer_than_80_chars

import '../../data/models/customer.dart';
import '../../data/models/product.dart';
import '../../data/models/records.dart';
import '../../domain/inventory.dart';
import '../result.dart';

import 'strings.dart';

class FilStrings extends Strings {
  const FilStrings();

  @override
  String get aboutBody => 'Tindahan POS para sa sari-sari store: benta, paninda, utang at kita. Naka-save ang data sa phone at sa Firebase, kaya gumagana kahit walang internet.';

  @override
  String get aboutTitle => 'Tungkol sa app';

  @override
  String get accessDisabledBody => 'Pinatay ng may-ari ng tindahan ang access ng account na ito. Kausapin ang may-ari para buksan ulit.';

  @override
  String get accessDisabledTitle => 'Naka-off ang access';

  @override
  String get actualCount => 'Aktwal na bilang';

  @override
  String get actualCountHelper => 'Bilangin ang nasa estante at ilagay dito.';

  @override
  String get addCashier => 'Magdagdag ng cashier';

  @override
  String get addCashierCaption => 'Gagawa ito ng sariling login para sa cashier. Ibigay mo sa kanya ang email at password.';

  @override
  String get addCustomer => 'Bagong customer';

  @override
  String get addExpense => 'Magdagdag ng gastos';

  @override
  String get addProduct => 'Bagong paninda';

  @override
  String get addUtang => 'Dagdag utang';

  @override
  String get addedToUtang => 'Idadagdag sa utang';

  @override
  String get adjustStock => 'I-adjust';

  @override
  String get adjustTitle => 'I-adjust ang stock';

  @override
  String get allCategories => 'Lahat';

  @override
  String get allTypes => 'Lahat';

  @override
  String get amount => 'Halaga';

  @override
  String get amountPaid => 'Halagang binayad';

  @override
  String get appName => 'Tindahan';

  @override
  String get archive => 'I-archive';

  @override
  String get archiveProductTitle => 'I-archive ang paninda?';

  @override
  String get archivedLabel => 'Naka-archive';

  @override
  String get auditCaption => 'Sino ang nagbago ng ano';

  @override
  String get auditTitle => 'Audit log';

  @override
  String get averageCostExplainer => 'Pinagsasama ang puhunan ng luma at bagong stock para tama ang kita sa bawat benta.';

  @override
  String get balanceOwed => 'Utang na balanse';

  @override
  String get balanceShort => 'Balanse';

  @override
  String get barcode => 'Barcode';

  @override
  String get barcodeOptional => 'Barcode (opsyonal)';

  @override
  String get bestSellersThisMonth => 'Pinakamabenta ngayong buwan';

  @override
  String get calculationTitle => 'Kalkulasyon';

  @override
  String get cancel => 'Huwag na';

  @override
  String get cancelSale => 'Kanselahin ang benta';

  @override
  String get cancelSaleTitle => 'Kanselahin ang buong benta?';

  @override
  String get cancelledSales => 'Kinanselang benta';

  @override
  String get capitalAndIncome => 'Puhunan at kita';

  @override
  String get capitalInStock => 'Puhunan sa stock';

  @override
  String get capitalLabel => 'Puhunan';

  @override
  String get cartEmpty => 'Wala pang laman ang cart.';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cashReceived => 'Perang tinanggap';

  @override
  String get cashToReturn => 'Ibabalik na pera';

  @override
  String get cashierAdded => 'Naidagdag ang cashier.';

  @override
  String get cashierName => 'Pangalan ng cashier';

  @override
  String get cashierRightsNote => 'Puwedeng magbenta, tumingin ng stock at mag-record ng utang ang cashier. Hindi niya nakikita ang puhunan at kita, at hindi siya puwedeng mag-edit ng paninda, mag-refund o magkansela ng benta.';

  @override
  String get category => 'Kategorya';

  @override
  String get categoryHint => 'Hal. Inumin, Delata, Sabon';

  @override
  String get categoryOptional => 'Kategorya (opsyonal)';

  @override
  String get changeCustomer => 'Palitan';

  @override
  String get changeLabel => 'Sukli';

  @override
  String get checkoutTitle => 'Bayad';

  @override
  String get chooseCustomer => 'Pumili ng customer';

  @override
  String get clearCart => 'Alisin lahat';

  @override
  String get clearCartMessage => 'Aalisin ang lahat ng item sa cart.';

  @override
  String get clearCartTitle => 'Alisin lahat ng item?';

  @override
  String get clearSearch => 'Burahin ang hinahanap';

  @override
  String get columnCount => 'Bilang';

  @override
  String get columnProfit => 'Kita';

  @override
  String get columnSales => 'Benta';

  @override
  String get completeSale => 'Tapusin ang benta';

  @override
  String get confirmPassword => 'Ulitin ang password';

  @override
  String get confirmRefund => 'I-refund';

  @override
  String get costModePerPiece => 'Bawat piraso';

  @override
  String get costModeTotal => 'Kabuuang bayad';

  @override
  String get costOfGoodsSold => 'Puhunan ng nabenta';

  @override
  String get costPerPiece => 'Puhunan bawat piraso';

  @override
  String get costPerPieceHelper => 'Magkano ang bili mo sa isang piraso.';

  @override
  String get costPerPieceLabel => 'Puhunan bawat piraso';

  @override
  String get createAccount => 'Gumawa ng account';

  @override
  String get createStoreAccount => 'Gumawa ng account ng tindahan';

  @override
  String get createStoreCaption => 'Ikaw ang magiging may-ari. Puwede kang magdagdag ng cashier mamaya.';

  @override
  String get createStoreTitle => 'I-setup ang tindahan';

  @override
  String get csvBarcode => 'Barcode';

  @override
  String get csvBy => 'Ginawa ni';

  @override
  String get csvCategory => 'Kategorya';

  @override
  String get csvDate => 'Petsa';

  @override
  String get csvMinStock => 'Minimum na stock';

  @override
  String get csvMovementType => 'Uri';

  @override
  String get csvName => 'Pangalan';

  @override
  String get csvProfit => 'Kita';

  @override
  String get csvQtyChange => 'Pagbabago';

  @override
  String get csvReason => 'Dahilan';

  @override
  String get csvReference => 'Reference';

  @override
  String get csvRevenue => 'Kabuuang benta';

  @override
  String get csvSellingPrice => 'Presyo';

  @override
  String get csvSku => 'SKU';

  @override
  String get csvSoldQty => 'Nabentang piraso';

  @override
  String get csvStatus => 'Status';

  @override
  String get csvStock => 'Stock';

  @override
  String get csvStockAfter => 'Stock pagkatapos';

  @override
  String get csvStockBefore => 'Stock bago';

  @override
  String get csvStockValueCost => 'Halaga ng stock (puhunan)';

  @override
  String get csvStockValueRetail => 'Halaga ng stock (presyo)';

  @override
  String get csvSupplier => 'Supplier';

  @override
  String get csvUnitCost => 'Puhunan bawat piraso';

  @override
  String get currentStock => 'Stock ngayon';

  @override
  String get customer => 'Customer';

  @override
  String get customerName => 'Pangalan ng customer';

  @override
  String get customerNotFound => 'Hindi makita ang customer.';

  @override
  String get customerNoteHint => 'Hal. Kapitbahay sa kanto';

  @override
  String get dashboardTitle => 'Ngayong araw';

  @override
  String get date => 'Petsa';

  @override
  String get decreaseQty => 'Bawasan';

  @override
  String get deductFromUtang => 'Ibabawas sa utang';

  @override
  String get delete => 'Burahin';

  @override
  String get deleteExpenseTitle => 'Burahin ang gastos?';

  @override
  String get details => 'Detalye';

  @override
  String get disable => 'I-off';

  @override
  String get disableCashierTitle => 'I-off ang access ng cashier?';

  @override
  String get editCustomer => 'I-edit ang customer';

  @override
  String get editProduct => 'I-edit ang paninda';

  @override
  String get email => 'Email';

  @override
  String get enterAmount => 'Ilagay ang halaga.';

  @override
  String get enterEmailFirst => 'Ilagay muna ang email mo.';

  @override
  String get enterPassword => 'Ilagay ang password.';

  @override
  String get enterQuantity => 'Ilagay ang dami.';

  @override
  String get enterSellingPrice => 'Ilagay ang presyo ng benta.';

  @override
  String get enterValidEmail => 'Ilagay ang tamang email.';

  @override
  String get estimatedProfit => 'Tinantyang kita';

  @override
  String get exactAmount => 'Eksakto';

  @override
  String get expectedIncome => 'Inaasahang kita';

  @override
  String get expenseDeleted => 'Nabura ang gastos.';

  @override
  String get expenseNotStock => 'Hindi kasama ang pambili ng paninda (nasa restock iyon).';

  @override
  String get expenseSaved => 'Na-save ang gastos.';

  @override
  String get expensesCaption => 'Kuryente, tubig, upa at iba pa';

  @override
  String get expensesThisMonth => 'Gastos ngayong buwan';

  @override
  String get expensesTitle => 'Gastos';

  @override
  String get exportCaption => 'Bubukas ito sa Excel o Google Sheets. Puwede mong i-send sa Messenger o email.';

  @override
  String get exportFailed => 'Hindi na-export ang file. Subukan ulit.';

  @override
  String get exportInventory => 'Listahan ng paninda';

  @override
  String get exportInventoryCaption => 'Lahat ng paninda, presyo, puhunan at stock (CSV)';

  @override
  String get exportInventoryFile => 'paninda';

  @override
  String get exportMovements => 'Galaw ng stock';

  @override
  String get exportMovementsCaption => 'Benta, restock, adjust at refund (CSV)';

  @override
  String get exportMovementsFile => 'galaw-ng-stock';

  @override
  String get exportTitle => 'I-export';

  @override
  String get fixCartFirst => 'Ayusin muna ang mga item na kulang ang stock.';

  @override
  String get forgotPassword => 'Nakalimutan ang password?';

  @override
  String get goToInventory => 'Pumunta sa Paninda';

  @override
  String get haveAccountSignIn => 'May account na? Mag-sign in';

  @override
  String get hidePassword => 'Itago ang password';

  @override
  String get incomeLabel => 'Kita';

  @override
  String get incomePerPiece => 'Kita bawat piraso';

  @override
  String get increaseQty => 'Dagdagan';

  @override
  String get inventoryTitle => 'Paninda';

  @override
  String get inventoryValueTitle => 'Halaga ng paninda';

  @override
  String get itemsInSale => 'Mga item';

  @override
  String get languageTitle => 'Wika';

  @override
  String get lastSevenDays => 'Benta nitong 7 araw';

  @override
  String get loading => 'Naglo-load';

  @override
  String get lowStock => 'Paubos na';

  @override
  String get minStockHelper => 'Lalabas sa “Paubos na” kapag ganito na lang o mas kaunti ang stock.';

  @override
  String get minStockLevel => 'Minimum na stock';

  @override
  String get moreActions => 'Iba pang aksyon';

  @override
  String get moreTitle => 'Iba pa';

  @override
  String get netSales => 'Netong benta';

  @override
  String get newAverageCost => 'Bagong average na puhunan';

  @override
  String get newBalanceLabel => 'Bagong balanse';

  @override
  String get newSale => 'Bagong benta';

  @override
  String get nextDay => 'Susunod na araw';

  @override
  String get nextMonth => 'Susunod na buwan';

  @override
  String get noAuditYet => 'Wala pang record.';

  @override
  String get noCustomersFound => 'Walang customer na tugma.';

  @override
  String get noCustomersYet => 'Wala pang customer na may utang. Idagdag sila dito o habang nagbebenta.';

  @override
  String get noExpenses => 'Walang gastos ngayong buwan.';

  @override
  String get noMovementsYet => 'Wala pang galaw ng stock.';

  @override
  String get noProductsCashier => 'Wala pang paninda. Hintayin ang may-ari na magdagdag.';

  @override
  String get noProductsOwner => 'Wala pang paninda. Magdagdag para makapagbenta.';

  @override
  String get noSalesThisDay => 'Walang benta sa araw na ito.';

  @override
  String get noSalesThisMonth => 'Wala pang benta ngayong buwan.';

  @override
  String get noSalesYet => 'Wala pang benta.';

  @override
  String get noSearchResults => 'Walang tugma sa hinahanap mo.';

  @override
  String get noStockAlerts => 'Ayos ang stock. Walang paubos o ubos na.';

  @override
  String get noUtangHistory => 'Wala pang record ng utang.';

  @override
  String get noteOptional => 'Note (opsyonal)';

  @override
  String get onHand => 'Stock';

  @override
  String get openStore => 'Buksan ang tindahan';

  @override
  String get openingStore => 'Binubuksan ang tindahan…';

  @override
  String get outOfStock => 'Ubos na';

  @override
  String get paidUp => 'Bayad na';

  @override
  String get password => 'Password';

  @override
  String get passwordRule => 'Hindi bababa sa 6 na character.';

  @override
  String get passwordsDoNotMatch => 'Hindi magkapareho ang password.';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentMethod => 'Paraan ng bayad';

  @override
  String get paymentRecorded => 'Na-record ang bayad.';

  @override
  String get paymentUtang => 'Utang';

  @override
  String get periodMonth => 'Ngayong buwan';

  @override
  String get periodToday => 'Ngayon';

  @override
  String get periodWeek => 'Ngayong linggo';

  @override
  String get phoneOptional => 'Cellphone (opsyonal)';

  @override
  String get piecesSoldLabel => 'Nabentang piraso';

  @override
  String get posTitle => 'Benta';

  @override
  String get previousDay => 'Nakaraang araw';

  @override
  String get previousMonth => 'Nakaraang buwan';

  @override
  String get priceAndStockSection => 'Presyo at dami';

  @override
  String get priceBelowCost => 'Mas mababa ang presyo sa puhunan. Malulugi ka sa bawat benta.';

  @override
  String get priceSection => 'Presyo';

  @override
  String get productAdded => 'Naidagdag ang paninda.';

  @override
  String get productArchived => 'Na-archive ang paninda.';

  @override
  String get productDetailsSection => 'Detalye ng paninda';

  @override
  String get productName => 'Pangalan ng paninda';

  @override
  String get productNameHint => 'Hal. Kopiko 3-in-1';

  @override
  String get productNotFound => 'Hindi makita ang paninda.';

  @override
  String get productRestored => 'Naibalik ang paninda.';

  @override
  String get productSaved => 'Na-save ang mga pagbabago.';

  @override
  String get productsInStock => 'Paninda na may stock';

  @override
  String get quantityBought => 'Ilang piraso ang binili?';

  @override
  String get quantityBoughtHelper => 'Ito ang magiging unang stock.';

  @override
  String get quantityNeededForTotal => 'Ilagay ang dami para makuha ang puhunan bawat piraso.';

  @override
  String get quantityReceived => 'Dami ng dumating';

  @override
  String get realizedIncome => 'Kitang nakuha na';

  @override
  String get reason => 'Dahilan';

  @override
  String get recentTransactions => 'Mga huling transaksyon';

  @override
  String get recordPayment => 'Magbayad';

  @override
  String get refundCaption => 'Piliin ang ibinalik at ilang piraso.';

  @override
  String get refundItems => 'Mag-refund';

  @override
  String get refundReasonHint => 'Hal. Expired, sira, maling item';

  @override
  String get refunded => 'Na-refund';

  @override
  String get refunds => 'Mga refund';

  @override
  String get removeItem => 'Alisin';

  @override
  String get required => 'Kailangan ito.';

  @override
  String get resetEmailSent => 'Nag-send kami ng email para palitan ang password.';

  @override
  String get restock => 'Mag-restock';

  @override
  String get restockTitle => 'Mag-restock';

  @override
  String get restore => 'Ibalik';

  @override
  String get restoreProductTitle => 'Ibalik ang paninda?';

  @override
  String get retry => 'Subukan ulit';

  @override
  String get returnToStock => 'Ibalik sa stock';

  @override
  String get returnToStockOff => 'Hindi na maibebenta (sira o expired). Mababawas sa kita.';

  @override
  String get returnToStockOn => 'Maayos pa at puwedeng ibenta ulit.';

  @override
  String get returnedToStock => 'Ibinalik sa stock';

  @override
  String get revenue => 'Kabuuang benta';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleOwner => 'May-ari';

  @override
  String get saleCancelled => 'Nakansela ang benta at naibalik ang stock.';

  @override
  String get saleComplete => 'Tapos na ang benta!';

  @override
  String get saleNotFound => 'Hindi makita ang benta.';

  @override
  String get salesHistoryCaption => 'Lahat ng benta bawat araw';

  @override
  String get salesHistoryTitle => 'Mga benta';

  @override
  String get salesIfAllSold => 'Benta kapag naubos lahat';

  @override
  String get salesSoFar => 'Nabenta na';

  @override
  String get salesSummary => 'Buod ng benta';

  @override
  String get save => 'I-save';

  @override
  String get saveAdjustment => 'I-save ang adjustment';

  @override
  String get saveChanges => 'I-save ang pagbabago';

  @override
  String get saveProduct => 'I-save ang paninda';

  @override
  String get saveRestock => 'I-save ang restock';

  @override
  String get savedOffline => 'Naka-save sa phone. Isi-sync kapag may internet na.';

  @override
  String get searchCustomerHint => 'Hanapin ang pangalan o number';

  @override
  String get searchInventoryHint => 'Pangalan, barcode, SKU o kategorya';

  @override
  String get searchProductHint => 'Hanapin o i-scan ang barcode';

  @override
  String get seeAll => 'Tingnan lahat';

  @override
  String get sellingPricePerPiece => 'Presyo bawat piraso';

  @override
  String get setupNeededBody => 'Hindi pa naka-connect ang app sa Firebase. Sa project folder, patakbuhin ang:';

  @override
  String get setupNeededTitle => 'Kailangan pang i-setup';

  @override
  String get showPassword => 'Ipakita ang password';

  @override
  String get signIn => 'Mag-sign in';

  @override
  String get signInCaption => 'Gamitin ang email at password ng tindahan mo.';

  @override
  String get signInTitle => 'Mag-sign in';

  @override
  String get signOut => 'Mag-sign out';

  @override
  String get signOutCartMessage => 'May laman pa ang cart. Mawawala ito kapag nag-sign out ka.';

  @override
  String get signOutMessage => 'Kailangan mong mag-sign in ulit para magamit ang tindahan.';

  @override
  String get signOutTitle => 'Mag-sign out?';

  @override
  String get signUpCaption => 'Ito ang gagamitin mo sa pag-sign in.';

  @override
  String get signUpTitle => 'Gumawa ng account';

  @override
  String get sku => 'SKU / code';

  @override
  String get skuHelper => 'Sariling code mo, hal. KOP-01. Puwedeng i-type sa POS.';

  @override
  String get skuOptional => 'SKU / code (opsyonal)';

  @override
  String get somethingWentWrong => 'May nangyaring mali';

  @override
  String get sortBy => 'Ayusin ayon sa';

  @override
  String get staffCaption => 'Mga cashier at access nila';

  @override
  String get staffTitle => 'Mga tauhan';

  @override
  String get startSelling => 'Magbenta';

  @override
  String get startupFailedBody => 'Hindi mabuksan ang app. Isara at buksan ulit, o tingnan ang internet.';

  @override
  String get statusCancelled => 'Kinansela';

  @override
  String get statusCompleted => 'Bayad';

  @override
  String get statusPartRefund => 'May refund';

  @override
  String get statusRefunded => 'Na-refund';

  @override
  String get stepOneOfTwo => 'Hakbang 1 ng 2';

  @override
  String get stepTwoOfTwo => 'Hakbang 2 ng 2';

  @override
  String get stockAfter => 'Stock pagkatapos';

  @override
  String get stockAlerts => 'Babala sa stock';

  @override
  String get stockChange => 'Pagbabago';

  @override
  String get stockChangesHint => 'Para baguhin ang stock, gamitin ang Mag-restock o I-adjust.';

  @override
  String get stockHistory => 'Galaw ng stock';

  @override
  String get stockInApp => 'Stock sa app';

  @override
  String get stockMovementsCaption => 'Lahat ng pasok at labas ng paninda';

  @override
  String get stockMovementsTitle => 'Galaw ng stock';

  @override
  String get storeName => 'Pangalan ng tindahan';

  @override
  String get storeNameHint => 'Hal. Aling Nena Sari-Sari Store';

  @override
  String get supplier => 'Supplier';

  @override
  String get supplierOptional => 'Supplier (opsyonal)';

  @override
  String get tabDashboard => 'Buod';

  @override
  String get tabInventory => 'Paninda';

  @override
  String get tabMore => 'Iba pa';

  @override
  String get tabPos => 'Benta';

  @override
  String get tabUtang => 'Utang';

  @override
  String get temporaryPassword => 'Pansamantalang password';

  @override
  String get timeZoneNote => 'Lahat ng oras at petsa ay oras sa Pilipinas (Asia/Manila).';

  @override
  String get todayExpenses => 'Gastos ngayon';

  @override
  String get todayProfit => 'Tinantyang kita ngayon';

  @override
  String get todaySales => 'Benta ngayon';

  @override
  String get todayTransactions => 'Transaksyon';

  @override
  String get total => 'Kabuuan';

  @override
  String get totalCostHelper => 'Kabuuang binayad mo para sa lahat ng piraso.';

  @override
  String get totalCostLabel => 'Kabuuang puhunan';

  @override
  String get totalDue => 'Babayaran';

  @override
  String get totalReceivable => 'Kabuuang utang sa tindahan';

  @override
  String get totalSalesLabel => 'Kabuuang benta';

  @override
  String get utangAdded => 'Naidagdag sa utang.';

  @override
  String get utangCaption => 'Listahan ng may utang';

  @override
  String get utangHistory => 'Kasaysayan ng utang';

  @override
  String get utangSummary => 'Utang';

  @override
  String get utangTitle => 'Utang';

  @override
  String get valueAtSellingPrice => 'Halaga kung maibenta';

  @override
  String get valueLost => 'Halagang nawala';

  @override
  String get viewCart => 'Tingnan ang cart';

  @override
  String get welcomeEyebrow => 'Para sa sari-sari store';

  @override
  String get welcomeHeadline => 'Benta, paninda at utang sa isang app.';

  @override
  String get welcomeLead => 'Alamin ang puhunan at kita ng bawat paninda, kahit walang internet.';

  @override
  String get whatWasItFor => 'Para saan?';

  @override
  String get writtenOff => 'Hindi na maibebenta';

  @override
  String get yourName => 'Pangalan mo';

  @override
  String get yourNameHelper => 'Lalabas ito sa mga resibo at record.';

  @override
  String adjustSaved(String name) => 'Na-update ang stock ng $name.';

  @override
  String afterExpenses(String amount) => 'Bawas gastos: $amount';

  @override
  String archiveProductMessage(String name) => 'Hindi na lalabas ang $name sa POS. Nananatili ang mga lumang benta at record nito.';

  @override
  String calculationCaption(int qty) => 'Para sa $qty piraso';

  @override
  String cancelSaleMessage(String total) => 'Ibabalik sa stock ang lahat ng item at aalisin ang $total sa benta ng araw na iyon.';

  @override
  String cancelledBecause(String reason) => 'Kinansela: $reason';

  @override
  String capitalForStock(int stock) => 'Puhunan ng $stock piraso';

  @override
  String cartLineTooMany(String name, int available) => '$available na lang ang stock ng $name.';

  @override
  String cartLineUnavailable(String name) => 'Hindi na mabibili ang $name.';

  @override
  String cashShort(String amount) => 'Kulang pa ng $amount.';

  @override
  String codeAlreadyUsed(String productName) => 'Gamit na ito ng “$productName”.';

  @override
  String costShort(String amount) => 'puhunan $amount';

  @override
  String currentBalance(String amount) => 'Utang ngayon: $amount';

  @override
  String customersWithBalance(int count) => '$count customer na may utang';

  @override
  String deleteExpenseMessage(String amount, String category) => 'Buburahin ang $category na $amount.';

  @override
  String disableCashierMessage(String name) => 'Hindi na makakapag-sign in si $name hanggang buksan mo ulit.';

  @override
  String estimatedProfitShort(String amount) => 'Kita $amount';

  @override
  String highestDay(String amount) => 'Pinakamataas: $amount';

  @override
  String inCartCount(int count) => '$count sa cart';

  @override
  String itemCount(int count) => '$count item';

  @override
  String markupPercent(double percent) => '${percent.toStringAsFixed(0)}% patong';

  @override
  String minLevel(int count) => 'Minimum: $count';

  @override
  String notEnoughStockFor(String names) => 'Kulang ang stock: $names.';

  @override
  String onlyNInStock(int count, String name) => '$count lang ang stock ng $name.';

  @override
  String outOfStockMessage(String name) => 'Ubos na ang $name.';

  @override
  String payAmount(String amount) => 'Bayaran · $amount';

  @override
  String payFullBalance(String amount) => 'Buong balanse ($amount)';

  @override
  String paymentOverBalance(String amount) => 'Mas malaki sa utang na $amount.';

  @override
  String piecesSold(int count) => '$count piraso ang nabenta';

  @override
  String priceEach(String amount) => '$amount bawat isa';

  @override
  String productCount(int count) => '$count paninda';

  @override
  String productUnavailable(String name) => 'Hindi na mabibili ang $name.';

  @override
  String receiptNo(String number) => 'Resibo #$number';

  @override
  String refundSaved(String amount) => 'Na-refund ang $amount.';

  @override
  String refundableOf(int qty, String price) => 'Puwedeng i-refund: $qty · $price bawat isa';

  @override
  String refundedQty(int count) => '$count na-refund';

  @override
  String refundsToday(String amount) => 'Refund: $amount';

  @override
  String restockSaved(int qty, String name) => 'Nadagdag ang $qty sa $name.';

  @override
  String restockSpend(String amount) => 'Pinambili ng stock: $amount';

  @override
  String restoreProductMessage(String name) => 'Lalabas ulit ang $name sa POS.';

  @override
  String soldBy(String name) => 'Cashier: $name';

  @override
  String stockCount(int count) => 'Stock: $count';

  @override
  String stockLeftOfMin(int stock, int minimum) => '$stock na lang · minimum $minimum';

  @override
  String stockNow(int count) => 'stock $count';

  @override
  String storeOwesCustomer(String amount) => 'May babayaran ang tindahan na $amount.';

  @override
  String todayWithDate(String date) => 'Ngayon, $date';

  @override
  String transactionCount(int count) => '$count transaksyon';

  @override
  String unitsOnHand(int count) => '$count piraso lahat';

  @override
  String useAvailable(int count) => 'Gawing $count';

  @override
  String utangFor(String name) => 'Utang ni $name';

  @override
  String adjustReasonLabel(AdjustReason value) => switch (value) {
        AdjustReason.recount => 'Pagbilang ulit',
        AdjustReason.damaged => 'Sira',
        AdjustReason.expired => 'Expired',
        AdjustReason.lost => 'Nawala',
        AdjustReason.personalUse => 'Ginamit sa bahay',
        AdjustReason.other => 'Iba pa',
      };

  @override
  String auditActionLabel(AuditAction value) => switch (value) {
        AuditAction.productCreated => 'Bagong paninda',
        AuditAction.productEdited => 'Na-edit ang paninda',
        AuditAction.priceChanged => 'Nagbago ang presyo',
        AuditAction.productArchived => 'Na-archive ang paninda',
        AuditAction.productRestored => 'Naibalik ang paninda',
        AuditAction.stockRestocked => 'Restock',
        AuditAction.stockAdjusted => 'Adjust ng stock',
        AuditAction.saleRefunded => 'Refund',
        AuditAction.saleCancelled => 'Kinanselang benta',
        AuditAction.utangPayment => 'Bayad sa utang',
        AuditAction.utangManualCharge => 'Dagdag utang',
        AuditAction.expenseAdded => 'Bagong gastos',
        AuditAction.expenseDeleted => 'Binurang gastos',
        AuditAction.staffAdded => 'Bagong cashier',
        AuditAction.staffDisabled => 'Na-off ang cashier',
        AuditAction.staffEnabled => 'Na-on ang cashier',
      };

  @override
  String errorMessage(AppErrorCode value) => switch (value) {
        AppErrorCode.permissionDenied => 'Wala kang pahintulot para dito.',
        AppErrorCode.notFound => 'Hindi makita ang hinahanap.',
        AppErrorCode.offline => 'Walang internet. Subukan ulit kapag may koneksyon.',
        AppErrorCode.insufficientStock => 'Kulang ang stock.',
        AppErrorCode.invalidInput => 'May mali sa inilagay. Pakisuri.',
        AppErrorCode.emailInUse => 'May account na ang email na ito.',
        AppErrorCode.wrongCredentials => 'Mali ang email o password.',
        AppErrorCode.weakPassword => 'Masyadong mahina ang password. Gumamit ng 6 o higit pang character.',
        AppErrorCode.invalidEmail => 'Mali ang format ng email.',
        AppErrorCode.tooManyAttempts => 'Masyadong maraming subok. Maghintay muna sandali.',
        AppErrorCode.notConfigured => 'Hindi pa naka-setup ang Firebase.',
        AppErrorCode.unknown => 'May nangyaring mali. Subukan ulit.',
      };

  @override
  String expenseCategoryLabel(ExpenseCategory value) => switch (value) {
        ExpenseCategory.electricity => 'Kuryente',
        ExpenseCategory.water => 'Tubig',
        ExpenseCategory.rent => 'Upa',
        ExpenseCategory.transport => 'Pamasahe at delivery',
        ExpenseCategory.supplies => 'Gamit sa tindahan',
        ExpenseCategory.food => 'Pagkain',
        ExpenseCategory.other => 'Iba pa',
      };

  @override
  String inventorySortLabel(InventorySort value) => switch (value) {
        InventorySort.name => 'Pangalan A–Z',
        InventorySort.stockLowFirst => 'Pinakakaunting stock',
        InventorySort.priceHighFirst => 'Pinakamahal',
        InventorySort.bestSelling => 'Pinakamabenta',
        InventorySort.newest => 'Pinakabago',
      };

  @override
  String ledgerTypeLabel(LedgerType value) => switch (value) {
        LedgerType.charge => 'Utang',
        LedgerType.payment => 'Bayad',
        LedgerType.refund => 'Refund',
        LedgerType.cancel => 'Kinansela',
      };

  @override
  String movementTypeLabel(MovementType value) => switch (value) {
        MovementType.initial => 'Unang stock',
        MovementType.sale => 'Benta',
        MovementType.restock => 'Restock',
        MovementType.adjustment => 'Adjust',
        MovementType.refund => 'Refund',
        MovementType.cancel => 'Kinanselang benta',
      };

  @override
  String stockStatusLabel(StockStatus value) => switch (value) {
        StockStatus.inStock => 'May stock',
        StockStatus.low => 'Paubos na',
        StockStatus.out => 'Ubos na',
      };

  @override
  String inventoryFilterLabel(InventoryFilter filter, int count) => switch (filter) {
        InventoryFilter.all => 'Lahat ($count)',
        InventoryFilter.inStock => 'May stock ($count)',
        InventoryFilter.low => 'Paubos ($count)',
        InventoryFilter.out => 'Ubos ($count)',
        InventoryFilter.archived => 'Naka-archive ($count)',
      };

  @override
  String monthName(int month) {
    const values = ['Enero', 'Pebrero', 'Marso', 'Abril', 'Mayo', 'Hunyo', 'Hulyo', 'Agosto', 'Setyembre', 'Oktubre', 'Nobyembre', 'Disyembre'];
    final index = month < 1 ? 0 : (month > values.length ? values.length - 1 : month - 1);
    return values[index];
  }

  @override
  String monthShort(int month) {
    const values = ['Ene', 'Peb', 'Mar', 'Abr', 'May', 'Hun', 'Hul', 'Ago', 'Set', 'Okt', 'Nob', 'Dis'];
    final index = month < 1 ? 0 : (month > values.length ? values.length - 1 : month - 1);
    return values[index];
  }

  @override
  String weekdayName(int weekday) {
    const values = ['Lunes', 'Martes', 'Miyerkules', 'Huwebes', 'Biyernes', 'Sabado', 'Linggo'];
    final index = weekday < 1 ? 0 : (weekday > values.length ? values.length - 1 : weekday - 1);
    return values[index];
  }

  @override
  String weekdayShort(int weekday) {
    const values = ['Lun', 'Mar', 'Miy', 'Huw', 'Biy', 'Sab', 'Lin'];
    final index = weekday < 1 ? 0 : (weekday > values.length ? values.length - 1 : weekday - 1);
    return values[index];
  }

}
