// File: lib/presentation/widgets/ui_components.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ═════════════════════════════════════════════════════════════════════════════
// LOADING STATES
// ═════════════════════════════════════════════════════════════════════════════

/// Shimmer loading effect for skeleton loaders
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key, required this.child, this.isLoading = true});

  final Widget child;
  final bool isLoading;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = context.isDark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.white10, Colors.white24, Colors.white10]
                  : [
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ],
              stops: [0.0, 0.5 + _animation.value * 0.25, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton placeholder box
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.isDark ? Colors.white12 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Loading overlay with spinner
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black38,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!, style: context.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EMPTY STATES
// ═════════════════════════════════════════════════════════════════════════════

/// Empty state widget with icon, title, description, and optional action
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.iconSize = 72,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.primary.withOpacity(
                  context.isDark ? 0.08 : 0.10,
                ),
              ),
              child: Icon(icon, size: iconSize, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ERROR STATES
// ═════════════════════════════════════════════════════════════════════════════

/// Error state widget with retry option
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.error.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 56,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CARDS
// ═════════════════════════════════════════════════════════════════════════════

/// Modern card with optional tap handling
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Metric/stat card for displaying values
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.unit,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? unit;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppTheme.primary,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: context.textTheme.labelMedium),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: context.textTheme.headlineSmall),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit!, style: context.textTheme.labelMedium),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NAVIGATION
// ═════════════════════════════════════════════════════════════════════════════

/// Bottom pill navigation bar (as seen in testapp)
class PillBottomNav extends StatelessWidget {
  const PillBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PillNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final active = currentIndex == i;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (active)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(
                            context.isDark ? 0.20 : 0.22,
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Icon(
                          item.activeIcon ?? item.icon,
                          size: 24,
                          color: context.textPrimary,
                        ),
                      )
                    else
                      Icon(item.icon, size: 24, color: context.textTertiary),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                        color: active
                            ? context.textPrimary
                            : context.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class PillNavItem {
  const PillNavItem({required this.icon, required this.label, this.activeIcon});

  final IconData icon;
  final String label;
  final IconData? activeIcon;
}

// ═════════════════════════════════════════════════════════════════════════════
// PROGRESS INDICATORS
// ═════════════════════════════════════════════════════════════════════════════

/// Step progress indicator (as seen in registration flow)
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.showLabels = true,
  });

  final int totalSteps;
  final int currentStep;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (i) {
            final isActive = i <= currentStep;
            final isCurrent = i == currentStep;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 8),
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : context.borderColor,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            blurRadius: 10,
                            color: AppTheme.primary.withOpacity(0.35),
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
        if (showLabels) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1}',
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text('Step $totalSteps', style: context.textTheme.labelSmall),
            ],
          ),
        ],
      ],
    );
  }
}

/// Page indicator dots (for onboarding)
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 34 : 10,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary
                : AppTheme.primary.withOpacity(context.isDark ? 0.30 : 0.40),
            borderRadius: BorderRadius.circular(99),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      blurRadius: 14,
                      color: AppTheme.primary.withOpacity(0.55),
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// AVATARS
// ═════════════════════════════════════════════════════════════════════════════

/// Circle avatar with initials
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 46,
    this.backgroundColor,
    this.textColor,
  });

  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1)
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            backgroundColor ??
            AppTheme.primary.withOpacity(context.isDark ? 0.14 : 0.18),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w900,
          color:
              textColor ??
              (context.isDark ? AppTheme.primary : AppTheme.textPrimaryLight),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BUTTONS
// ═════════════════════════════════════════════════════════════════════════════

/// Primary action button with icon
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isStadium = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isStadium;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: isStadium
              ? const StadiumBorder()
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 10),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Action button (as seen in patient details)
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FORM COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

/// Gender segment selector (as seen in registration)
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    this.value,
    this.selectedGender,
    required this.onChanged,
  });

  final String? value;
  final String? selectedGender;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = ['Male', 'Female', 'Other'];
    final currentValue = selectedGender ?? value ?? 'Male';

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = opt == currentValue;

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary.withOpacity(
                          context.isDark ? 0.22 : 0.15,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppTheme.primary : Colors.transparent,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: selected
                        ? (context.isDark
                              ? AppTheme.primary
                              : AppTheme.textPrimaryLight)
                        : context.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Form field label
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    this.label,
    this.text,
    this.required = false,
    this.isRequired = false,
  });

  final String? label;
  final String? text;
  final bool required;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? text ?? '';
    final showRequired = required || isRequired;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            displayLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: context.textPrimary,
            ),
          ),
          if (showRequired) ...[
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═════════════════════════════════════════════════════════════════════════════

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title, style: context.textTheme.titleMedium)),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DATE CHIPS
// ═════════════════════════════════════════════════════════════════════════════

/// Date selection chip (as seen in appointments)
class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.day,
    required this.date,
    required this.isActive,
    required this.onTap,
  });

  final String day;
  final int date;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isActive ? AppTheme.primary : context.cardColor,
          border: Border.all(
            color: isActive ? Colors.transparent : context.borderColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isActive
                    ? AppTheme.textPrimaryLight
                    : context.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$date',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isActive
                    ? AppTheme.textPrimaryLight
                    : context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATUS CHIPS
// ═════════════════════════════════════════════════════════════════════════════

/// Status badge/chip
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  factory StatusChip.pending() =>
      const StatusChip(label: 'Pending', color: AppTheme.warning);

  factory StatusChip.confirmed() =>
      const StatusChip(label: 'Confirmed', color: AppTheme.success);

  factory StatusChip.cancelled() =>
      const StatusChip(label: 'Cancelled', color: AppTheme.error);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
