import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/records.dart';
import '../../../data/store_session.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

/// Day-to-day store expenses (electricity, rent, transport...). Buying stock
/// is not an expense here; it is recorded as a restock (capital).
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late DateTime _month = ManilaTime.startOfMonth(ManilaTime.now());
  StoreSession? _session;
  LiveQuery<List<Expense>>? _expenses;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = StoreScope.of(context);
    if (!identical(session, _session)) {
      _session = session;
      _open();
    }
  }

  void _open() {
    final session = _session;
    if (session == null) return;
    _expenses?.dispose();
    final key = ManilaTime.monthKey(_month);
    _expenses = LiveQuery<List<Expense>>(() => session.expenses.watchMonth(key), context: '[expenses/month]');
  }

  void _moveMonth(int delta) {
    final next = DateTime.utc(_month.year, _month.month + delta);
    if (next.isAfter(ManilaTime.startOfMonth(ManilaTime.now()))) return;
    setState(() {
      _month = next;
      _open();
    });
  }

  @override
  void dispose() {
    _expenses?.dispose();
    super.dispose();
  }

  Future<void> _delete(Expense expense) async {
    final s = context.s;
    final session = _session;
    if (session == null) return;
    final confirmed = await showConfirmDialog(
      context,
      title: s.deleteExpenseTitle,
      message: s.deleteExpenseMessage(formatPeso(expense.amount), s.expenseCategoryLabel(expense.category)),
      confirmLabel: s.delete,
    );
    if (!confirmed || !mounted) return;
    final result = await session.expenses.delete(expense);
    if (!mounted) return;
    final error = result.errorOrNull;
    showMessage(context, error == null ? s.expenseDeleted : describeError(s, error));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final expenses = _expenses;
    final session = _session;
    if (expenses == null || session == null) return const SizedBox.shrink();
    final isCurrentMonth = ManilaTime.monthKey(_month) == ManilaTime.monthKey(ManilaTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(s.expensesTitle)),
      body: ListenableBuilder(
        listenable: expenses,
        builder: (context, _) {
          final error = expenses.error;
          final list = expenses.value ?? const <Expense>[];
          final total = list.fold<int>(0, (sum, e) => sum + e.amount);
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.xl),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: s.previousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _moveMonth(-1),
                  ),
                  Expanded(
                    child: Text(
                      '${s.monthName(_month.month)} ${_month.year}',
                      style: AppType.bodyStrong,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: s.nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: isCurrentMonth ? null : () => _moveMonth(1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              AppCard(
                tone: CardTone.featured,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.expensesThisMonth.toUpperCase(), style: AppType.eyebrowCap),
                    const SizedBox(height: AppSpace.sm),
                    Text(formatPeso(total), style: AppType.tabular(AppType.displayMobile)),
                    Text(s.expenseNotStock, style: AppType.caption),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              if (error != null)
                ErrorCard(error: error, onRetry: expenses.retry)
              else if (expenses.isLoading)
                const LoadingBlocks()
              else if (list.isEmpty)
                EmptyState(icon: Icons.receipt_long_outlined, message: s.noExpenses)
              else
                ListCard(
                  children: [
                    for (final expense in list)
                      ListRow(
                        title: s.expenseCategoryLabel(expense.category),
                        subtitle: [
                          ManilaTime.formatDate(ManilaTime.fromDayKey(expense.dayKey), s),
                          if (expense.note.isNotEmpty) expense.note,
                          expense.byName,
                        ].join(' · '),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(formatPeso(expense.amount), style: AppType.tabular(AppType.bodyStrong)),
                            IconButton(
                              tooltip: s.delete,
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () => _delete(expense),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomActionBar(
        child: PillButton(
          label: s.addExpense,
          icon: Icons.add_rounded,
          expand: true,
          onPressed: () => showAppSheet<void>(context, builder: (_) => _ExpenseSheet(session: session)),
        ),
      ),
    );
  }
}

class _ExpenseSheet extends StatefulWidget {
  const _ExpenseSheet({required this.session});

  final StoreSession session;

  @override
  State<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<_ExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.electricity;
  DateTime _day = ManilaTime.startOfDay(ManilaTime.now());
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = ManilaTime.startOfDay(ManilaTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_day.year, _day.month, _day.day),
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked != null && mounted) {
      setState(() => _day = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final result = await widget.session.expenses.add(
      amount: parsePesoToCents(_amount.text) ?? 0,
      category: _category,
      dayKey: ManilaTime.dayKey(_day),
      note: _note.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (_) {
        Navigator.of(context).pop();
        showMessage(context, s.expenseSaved);
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.addExpense, style: AppType.headingLg),
            const SizedBox(height: AppSpace.lg),
            PesoField(
              label: s.amount,
              controller: _amount,
              autofocus: true,
              validator: (value) {
                final cents = parsePesoToCents(value ?? '');
                return cents == null || cents <= 0 ? s.enterAmount : null;
              },
            ),
            const SizedBox(height: AppSpace.lg),
            Text(s.category, style: AppType.caption.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final category in ExpenseCategory.values)
                  ChoicePill(
                    label: s.expenseCategoryLabel(category),
                    selected: category == _category,
                    onTap: () => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            Text(s.date, style: AppType.caption.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpace.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: PillButton(
                label: ManilaTime.formatDate(_day, s),
                icon: Icons.calendar_today_outlined,
                variant: PillVariant.outline,
                onPressed: _pickDate,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.noteOptional,
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpace.xl),
            PillButton(label: s.save, onPressed: _save, loading: _busy, expand: true),
          ],
        ),
      ),
    );
  }
}
