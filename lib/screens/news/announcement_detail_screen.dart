import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/data/models/announcement_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as AnnouncementModel;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasImage = item.image.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: hasImage ? 240 : 120,
            pinned: true,
            backgroundColor: AppSurfaces.card(context),
            foregroundColor: theme.colorScheme.onSurface,
            title: Text(
              AppStrings.announcements.tr,
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
              background: hasImage
                  ? CachedNetworkImage(
                      imageUrl: item.image,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppSurfaces.primarySoft(context),
                        child: Icon(
                          Icons.campaign_rounded,
                          color: primary.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppSurfaces.primarySoft(context),
                        child: Icon(
                          Icons.campaign_rounded,
                          color: primary.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ),
                    )
                  : Container(
                      color: AppSurfaces.primarySoft(context),
                      child: Icon(
                        Icons.campaign_rounded,
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
                  Row(
                    children: [
                      if (item.publishedAt != null)
                        Text(
                          formatLocalDate(item.publishedAt!),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppSurfaces.muted(context),
                          ),
                        ),
                      if (item.isExpired) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppStrings.announcementExpired.tr,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: Dimentions.spaces12),
                  Text(
                    item.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: Dimentions.spaces16),
                  const Divider(),
                  const SizedBox(height: Dimentions.spaces16),
                  Text(
                    item.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.9,
                      color: AppSurfaces.muted(context),
                    ),
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
