import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_picker/currency_picker.dart';
import '../providers/currency_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyAsync = ref.watch(currencyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Currency'),
            subtitle: currencyAsync.when(
              data: (currency) => Text(
                  '${currency.flag} ${currency.name} (${currency.symbol})'),
              loading: () => const Text('Loading...'),
              error: (error, _) => Text('Error: $error'),
            ),
            onTap: () {
              showCurrencyPicker(
                context: context,
                showFlag: true,
                showCurrencyName: true,
                showCurrencyCode: true,
                onSelect: (Currency currency) {
                  ref
                      .read(currencyNotifierProvider.notifier)
                      .setSelectedCurrency(currency);
                },
                favorite: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'IDR'],
              );
            },
          ),
        ],
      ),
    );
  }
}
