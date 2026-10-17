import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/data/models/news_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final news = Get.arguments as NewsModel;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppSurfaces.card(context),
            foregroundColor: theme.colorScheme.onSurface,
            title: Text(
              AppStrings.news.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(Dimentions.spaces6),
              child: Material(
                color: Colors.black.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: news.coverImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: news.coverImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppSurfaces.primarySoft(context),
                        child: Icon(
                          Icons.newspaper_rounded,
                          color: primary.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppSurfaces.primarySoft(context),
                        child: Icon(
                          Icons.newspaper_rounded,
                          color: primary.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ),
                    )
                  : Container(
                      color: AppSurfaces.primarySoft(context),
                      child: Icon(
                        Icons.newspaper_rounded,
                        color: primary.withValues(alpha: 0.4),
                        size: 48,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimentions.spaces20,
                Dimentions.spaces20,
                Dimentions.spaces20,
                Dimentions.spaces32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (news.publishedAt != null)
                    Text(
                      formatLocalDate(news.publishedAt!),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppSurfaces.muted(context),
                      ),
                    ),
                  const SizedBox(height: Dimentions.spaces12),
                  Text(
                    news.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: Dimentions.spaces16),
                  const Divider(),
                  const SizedBox(height: Dimentions.spaces16),
                  Text(
                    news.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.9,
                      color: AppSurfaces.muted(context),
                    ),
                  ),
                  if (news.image.isNotEmpty) ...[
                    const SizedBox(height: Dimentions.spaces20),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Dimentions.radius12),
                      child: CachedNetworkImage(
                        imageUrl: news.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          height: 200,
                          color: AppSurfaces.softFill(context),
                        ),
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
