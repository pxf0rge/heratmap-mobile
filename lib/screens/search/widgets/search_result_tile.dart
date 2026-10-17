import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';

class SearchResultTile extends StatelessWidget {
  final FactoryModel factory;
  final VoidCallback onTap;
  final String phaseName;

  const SearchResultTile({
    super.key,
    required this.factory,
    required this.onTap,
    this.phaseName = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Dimentions.spaces12),
      child: Row(
        children: [
          factory.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(Dimentions.radius12),
                  child: Image.network(
                    factory.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => AppIconBox(
                      icon: Icons.factory_rounded,
                      size: 48,
                      iconSize: 22,
                    ),
                  ),
                )
              : AppIconBox(
                  icon: Icons.factory_rounded,
                  size: 48,
                  iconSize: 22,
                ),
          const SizedBox(width: Dimentions.spaces12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        factory.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!factory.isActive)
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: StatusColors.redLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppStrings.inactive.tr,
                          style: const TextStyle(
                            fontSize: 10,
                            color: StatusColors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (factory.category.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    factory.category,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (factory.lotNumber.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    '${AppStrings.lotNumberLabel.tr}: ${factory.lotNumber}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppSurfaces.muted(context),
                    ),
                  ),
                ],
                if (factory.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    factory.address,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (phaseName.isNotEmpty) ...[
            const SizedBox(width: Dimentions.spaces8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimentions.spaces8,
                vertical: Dimentions.spaces4,
              ),
              decoration: BoxDecoration(
                color: AppSurfaces.primarySoft(context),
                borderRadius: BorderRadius.circular(Dimentions.radius8),
              ),
              child: Text(
                phaseName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
