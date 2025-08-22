import 'package:flutter/material.dart';

/// Themed app bar for Islamic app
class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemedAppBar({
    super.key,
    this.title,
    this.titleText,
    this.centerTitle = true,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.gradient,
    this.showBackButton = true,
  });

  final Widget? title;
  final String? titleText;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Gradient? gradient;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: gradient != null
          ? BoxDecoration(gradient: gradient)
          : const BoxDecoration(),
      child: AppBar(
        title: title ??
            (titleText != null
                ? Text(
                    titleText!,
                    style: textTheme.titleLarge?.copyWith(
                      color: foregroundColor ?? colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null),
        centerTitle: centerTitle,
        leading: leading,
        actions: actions,
        automaticallyImplyLeading: showBackButton,
        backgroundColor: gradient != null
            ? Colors.transparent
            : (backgroundColor ?? colorScheme.primary),
        foregroundColor: foregroundColor ?? colorScheme.onPrimary,
        elevation: elevation ?? 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Themed card with Islamic styling
class ThemedCard extends StatelessWidget {
  const ThemedCard({
    required this.child,
    super.key,
    this.margin,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
    this.border,
    this.gradient,
    this.onTap,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardTheme = Theme.of(context).cardTheme;

    Widget cardChild = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient != null ? null : (color ?? cardTheme.color),
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        boxShadow: shadow != null
            ? [shadow!]
            : [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: elevation ?? 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      cardChild = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: cardChild,
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: cardChild,
    );
  }
}

/// Themed elevated button with Islamic styling
class ThemedElevatedButton extends StatelessWidget {
  const ThemedElevatedButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.gradient,
    this.width,
    this.height,
    this.isLoading = false,
    this.loadingText,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final bool isLoading;
  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final buttonChild = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? colorScheme.onPrimary,
                  ),
                ),
              ),
              if (loadingText != null) ...[
                const SizedBox(width: 8),
                Text(loadingText!),
              ],
            ],
          )
        : child;

    if (gradient != null) {
      return Container(
        width: width,
        height: height ?? 48,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: elevation ?? 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: Container(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Center(
                child: DefaultTextStyle(
                  style: textTheme.labelLarge?.copyWith(
                        color: foregroundColor ?? Colors.white,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(),
                  child: buttonChild,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: foregroundColor ?? colorScheme.onPrimary,
          elevation: elevation,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Themed text field with Islamic styling
class ThemedTextField extends StatelessWidget {
  const ThemedTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.fillColor,
    this.borderRadius,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      expands: expands,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? inputDecorationTheme.fillColor,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          borderSide: BorderSide(
            color: enabledBorderColor ?? colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          borderSide: BorderSide(
            color: enabledBorderColor ?? colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          borderSide: BorderSide(
            color: focusedBorderColor ?? colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Themed loading indicator
class ThemedLoadingIndicator extends StatelessWidget {
  const ThemedLoadingIndicator({
    super.key,
    this.size = 24,
    this.strokeWidth = 3,
    this.color,
    this.text,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? colorScheme.primary,
            ),
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 16),
          Text(
            text!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Themed divider with Islamic styling
class ThemedDivider extends StatelessWidget {
  const ThemedDivider({
    super.key,
    this.height,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
    this.text,
    this.textStyle,
  });

  final double? height;
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;
  final String? text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (text != null) {
      return Row(
        children: [
          if (indent != null) SizedBox(width: indent),
          Expanded(
            child: Divider(
              height: height ?? 1,
              thickness: thickness ?? 1,
              color: color ?? colorScheme.outline.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text!,
              style: textStyle ??
                  textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              height: height ?? 1,
              thickness: thickness ?? 1,
              color: color ?? colorScheme.outline.withOpacity(0.5),
            ),
          ),
          if (endIndent != null) SizedBox(width: endIndent),
        ],
      );
    }

    return Divider(
      height: height,
      thickness: thickness,
      color: color ?? colorScheme.outline.withOpacity(0.5),
      indent: indent,
      endIndent: endIndent,
    );
  }
}

/// Themed bottom sheet
class ThemedBottomSheet extends StatelessWidget {
  const ThemedBottomSheet({
    required this.child,
    super.key,
    this.title,
    this.showHandle = true,
    this.padding,
    this.backgroundColor,
    this.shape,
  });

  final Widget child;
  final String? title;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final ShapeBorder? shape;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showHandle = true,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      builder: (context) => ThemedBottomSheet(
        title: title,
        showHandle: showHandle,
        padding: padding,
        backgroundColor: backgroundColor,
        shape: shape,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          if (showHandle) ...[
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Title
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                title!,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            ThemedDivider(
              thickness: 1,
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ],

          // Content
          Flexible(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(24),
              child: child,
            ),
          ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Prayer time feature color helper
class PrayerTimeColors {
  static Color getColor(String prayer, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.green;
  }

  static Color getBackgroundColor(String prayer, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.green.shade50;
  }
}

/// Feature color helper
class FeatureColors {
  static Color getColor(String feature, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.blue;
  }
}
