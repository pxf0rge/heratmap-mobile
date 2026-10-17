import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/cache/key_value_store.dart';
import 'package:heratmap/data/cache/local_cache.dart';
import 'package:heratmap/data/cache/search_history.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/repository/factory_repository.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;

FactoryModel _factory({
  required String id,
  required String name,
  String phase = 'فاز 1',
}) => FactoryModel(
  id: id,
  name: name,
  category: 'صنعتی',
  phase: phase,
  lat: 34.2,
  lon: 62.2,
  address: 'خیابان اول',
  phone: '0790000000',
  workStart: '07:00',
  workEnd: '19:00',
  lotNumber: '',
  isActive: true,
  description: '',
  image: '',
  websiteUrl: '',
);

/// مخزن جعلی بدون شبکه.
///
/// درخواست‌های جستجو را ثبت و پاسخ را معلق نگه می‌دارد تا تست بتواند ترتیب
/// رسیدن پاسخ‌ها را کنترل کند (سنجش «پاسخ کهنه»).
class _FakeRepository extends FactoryRepository {
  _FakeRepository(this.factories)
    : super(cache: LocalCache(store: InMemoryStore()));

  final List<FactoryModel> factories;
  final List<String> searchCalls = [];
  final Map<String, Completer<DataResult<List<FactoryModel>>>> gates = {};
  bool blocked = false;

  @override
  bool get isSearchServerBlocked => blocked;

  @override
  Future<DataResult<List<FactoryModel>>> getFactories({
    String? phase,
    bool forceRefresh = false,
  }) async => DataSuccess(
    List.of(factories),
    source: DataSource.network,
    fetchedAt: DateTime.now(),
  );

  @override
  Future<DataResult<List<FactoryModel>>> searchFactories(
    String query, {
    bool forceRefresh = false,
  }) {
    searchCalls.add(query);
    final gate = Completer<DataResult<List<FactoryModel>>>();
    gates[query] = gate;
    return gate.future;
  }

  /// پاسخ موفق برای یک عبارت (فیلترشده از داده‌ی محلی).
  void answer(String query) => gates[query]!.complete(
    DataSuccess(
      FactoryRepository.filterLocally(factories, query),
      source: DataSource.network,
      fetchedAt: DateTime.now(),
    ),
  );

  /// پاسخ ناموفق گذرا (مثل آفلاین‌بودن دستگاه).
  void fail(String query) => gates[query]!.complete(
    const DataFailure<List<FactoryModel>>(DataError(DataErrorKind.offline)),
  );
}

