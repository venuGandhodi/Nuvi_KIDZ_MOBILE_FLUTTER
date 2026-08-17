import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Hand-traced outline icons matching the design handoff's custom SVGs
/// (simple 2px-stroke line art, not Material/emoji glyphs) — used
/// specifically where the design calls out a distinctive custom shape:
/// the bottom nav icons, header profile icon, and empty-state icon.
class NuviIcons {
  static Widget home({required Color color, double size = 21}) {
    return SvgPicture.string(
      '<svg width="24" height="24" viewBox="0 0 24 24" fill="none">'
      '<path d="M4 11.5L12 4l8 7.5" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M6 10v9a1 1 0 0 0 1 1h4v-6h2v6h4a1 1 0 0 0 1-1v-9" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
      '</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  static Widget orders({required Color color, double size = 23}) {
    return SvgPicture.string(
      '<svg width="24" height="24" viewBox="0 0 24 24" fill="none">'
      '<rect x="5" y="3" width="14" height="18" rx="2" stroke="#000" stroke-width="1.8"/>'
      '<path d="M9 8h6M9 12h6M9 16h3" stroke="#000" stroke-width="1.8" stroke-linecap="round"/>'
      '</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  static Widget cart({required Color color, double size = 23}) {
    return SvgPicture.string(
      '<svg width="24" height="24" viewBox="0 0 24 24" fill="none">'
      '<path d="M3 4h2l2.4 12.4a2 2 0 0 0 2 1.6h8.2a2 2 0 0 0 2-1.6L21 8H6" stroke="#000" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
      '<circle cx="10" cy="21" r="1.4" fill="#000"/>'
      '<circle cx="17" cy="21" r="1.4" fill="#000"/>'
      '</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  static Widget wishlist({required Color color, double size = 23}) {
    return SvgPicture.string(
      '<svg width="24" height="24" viewBox="0 0 24 24" fill="none">'
      '<path d="M12 20.2s-7.5-4.6-9.5-9.1C1.2 8 2.6 4.8 5.8 4.1c2-.4 3.9.6 5 2.3 1.1-1.7 3-2.7 5-2.3 3.2.7 4.6 3.9 3.3 7-2 4.5-9.1 9.1-9.1 9.1z" stroke="#000" stroke-width="1.8" stroke-linejoin="round"/>'
      '</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  static Widget person({required Color color, double size = 16}) {
    return SvgPicture.string(
      '<svg width="24" height="24" viewBox="0 0 24 24" fill="none">'
      '<circle cx="12" cy="8" r="4" stroke="#000" stroke-width="1.8"/>'
      '<path d="M4 20c0-3.5 3.6-6 8-6s8 2.5 8 6" stroke="#000" stroke-width="1.8" stroke-linecap="round"/>'
      '</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  static Widget searchOff({required Color color, double size = 46}) {
    return SvgPicture.string(
      '<svg width="24" height="24" viewBox="0 0 24 24" fill="none">'
      '<circle cx="10" cy="10" r="6.5" stroke="#000" stroke-width="1.6"/>'
      '<path d="M15 15l5 5M8 8l4 4M12 8l-4 4" stroke="#000" stroke-width="1.6" stroke-linecap="round"/>'
      '</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
