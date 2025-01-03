import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:spending_management_app/helper/currency_helper.dart';

part 'currency_notifier.g.dart';

@riverpod
class CurrencyNotifier extends _$CurrencyNotifier {
  static const String _currencyCodeKey = 'currency_code';

  @override
  Future<Currency> build() async {
    return _loadSavedCurrency();
  }

  Future<Currency> _loadSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString(_currencyCodeKey);
    if (savedCurrency != null) {
      return getCurrencyByCode(savedCurrency);
    }
    // Default to USD if no currency is saved
    return getCurrencyByCode('USD');
  }

  Future<void> setSelectedCurrency(Currency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyCodeKey, currency.code);
    state = AsyncValue.data(currency);
  }

  String formatAmount(double amount) {
    final currency = state.value;
    if (currency == null) return amount.toStringAsFixed(2);
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }
}

@riverpod
String formattedAmount(FormattedAmountRef ref, double amount) {
  final currencyAsync = ref.watch(currencyNotifierProvider);
  return currencyAsync.when(
    data: (currency) => formatCurrency(amount, currency),
    loading: () => amount.toStringAsFixed(2),
    error: (_, __) => amount.toStringAsFixed(2),
  );
}
