// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$formattedAmountHash() => r'a76dea655bddbe78b8d8f14b93034b830e879cae';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [formattedAmount].
@ProviderFor(formattedAmount)
const formattedAmountProvider = FormattedAmountFamily();

/// See also [formattedAmount].
class FormattedAmountFamily extends Family<String> {
  /// See also [formattedAmount].
  const FormattedAmountFamily();

  /// See also [formattedAmount].
  FormattedAmountProvider call(
    double amount,
  ) {
    return FormattedAmountProvider(
      amount,
    );
  }

  @override
  FormattedAmountProvider getProviderOverride(
    covariant FormattedAmountProvider provider,
  ) {
    return call(
      provider.amount,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'formattedAmountProvider';
}

/// See also [formattedAmount].
class FormattedAmountProvider extends AutoDisposeProvider<String> {
  /// See also [formattedAmount].
  FormattedAmountProvider(
    double amount,
  ) : this._internal(
          (ref) => formattedAmount(
            ref as FormattedAmountRef,
            amount,
          ),
          from: formattedAmountProvider,
          name: r'formattedAmountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$formattedAmountHash,
          dependencies: FormattedAmountFamily._dependencies,
          allTransitiveDependencies:
              FormattedAmountFamily._allTransitiveDependencies,
          amount: amount,
        );

  FormattedAmountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.amount,
  }) : super.internal();

  final double amount;

  @override
  Override overrideWith(
    String Function(FormattedAmountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FormattedAmountProvider._internal(
        (ref) => create(ref as FormattedAmountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        amount: amount,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _FormattedAmountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedAmountProvider && other.amount == amount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, amount.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FormattedAmountRef on AutoDisposeProviderRef<String> {
  /// The parameter `amount` of this provider.
  double get amount;
}

class _FormattedAmountProviderElement extends AutoDisposeProviderElement<String>
    with FormattedAmountRef {
  _FormattedAmountProviderElement(super.provider);

  @override
  double get amount => (origin as FormattedAmountProvider).amount;
}

String _$currencyNotifierHash() => r'32fdd39d5f4bf9b1a351b79ac972215680e0b622';

/// See also [CurrencyNotifier].
@ProviderFor(CurrencyNotifier)
final currencyNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CurrencyNotifier, Currency>.internal(
  CurrencyNotifier.new,
  name: r'currencyNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencyNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrencyNotifier = AutoDisposeAsyncNotifier<Currency>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
