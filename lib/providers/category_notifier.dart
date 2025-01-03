import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spending_management_app/database/dao/category_dao.dart';
import 'package:spending_management_app/model/category.dart';

part 'category_notifier.g.dart';

@Riverpod(keepAlive: true)
class CategoryNotifier extends _$CategoryNotifier {
  @override
  List<Category> build() {
    return [];
  }

  Future<void> loadSavedCategories() async {
    final categoryDao = CategoryDao.instance;
    state = await categoryDao.getCategories();
  }
}
