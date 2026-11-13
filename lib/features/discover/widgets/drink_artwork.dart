import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/drink_recipe.dart';

class DrinkArtwork extends StatelessWidget {
  const DrinkArtwork({required this.style, this.backgroundColor, super.key});

  final DrinkArtworkStyle style;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(style);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 14,
              right: 18,
              child: _Circle(
                color: palette.accent.withValues(alpha: 0.15),
                size: 54,
              ),
            ),
            Positioned(
              left: 18,
              bottom: 14,
              child: _Circle(
                color: palette.accent.withValues(alpha: 0.12),
                size: 34,
              ),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _GlassPainter(palette: palette),
            ),
            Positioned(
              top: 26,
              right: 28,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 7,
                  height: 54,
                  decoration: BoxDecoration(
                    color: palette.straw,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 38,
              right: 26,
              child: _Circle(color: palette.garnish, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ArtworkPalette {
  const _ArtworkPalette({
    required this.background,
    required this.drink,
    required this.accent,
    required this.garnish,
    this.straw = AppColors.white,
  });

  final Color background;
  final Color drink;
  final Color accent;
  final Color garnish;
  final Color straw;
}

_ArtworkPalette _paletteFor(DrinkArtworkStyle style) => switch (style) {
  DrinkArtworkStyle.peachTea => const _ArtworkPalette(
    background: Color(0xFFFFE9DF),
    drink: Color(0xFFE99A65),
    accent: Color(0xFFF47F91),
    garnish: Color(0xFFF8C75E),
  ),
  DrinkArtworkStyle.mojito => const _ArtworkPalette(
    background: Color(0xFFE6F2D8),
    drink: Color(0xFFA8D89A),
    accent: Color(0xFF75B87A),
    garnish: Color(0xFF74AD55),
  ),
  DrinkArtworkStyle.lemonTea => const _ArtworkPalette(
    background: Color(0xFFFFF1C9),
    drink: Color(0xFFE9B746),
    accent: Color(0xFFEFAE70),
    garnish: Color(0xFFF8D46B),
  ),
  DrinkArtworkStyle.mango => const _ArtworkPalette(
    background: Color(0xFFFFE8C3),
    drink: Color(0xFFFFB84F),
    accent: Color(0xFFEFAE70),
    garnish: Color(0xFFF8D46B),
  ),
  DrinkArtworkStyle.latte => const _ArtworkPalette(
    background: Color(0xFFF0E1D2),
    drink: Color(0xFF9B684A),
    accent: Color(0xFFCFA987),
    garnish: Color(0xFFF1D8B9),
    straw: Color(0xFFF1D8B9),
  ),
  DrinkArtworkStyle.walnutMilk => const _ArtworkPalette(
    background: Color(0xFFE9E6D8),
    drink: Color(0xFFEAD8B9),
    accent: Color(0xFFAAA27C),
    garnish: Color(0xFF90714E),
  ),
  DrinkArtworkStyle.berry => const _ArtworkPalette(
    background: Color(0xFFE9E2F3),
    drink: Color(0xFF7861A8),
    accent: Color(0xFF9E84C8),
    garnish: Color(0xFF41325F),
  ),
  DrinkArtworkStyle.matcha => const _ArtworkPalette(
    background: Color(0xFFE8EFD9),
    drink: Color(0xFF819D53),
    accent: Color(0xFFA5C94A),
    garnish: Color(0xFF60783D),
  ),
  DrinkArtworkStyle.strawberryYogurt => const _ArtworkPalette(
    background: Color(0xFFFFE6E9),
    drink: Color(0xFFE98B9B),
    accent: Color(0xFFF47F91),
    garnish: Color(0xFFC65363),
  ),
};

class _GlassPainter extends CustomPainter {
  const _GlassPainter({required this.palette});

  final _ArtworkPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.57);
    final glassWidth = size.width * 0.32;
    final glassHeight = size.height * 0.56;
    final top = center.dy - glassHeight * 0.48;
    final glass = Path()
      ..moveTo(center.dx - glassWidth / 2, top)
      ..lineTo(center.dx - glassWidth * 0.35, top + glassHeight)
      ..quadraticBezierTo(
        center.dx,
        top + glassHeight + 8,
        center.dx + glassWidth * 0.35,
        top + glassHeight,
      )
      ..lineTo(center.dx + glassWidth / 2, top)
      ..close();
    final drink = Path()
      ..moveTo(center.dx - glassWidth * 0.42, top + glassHeight * 0.43)
      ..lineTo(center.dx - glassWidth * 0.32, top + glassHeight)
      ..quadraticBezierTo(
        center.dx,
        top + glassHeight + 5,
        center.dx + glassWidth * 0.32,
        top + glassHeight,
      )
      ..lineTo(center.dx + glassWidth * 0.42, top + glassHeight * 0.43)
      ..close();

    canvas.drawShadow(glass, AppColors.navy.withValues(alpha: 0.13), 12, true);
    canvas.drawPath(
      glass,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill,
    );
    canvas.save();
    canvas.clipPath(glass);
    canvas.drawPath(
      drink,
      Paint()
        ..shader = LinearGradient(
          colors: [palette.drink.withValues(alpha: 0.65), palette.drink],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    final icePaint = Paint()..color = AppColors.white.withValues(alpha: 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx - glassWidth * 0.2,
            top + glassHeight * 0.55,
          ),
          width: glassWidth * 0.18,
          height: glassHeight * 0.12,
        ),
        const Radius.circular(4),
      ),
      icePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx + glassWidth * 0.12,
            top + glassHeight * 0.72,
          ),
          width: glassWidth * 0.18,
          height: glassHeight * 0.12,
        ),
        const Radius.circular(4),
      ),
      icePaint,
    );
    canvas.restore();
    canvas.drawPath(
      glass,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(center.dx - glassWidth * 0.53, top),
      Offset(center.dx + glassWidth * 0.53, top),
      Paint()
        ..color = AppColors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) =>
      oldDelegate.palette != palette;
}
