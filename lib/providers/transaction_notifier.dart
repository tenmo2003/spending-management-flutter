import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_notifier.g.dart';

@Riverpod(keepAlive: true)
class TransactionLastUpdateNotifier extends _$TransactionLastUpdateNotifier {
  void update() {
    state = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  int build() {
    return 0;
  }
}
