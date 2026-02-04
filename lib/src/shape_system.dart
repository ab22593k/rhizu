import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widget_previews.dart';

/// Material 3 Shape System Specs.
///
/// See: specs/shape_system.md
class ShapeScale {
  const ShapeScale._();

  static const double none = 0.0;
  static const double extraSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double largeIncreased = 20.0;
  static const double extraLarge = 28.0;
  static const double extraLargeIncreased = 32.0;
  static const double extraExtraLarge = 48.0;

  /// Represents the 'Full' token (50% of height).
  /// In Flutter, using a very large radius (like 1000 or infinity)
  /// with BorderRadius.circular often achieves the stadium/pill effect.
  static const double full = double.infinity;
}

/// Material 3 Expressive Shapes (Assets).
class ExpressiveShapes {
  const ExpressiveShapes._();

  static const String _basePath = 'assets/shapes';

  static const String arch = '$_basePath/material_shape_arch.svg';
  static const String arrow = '$_basePath/material_shape_arrow.svg';
  static const String boom = '$_basePath/material_shape_boom.svg';
  static const String bun = '$_basePath/material_shape_bun.svg';
  static const String burst = '$_basePath/material_shape_burst.svg';
  static const String circle = '$_basePath/material_shape_circle.svg';
  static const String clover4 = '$_basePath/material_shape_clover_4.svg';
  static const String clover8 = '$_basePath/material_shape_clover_8.svg';
  static const String cookie12 = '$_basePath/material_shape_cookie_12.svg';
  static const String cookie4 = '$_basePath/material_shape_cookie_4.svg';
  static const String cookie6 = '$_basePath/material_shape_cookie_6.svg';
  static const String cookie7 = '$_basePath/material_shape_cookie_7.svg';
  static const String cookie9 = '$_basePath/material_shape_cookie_9.svg';
  static const String diamond = '$_basePath/material_shape_diamond.svg';
  static const String fan = '$_basePath/material_shape_fan.svg';
  static const String flower = '$_basePath/material_shape_flower.svg';
  static const String gem = '$_basePath/material_shape_gem.svg';
  static const String ghostish = '$_basePath/material_shape_ghostish.svg';
  static const String heart = '$_basePath/material_shape_heart.svg';
  static const String hexagon = '$_basePath/material_shape_hexagon.svg';
  static const String oval = '$_basePath/material_shape_oval.svg';
  static const String pentagon = '$_basePath/material_shape_pentagon.svg';
  static const String pill = '$_basePath/material_shape_pill.svg';
  static const String pixelCircle =
      '$_basePath/material_shape_pixel_circle.svg';
  static const String pixelTriangle =
      '$_basePath/material_shape_pixel_triangle.svg';
  static const String puffy = '$_basePath/material_shape_puffy.svg';
  static const String puffyDiamond =
      '$_basePath/material_shape_puffy_diamond.svg';
  static const String semicircle = '$_basePath/material_shape_semicircle.svg';
  static const String slantedSquare =
      '$_basePath/material_shape_slanted_square.svg';
  static const String softBoom = '$_basePath/material_shape_soft_boom.svg';
  static const String softBurst = '$_basePath/material_shape_soft_burst.svg';
  static const String square = '$_basePath/material_shape_square.svg';
  static const String sunny = '$_basePath/material_shape_sunny.svg';
  static const String triangle = '$_basePath/material_shape_triangle.svg';
  static const String verySunny = '$_basePath/material_shape_very_sunny.svg';
}

/// A helper widget to preview shapes.
class ShapePreview extends StatelessWidget {
  final String? shapeAsset;
  final double? radius;
  final Widget? child;

  const ShapePreview({super.key, this.shapeAsset, this.radius, this.child});

  @override
  Widget build(BuildContext context) {
    if (shapeAsset != null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(color: const Color(0xFFE0E0E0)),
        child: ClipPath(
          child: Stack(
            children: [
              SvgPicture.asset(
                shapeAsset!,
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6750A4),
                  BlendMode.srcIn,
                ),
                package: 'rhizu',
              ),
              if (child != null) Center(child: child),
            ],
          ),
        ),
      );
    }

    if (radius != null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF6750A4),
          borderRadius: BorderRadius.circular(radius!),
        ),
        child: child != null ? Center(child: child) : null,
      );
    }

    return const SizedBox();
  }
}

@Preview()
Widget previewShape() {
  return const Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      ShapePreview(shapeAsset: ExpressiveShapes.flower),
      ShapePreview(shapeAsset: ExpressiveShapes.burst),
      ShapePreview(shapeAsset: ExpressiveShapes.heart),
      ShapePreview(shapeAsset: ExpressiveShapes.diamond),
      ShapePreview(shapeAsset: ExpressiveShapes.boom),
      ShapePreview(shapeAsset: ExpressiveShapes.clover4),
      ShapePreview(shapeAsset: ExpressiveShapes.pixelCircle),
      ShapePreview(shapeAsset: ExpressiveShapes.sunny),
    ],
  );
}
