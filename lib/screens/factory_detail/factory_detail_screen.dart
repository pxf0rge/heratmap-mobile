import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/working_hours.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/factory_detail/controller/factory_detail_controller.dart';
import 'package:heratmap/screens/factory_detail/widgets/detail_info_row.dart';
import 'package:heratmap/screens/factory_detail/widgets/factory_gallery.dart';
import 'package:heratmap/screens/factory_detail/widgets/navigation_target_sheet.dart';
import 'package:heratmap/screens/factory_detail/widgets/working_status_badge.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_button.dart';

class FactoryDetailScreen extends StatelessWidget {
  const FactoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FactoryDetailController>();
    final factory = ctrl.factory;
    final theme = Theme.of(context);

    final surface = AppSurfaces.card(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: surface,
            foregroundColor: theme.colorScheme.onSurface,
            leading: Padding(
              padding: const EdgeInsets.all(Dimentions.spaces6),
              child: Semantics(
                button: true,
                label: AppStrings.cancel.tr,
                child: _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Get.back(),
                ),
              ),
            ),
            actions: [
              if (ctrl.canBeFavorite)
                Padding(
                  padding: const EdgeInsets.only(left: Dimentions.spaces4),
                  child: Obx(
                    () => Semantics(
                      button: true,
                      label: (ctrl.isFavorite
                              ? AppStrings.removeFromFavorites
                              : AppStrings.addToFavorites)
                          .tr,
                      child: _CircleIconButton(
                        icon: ctrl.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: ctrl.isFavorite
                            ? StatusColors.red
                            : Colors.white,
                        onTap: () => _showMessageKey(
                          factory.name,
                          ctrl.toggleFavorite(),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: Dimentions.spaces8),
                child: Semantics(
                  button: true,
                  label: AppStrings.share.tr,
                  child: _CircleIconButton(
                    icon: Icons.share_rounded,
                    onTap: () =>
                        _run(context, ctrl.shareFactory, title: factory.name),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: FactoryGallery(images: factory.imageUrls),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -Dimentions.radius24),
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  Dimentions.spaces20,
                  Dimentions.spaces24,
                  Dimentions.spaces20,
                  Dimentions.spaces32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factory.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Dimentions.spaces12),
                    Wrap(
                      spacing: Dimentions.spaces8,
                      runSpacing: Dimentions.spaces8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (factory.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimentions.spaces12,
                              vertical: Dimentions.spaces4,
                            ),
                            decoration: BoxDecoration(
                              color: AppSurfaces.primarySoft(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: PrimaryColors.p200.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              factory.category,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (ctrl.hasWorkingHoursText)
                          Obx(
                            () => WorkingStatusBadge(
                              kind: ctrl.openStatus.value?.kind ??
                                  OpenStatusKind.unknown,
                              label: ctrl.statusText,
                              detail: ctrl.statusDetail,
                              semanticsLabel: ctrl.statusSemantics,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Dimentions.spaces16),
                    Container(
                      padding: const EdgeInsets.all(Dimentions.spaces12),
                      decoration: BoxDecoration(
                        color: AppSurfaces.softFill(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppSurfaces.border(context)),
                      ),
                      child: Column(
                        children: [
                          DetailInfoRow(
                            icon: Icons.grid_view_rounded,
                            label: AppStrings.phaseLabel.tr,
                            value: ctrl.phaseLabel,
                          ),
                          if (factory.lotNumber.isNotEmpty) ...[
                            const SizedBox(height: Dimentions.spaces8),
                            DetailInfoRow(
                              icon: Icons.pin_outlined,
                              label: 'نمره/قطعه',
                              value: factory.lotNumber,
                            ),
                          ],
                          const SizedBox(height: Dimentions.spaces8),
                          DetailInfoRow(
                            icon: Icons.phone_outlined,
                            label: AppStrings.phone.tr,
                            value: factory.phone.isNotEmpty
                                ? factory.phone
                                : '—',
                            onTap: ctrl.hasValidPhone
                                ? () => _run(
                                    context,
                                    ctrl.callPhone,
                                    title: factory.name,
                                  )
                                : null,
                            valueColor:
                                ctrl.hasValidPhone ? primary : null,
                            trailing: ctrl.hasValidPhone
                                ? _TrailingAction(
                                    icon: Icons.copy_rounded,
                                    label: AppStrings.copyPhone.tr,
                                    onTap: () => _run(
                                      context,
                                      ctrl.copyPhone,
                                      title: factory.name,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: Dimentions.spaces8),
                          DetailInfoRow(
                            icon: Icons.location_on_outlined,
                            label: AppStrings.address.tr,
                            value: factory.address.isNotEmpty
                                ? factory.address
                                : '—',
                          ),
                          const SizedBox(height: Dimentions.spaces8),
                          DetailInfoRow(
                            icon: Icons.access_time_rounded,
                            label: AppStrings.workingHours.tr,
                            value: ctrl.workingHoursLabel,
                          ),
                          if (factory.websiteUrl.isNotEmpty) ...[
                            const SizedBox(height: Dimentions.spaces8),
                            DetailInfoRow(
                              icon: Icons.language_rounded,
                              label: AppStrings.supportWebsite.tr,
                              value: factory.websiteUrl,
                              onTap: () => _run(
                                context,
                                ctrl.openWebsite,
                                title: factory.name,
                              ),
                              valueColor: primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (factory.description.isNotEmpty) ...[
                      const SizedBox(height: Dimentions.spaces16),
                      Text(
                        AppStrings.description.tr,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Dimentions.spaces8),
                      Text(
                        factory.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.8,
                          color: AppSurfaces.muted(context),
                        ),
                      ),
                    ],

                    const SizedBox(height: Dimentions.spaces24),

                    // Action buttons
                    AppButton(
                      title: AppStrings.navigate.tr,
                      onTap: () => _chooseNavigation(context, ctrl),
                      containerWidth: double.infinity,
                      enable: ctrl.canNavigate,
                      iconWidget: const Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: Dimentions.icon20,
                      ),
                    ),

                    if (!ctrl.canNavigate) ...[
                      const SizedBox(height: Dimentions.spaces8),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: Dimentions.icon16,
                            color: NeutralColors.n400,
                          ),
                          const SizedBox(width: Dimentions.spaces6),
                          Expanded(
                            child: Text(
                              (ctrl.navigationBlockedReason ?? '').tr,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: NeutralColors.n400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: Dimentions.spaces12),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            title: AppStrings.call.tr,
                            onTap: () => _run(
                              context,
                              ctrl.callPhone,
                              title: factory.name,
                            ),
                            buttonMode: ButtonModeEnum.outlined,
                            enable: ctrl.hasValidPhone,
                            iconWidget: const Icon(
                              Icons.phone_rounded,
                              size: Dimentions.icon20,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimentions.spaces12),
                        Expanded(
                          child: AppButton(
                            title: AppStrings.share.tr,
                            onTap: () => _run(
                              context,
                              ctrl.shareFactory,
                              title: factory.name,
                            ),
                            buttonMode: ButtonModeEnum.outlined,
                            iconWidget: const Icon(
                              Icons.share_rounded,
                              size: Dimentions.icon20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _chooseNavigation(
  BuildContext context,
  FactoryDetailController ctrl,
) async {
  final target = await showNavigationTargetSheet(context);
  if (target == null || !context.mounted) return;

  await _run(
    context,
    () => ctrl.openNavigation(target),
    title: ctrl.factory.name,
  );
}

Future<void> _run(
  BuildContext context,
  Future<String?> Function() action, {
  required String title,
}) async {
  final messageKey = await action();
  if (messageKey == null || !context.mounted) return;
  _showMessageKey(title, messageKey);
}

void _showMessageKey(String title, String? messageKey) {
  if (messageKey == null) return;
  Get.snackbar(
    title,
    messageKey.tr,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(Dimentions.spaces16),
    duration: const Duration(seconds: 3),
  );
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimentions.buttonHeight48,
      height: Dimentions.buttonHeight48,
      child: Material(
        color: Colors.black.withValues(alpha: 0.25),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _TrailingAction extends StatelessWidget {
  const _TrailingAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: Dimentions.buttonHeight48,
        height: Dimentions.buttonHeight48,
        child: IconButton(
          tooltip: label,
          onPressed: onTap,
          icon: Icon(
            icon,
            size: Dimentions.icon20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
