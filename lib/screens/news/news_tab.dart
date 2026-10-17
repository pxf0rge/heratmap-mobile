import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/data/models/announcement_model.dart';
import 'package:heratmap/data/models/news_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/screens/news/controller/announcement_controller.dart';
import 'package:heratmap/screens/news/controller/news_controller.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';

enum _NewsSection { news, announcements }

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  _NewsSection _section = _NewsSection.news;

  @override
  Widget build(BuildContext context) {
    final newsCtrl = Get.find<NewsController>();
    final announcementCtrl = Get.find<AnnouncementController>();
    final isNews = _section == _NewsSection.news;

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: isNews
                ? AppStrings.news.tr
                : AppStrings.announcements.tr,
            icon: isNews
                ? Icons.newspaper_rounded
                : Icons.campaign_rounded,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimentions.spaces16,
              Dimentions.spaces12,
              Dimentions.spaces16,
              Dimentions.spaces4,
            ),
            child: SegmentedButton<_NewsSection>(
              segments: [
                ButtonSegment(
                  value: _NewsSection.news,
                  label: Text(AppStrings.news.tr),
                  icon: const Icon(Icons.newspaper_rounded, size: 18),
                ),
                ButtonSegment(
                  value: _NewsSection.announcements,
                  label: Text(AppStrings.announcements.tr),
                  icon: const Icon(Icons.campaign_rounded, size: 18),
                ),
              ],
              selected: {_section},
              onSelectionChanged: (next) {
                setState(() => _section = next.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isNews
                ? _NewsList(ctrl: newsCtrl)
                : _AnnouncementList(ctrl: announcementCtrl),
          ),
        ],
      ),
    );
  }
}

class _NewsList extends StatelessWidget {
  final NewsController ctrl;
  const _NewsList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.news.isEmpty) {
        return const NewsListSkeleton();
      }
      if (ctrl.hasError && ctrl.news.isEmpty) {
        return AppEmptyState(
          icon: Icons.wifi_off_rounded,
          message: ctrl.errorText ?? '',
          actionLabel: AppStrings.retry.tr,
          onAction: ctrl.reload,
        );
      }
      if (ctrl.news.isEmpty) {
        return AppEmptyState(
          icon: Icons.newspaper_outlined,
          message: AppStrings.noNewsFound.tr,
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.reload,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimentions.spaces16,
            vertical: Dimentions.spaces12,
          ),
          itemCount: ctrl.news.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimentions.spaces8),
          itemBuilder: (_, i) => _NewsCard(news: ctrl.news[i]),
        ),
      );
    });
  }
}

class _AnnouncementList extends StatelessWidget {
  final AnnouncementController ctrl;
  const _AnnouncementList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.visibleAnnouncements;
      if (ctrl.isLoading.value && items.isEmpty) {
        return const NewsListSkeleton();
      }
      if (ctrl.hasError && items.isEmpty) {
        return AppEmptyState(
          icon: Icons.wifi_off_rounded,
          message: ctrl.errorText ?? '',
          actionLabel: AppStrings.retry.tr,
          onAction: ctrl.reload,
        );
      }
      if (items.isEmpty) {
        return AppEmptyState(
          icon: Icons.campaign_outlined,
          message: AppStrings.noAnnouncementsFound.tr,
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.reload,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimentions.spaces16,
            vertical: Dimentions.spaces12,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimentions.spaces8),
          itemBuilder: (_, i) => _AnnouncementCard(item: items[i]),
        ),
      );
    });
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AppSurfaceCard(
      onTap: () => Get.toNamed(AppRoutes.newsDetail, arguments: news),
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadiusDirectional.horizontal(
              start: Radius.circular(Dimentions.radius16),
            ),
            child: Container(
              width: 104,
              height: 104,
              color: AppSurfaces.primarySoft(context),
              child: news.coverImage.isNotEmpty
                  ? Image.network(
                      news.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.newspaper_rounded,
                        color: primary.withValues(alpha: 0.35),
                        size: 32,
                      ),
                    )
                  : Icon(
                      Icons.newspaper_rounded,
                      color: primary.withValues(alpha: 0.35),
                      size: 32,
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimentions.spaces12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: Dimentions.spaces6),
                  Text(
                    news.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppSurfaces.muted(context),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: Dimentions.spaces8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppSurfaces.muted(context),
                      ),
                      const SizedBox(width: 4),
                      if (news.publishedAt != null)
                        Text(
                          formatLocalDate(
                            news.publishedAt!,
                            withYear: false,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppSurfaces.muted(context),
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: NeutralColors.n300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel item;
  const _AnnouncementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AppSurfaceCard(
      onTap: () =>
          Get.toNamed(AppRoutes.announcementDetail, arguments: item),
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadiusDirectional.horizontal(
              start: Radius.circular(Dimentions.radius16),
            ),
            child: Container(
              width: 104,
              height: 104,
              color: AppSurfaces.primarySoft(context),
              child: item.image.isNotEmpty
                  ? Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.campaign_rounded,
                        color: primary.withValues(alpha: 0.35),
                        size: 32,
                      ),
                    )
                  : Icon(
                      Icons.campaign_rounded,
                      color: primary.withValues(alpha: 0.35),
                      size: 32,
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimentions.spaces12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: Dimentions.spaces6),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppSurfaces.muted(context),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: Dimentions.spaces8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppSurfaces.muted(context),
                      ),
                      const SizedBox(width: 4),
                      if (item.publishedAt != null)
                        Text(
                          formatLocalDate(
                            item.publishedAt!,
                            withYear: false,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppSurfaces.muted(context),
                          ),
                        ),
                      if (item.isExpired) ...[
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.announcementExpired.tr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: NeutralColors.n300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsListSkeleton extends StatelessWidget {
  const NewsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimentions.spaces16,
        vertical: Dimentions.spaces12,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: Dimentions.spaces8),
        height: 104,
        decoration: BoxDecoration(
          color: AppSurfaces.softFill(context),
          borderRadius: BorderRadius.circular(Dimentions.radius16),
        ),
      ),
    );
  }
}