const _tick = Duration(milliseconds: 60);
const _afterDebounce = Duration(milliseconds: 450);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeRepository repo;
  late app.SearchController ctrl;

  setUp(() {
    repo = _FakeRepository([
      _factory(id: '1', name: 'زلال موفق'),
      _factory(id: '2', name: 'برق و قدرت هرات', phase: 'فاز 2'),
    ]);
    ctrl = app.SearchController(
      repo,
      history: SearchHistoryStore(store: InMemoryStore()),
    );
  });

  /// راه‌اندازی کنترلر و کامل‌شدن بارگذاری اولیه.
  Future<void> start() async {
    ctrl.onInit();
    await Future<void>.delayed(_tick);
  }

  test('بارگذاری اولیه، همه‌ی شرکت‌ها را نشان می‌دهد', () async {
    await start();

    expect(ctrl.isInitialLoading, isFalse);
    expect(ctrl.results.length, 2);
    expect(ctrl.hasActiveFilter, isFalse);
  });

  test('تایپ: نتیجه‌ی محلی بی‌درنگ، فقط یک درخواست سرور پس از debounce', () async {
    await start();

    ctrl.onQueryInput('ز');
    ctrl.onQueryInput('زل');
    ctrl.onQueryInput('زلال');

    // هنوز هیچ درخواستی نرفته و لیست از حافظه فیلتر شده است
    expect(repo.searchCalls, isEmpty);
    expect(ctrl.results.single.id, '1');

    await Future<void>.delayed(_afterDebounce);

    expect(repo.searchCalls, ['زلال'], reason: 'یک درخواست برای کل تایپ');
    expect(ctrl.isSearching.value, isTrue);

    repo.answer('زلال');
    await Future<void>.delayed(_tick);

    expect(ctrl.isSearching.value, isFalse);
    expect(ctrl.results.single.id, '1');
  });

  test('پاسخ کهنه، نتیجه‌ی عبارت تازه را بازنویسی نمی‌کند', () async {
    await start();

    ctrl.onQueryInput('زلال');
    await Future<void>.delayed(_afterDebounce);

    ctrl.onQueryInput('برق');
    await Future<void>.delayed(_afterDebounce);

    expect(repo.searchCalls, ['زلال', 'برق']);

    repo.answer('برق');
    await Future<void>.delayed(_tick);
    expect(ctrl.results.single.id, '2');

    // پاسخ دیرآمده‌ی عبارت قبلی باید نادیده گرفته شود
    repo.answer('زلال');
    await Future<void>.delayed(_tick);
    expect(ctrl.results.single.id, '2');
  });

  test('اجرای فوری (Enter) درخواست تکراری برای debounce نمی‌سازد', () async {
    await start();

    ctrl.onQueryInput('زلال');
    ctrl.onQuerySubmitted('زلال');
    expect(repo.searchCalls, ['زلال']);

    // تایمر debounce باید همان عبارت را تکراری نفرستد
    await Future<void>.delayed(_afterDebounce);
    expect(repo.searchCalls, ['زلال']);
  });

  test('انتخاب از تاریخچه فقط یک درخواست می‌فرستد', () async {
    await start();

    ctrl.onQueryInput('زلال');
    ctrl.rememberQuery();
    ctrl.clearQuery();
    await Future<void>.delayed(_afterDebounce);

    ctrl.applyHistory('زلال');
    expect(repo.searchCalls, ['زلال']);
    expect(ctrl.isHistoryVisible.value, isFalse);

    await Future<void>.delayed(_afterDebounce);
    expect(repo.searchCalls, ['زلال']);
  });

  test('فیلتر فاز روی نتیجه‌ی سرور هم اعمال می‌شود', () async {
    await start();

    ctrl.setPhaseName('فاز 2');
    await Future<void>.delayed(_tick);
    expect(ctrl.results.single.id, '2');

    ctrl.clearFilters();
    await Future<void>.delayed(_tick);
    expect(ctrl.results.length, 2);
    expect(ctrl.hasActiveFilter, isFalse);
  });

  test('تاریخچه: ثبت جستجو، اجرای مجدد و حذف', () async {
    await start();

    ctrl.onQueryInput('زلال');
    ctrl.rememberQuery();
    expect(ctrl.history, ['زلال']);

    ctrl.clearQuery();
    ctrl.applyHistory('زلال');

    expect(ctrl.textController.text, 'زلال');
    expect(ctrl.query.value, 'زلال');
    expect(ctrl.results.single.id, '1');

    ctrl.removeHistoryItem('زلال');
    expect(ctrl.history, isEmpty);
  });

  test('خطای سرور، نتایج محلی را حذف نمی‌کند و پرچم آفلاین را روشن می‌کند', () async {
    await start();
    repo.blocked = true;

    ctrl.onQueryInput('زلال');
    await Future<void>.delayed(_afterDebounce);

    repo.fail('زلال');
    await Future<void>.delayed(_tick);

    expect(ctrl.hasError, isTrue);
    expect(ctrl.results.single.id, '1');
    expect(ctrl.serverSearchBlocked.value, isTrue);
  });

  testWidgets('پنل تاریخچه فقط با فوکوس روی فیلد و عبارت خالی باز می‌شود', (
    tester,
  ) async {
    ctrl.onInit();
    await tester.pump();

    // عبارت خالی چیزی در تاریخچه ثبت نمی‌کند
    ctrl.rememberQuery();
    expect(ctrl.history, isEmpty);

    ctrl.onQueryInput('زلال');
    ctrl.rememberQuery();
    ctrl.clearQuery();
    expect(ctrl.isHistoryVisible.value, isFalse);

    // فوکوس فقط وقتی معنا دارد که نود به درخت ویجت وصل باشد
    await tester.pumpWidget(
      MaterialApp(
        home: Focus(focusNode: ctrl.focusNode, child: const SizedBox.shrink()),
      ),
    );
    ctrl.focusNode.requestFocus();
    await tester.pump();

    expect(ctrl.isHistoryVisible.value, isTrue);

    ctrl.focusNode.unfocus();
    await tester.pump();

    expect(ctrl.isHistoryVisible.value, isFalse);

    // تخلیه‌ی تایمر debounce تا تست با تایمر معلق تمام نشود
    await tester.pump(const Duration(seconds: 1));
  });
}
