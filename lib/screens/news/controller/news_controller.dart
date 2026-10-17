import 'package:get/get.dart';
import 'package:heratmap/core/data_state.dart';
import 'package:heratmap/data/models/news_model.dart';
import 'package:heratmap/data/repository/news_repository.dart';

class NewsController extends GetxController with DataStateMixin {
  final NewsRepository _repo;
  NewsController(this._repo);

  final news = <NewsModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  Future<void> loadNews({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    dataError.value = null;

    final result = await _repo.getNews(forceRefresh: forceRefresh);
    final data = result.dataOrNull;
    if (data != null) news.value = data;
    applyResult(result);
    isLoading.value = false;
  }

  Future<void> reload() => loadNews(forceRefresh: true);

  bool get hasPublished => news.any((n) => n.publishedAt != null);
}
