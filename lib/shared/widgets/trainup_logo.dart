import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Variantes da logo do TrainUp.
enum TrainUpLogoVariant {
  /// Apenas o ícone (selo azul-marinho com o "T" em forma de barra/halteres).
  icon,

  /// Ícone + wordmark "TrainUp" na horizontal.
  horizontal,
}

/// Widget de logo do TrainUp, baseado nos assets em `assets/branding/`.
class TrainUpLogo extends StatelessWidget {
  const TrainUpLogo({
    super.key,
    this.variant = TrainUpLogoVariant.horizontal,
    this.height = 64,
  });

  final TrainUpLogoVariant variant;
  final double height;

  @override
  Widget build(BuildContext context) {
    final asset = switch (variant) {
      TrainUpLogoVariant.icon => 'assets/branding/icon.svg',
      TrainUpLogoVariant.horizontal => 'assets/branding/logo_horizontal.svg',
    };

    return SvgPicture.asset(asset, height: height);
  }
}
