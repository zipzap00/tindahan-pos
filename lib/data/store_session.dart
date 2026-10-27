// Everything that belongs to one signed-in member of one store: repositories,
// shared live data (products, customers) and the POS cart. Created when the
// member is confirmed active and disposed on sign-out.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/cart.dart';
import 'firestore_read.dart';
import 'firestore_support.dart';
import 'live_query.dart';
import 'models/customer.dart';
import 'models/product.dart';
import 'models/records.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/sales_repository.dart';
import 'repositories/store_repositories.dart';

class StoreSession {
  StoreSession({required FirebaseFirestore db, required this.storeId, required Member member})
      : refs = StoreRefs(db, storeId),
        member = ValueNotifier<Member>(member) {
    final actor = Actor(uid: member.uid, name: member.displayName);
    catalog = CatalogRepository(refs, actor);
    sales = SalesRepository(refs, actor);
    customerRepo = CustomerRepository(refs, actor);
    expenses = ExpenseRepository(refs, actor);
    insights = InsightsRepository(refs);
    staff = StaffRepository(refs, actor);
    products = LiveQuery<List<Product>>(catalog.watchProducts, context: '[session/products]');
    customers = LiveQuery<List<Customer>>(customerRepo.watchCustomers, context: '[session/customers]');
    storeName = LiveQuery<String>(
      () => refs.store.snapshots().map((doc) => readString(doc.data()?['name'])),
      context: '[session/store]',
    );
  }

  final String storeId;
  final StoreRefs refs;
  final ValueNotifier<Member> member;

  late final CatalogRepository catalog;
  late final SalesRepository sales;
  late final CustomerRepository customerRepo;
  late final ExpenseRepository expenses;
  late final InsightsRepository insights;
  late final StaffRepository staff;

  late final LiveQuery<List<Product>> products;
  late final LiveQuery<List<Customer>> customers;
  late final LiveQuery<String> storeName;

  final CartController cart = CartController();

  bool get isOwner => member.value.isOwner;

  /// Latest product data by id, for stock checks.
  Map<String, Product> get productsById => {
        for (final product in products.value ?? const <Product>[]) product.id: product,
      };

  Customer? customerById(String? id) {
    if (id == null) return null;
    for (final customer in customers.value ?? const <Customer>[]) {
      if (customer.id == id) return customer;
    }
    return null;
  }

  void updateMember(Member value) => member.value = value;

  void dispose() {
    products.dispose();
    customers.dispose();
    storeName.dispose();
    cart.dispose();
    member.dispose();
  }
}
