import 'package:flutter/material.dart';

/// Inter text style — the font is bundled in fonts/, so this never
/// touches the network (unlike package:google_fonts, which fetched font
/// files lazily at runtime and caused UI jank).
TextStyle inter({
  double? fontSize,
  double? height,
  FontWeight? fontWeight,
  Color? color,
  TextDecoration? decoration,
}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
      decoration: decoration,
    );

/// "Midnight Violet" — dark Material 3 ColorScheme. UI reads colors through
/// `Theme.of(context).colorScheme` roles; nothing in the views hardcodes hex.
const mindScrollDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFCFBCFF),
  onPrimary: Color(0xFF352267),
  primaryContainer: Color(0xFF4C3980),
  onPrimaryContainer: Color(0xFFE9DDFF),
  secondary: Color(0xFFC9C1DC),
  onSecondary: Color(0xFF312E3D),
  secondaryContainer: Color(0xFF484454),
  onSecondaryContainer: Color(0xFFE5DDF8),
  tertiary: Color(0xFFEFAFC6),
  onTertiary: Color(0xFF492536),
  tertiaryContainer: Color(0xFF633B4D),
  onTertiaryContainer: Color(0xFFFFD9E5),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF131318),
  onSurface: Color(0xFFE5E1E9),
  onSurfaceVariant: Color(0xFFC9C5D0),
  outline: Color(0xFF928F99),
  outlineVariant: Color(0xFF48464F),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE5E1E9),
  onInverseSurface: Color(0xFF303036),
  inversePrimary: Color(0xFF66548F),
  surfaceTint: Color(0xFFCFBCFF),
);

/// Custom colors that have no Material 3 role — only the streak chip's
/// warm accent. Access via
/// `Theme.of(context).extension<MindScrollColors>()`.
@immutable
class MindScrollColors extends ThemeExtension<MindScrollColors> {
  const MindScrollColors({
    required this.streakContainer,
    required this.onStreakContainer,
  });

  final Color streakContainer;
  final Color onStreakContainer;

  @override
  MindScrollColors copyWith({
    Color? streakContainer,
    Color? onStreakContainer,
  }) =>
      MindScrollColors(
        streakContainer: streakContainer ?? this.streakContainer,
        onStreakContainer: onStreakContainer ?? this.onStreakContainer,
      );

  @override
  MindScrollColors lerp(ThemeExtension<MindScrollColors>? other, double t) {
    if (other is! MindScrollColors) return this;
    return MindScrollColors(
      streakContainer: Color.lerp(streakContainer, other.streakContainer, t)!,
      onStreakContainer:
          Color.lerp(onStreakContainer, other.onStreakContainer, t)!,
    );
  }
}

const _mindScrollColors = MindScrollColors(
  streakContainer: Color(0xFF352319),
  onStreakContainer: Color(0xFFFF6D00),
);

/// Midnight Violet theme. Component sub-themes map to the semantic roles so
/// screens rarely need explicit colors at all.
final ThemeData mindScrollDarkTheme = () {
  final colorScheme = mindScrollDarkColorScheme.copyWith(
    surfaceContainerLowest: const Color(0xFF0D0D12),
    surfaceContainerLow: const Color(0xFF17171C),
    surfaceContainer: const Color(0xFF1D1D23),
    surfaceContainerHigh: const Color(0xFF24242B),
    surfaceContainerHighest: const Color(0xFF2F2F38),
  );

  final baseTheme = ThemeData.dark(useMaterial3: true);

  return baseTheme.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
    textTheme: baseTheme.textTheme
        .apply(
          fontFamily: 'Inter',
          fontFamilyFallback: const ['Roboto'],
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        )
        // Secondary/hint text uses onSurfaceVariant everywhere.
        .copyWith(
          bodySmall: inter(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surfaceContainerLowest,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      // primary/onPrimary come from the ColorScheme — onPrimary text, never
      // white, keeps accessible contrast on the light-violet primary.
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: colorScheme.onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      hintStyle: inter(
        fontSize: 14,
        color: colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onInverseSurface,
      ),
      actionTextColor: colorScheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
    extensions: const [_mindScrollColors],
  );
}();

/// Convenience accessor for the custom streak palette.
MindScrollColors mindScrollColors(BuildContext context) =>
    Theme.of(context).extension<MindScrollColors>() ?? _mindScrollColors;
