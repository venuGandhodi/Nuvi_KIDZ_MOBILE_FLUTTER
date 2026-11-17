import 'package:flutter/material.dart';

/// NUVI KIDZ colour tokens, matched to the store's mobile website.
///
/// Festival-aware accents (gold, peach, lavender, sage) are resolved per
/// context through `context.nuvi` (see nuvi_theme_ext.dart); the constants
/// here are the day-mode defaults.
class NuviColors {
  // ── Core palette (day mode) ───────────────────────────────────────────
  static const Color cream = Color(0xFFFFF9F3);
  static const Color ink = Color(0xFF30453E);
  static const Color sage = Color(0xFF9AA38C);
  static const Color peach = Color(0xFFF2B49A);
  static const Color gold = Color(0xFFEAB83D);
  static const Color skyBlue = Color(0xFFDDEEF7);
  static const Color lavender = Color(0xFFD9D2E9);
  static const Color moonCream = Color(0xFFF6E8CE);
  static const Color nightGreen = Color(0xFF172D2A);
  static const Color deepSpace = Color(0xFF102622);
  static const Color leaf = Color(0xFF5F7D3C);
  static const Color leafDark = Color(0xFF4E6A30);
  static const Color pdpInk = Color(0xFF1F3A2A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardPdp = Color(0xFFFFFCF8);
  static const Color line = Color(0x1F30453E);
  static const Color sale = Color(0xFFD9534F);
  static const Color newBadge = Color(0xFFE2452B);
  static const Color white = Color(0xFFFFFFFF);

  // Soft fills derived from the palette.
  static const Color goldSoft = Color(0xFFFCEFCB);
  static const Color sageSoft = Color(0xFFEDF0E6);
  static const Color peachSoft = Color(0xFFFCE9E0);
  static const Color saleSoft = Color(0xFFFBE4E3);
  static const Color amber = Color(0xFFB7860B);
  static const Color inkMuted = Color(0xFF5E6B64);
  static const Color inkFaint = Color(0xFF8A938E);
  static const Color photoButton = Color(0xEBFFFFFF);
  static const Color scrim = Color(0x66172D2A);
  static const Color mist = Color(0xFFE9ECF1);
  static const Color silver = Color(0xFFA9AFB8);

  // My Orders card.
  static const Color orderCard = Color(0xFFFFFDFA);
  static const Color orderBorder = Color(0xFFEEE4D8);

  // ── Semantic aliases (kept so every existing screen resolves) ─────────
  static const Color brandCream = cream;
  static const Color brandSage = sage;
  static const Color brandPeach = peach;
  static const Color brandMustard = gold;

  static const Color primary = ink;
  static const Color primaryContainer = nightGreen;
  static const Color onPrimary = cream;

  static const Color secondary = gold;
  static const Color secondaryContainer = goldSoft;
  static const Color onSecondary = nightGreen;

  static const Color surface = cream;
  static const Color surfaceVariant = card;
  static const Color onSurface = ink;

  static const Color accent = sale;

  static const Color error = sale;
  static const Color success = leaf;

  static const Color border = line;
  static const Color borderStrong = Color(0x2E30453E);

  static const Color textSecondary = inkMuted;
  static const Color textTertiary = Color(0xFF6B6A62);

  static const Color couponBackground = goldSoft;
  static const Color couponBorder = gold;
  static const Color couponText = nightGreen;

  static const Color fieldBackground = card;

  // ── Night mode ────────────────────────────────────────────────────────
  static const Color nightCard = Color(0x14FFF9F3);
  static const Color nightBorder = Color(0x2EF6E8CE);
}

/// Bag drawer + bag screen palette.
class NuviBagColors {
  static const Color ink = Color(0xFF2F3A2A);
  static const Color olive = Color(0xFF44532F);
  static const Color sage = Color(0xFF7B8D60);
  static const Color sageDark = Color(0xFF6A7C50);
  static const Color line = Color(0xFFECE2D3);
  static const Color card = Color(0xFFFFFCF7);
  static const Color muted = Color(0xFF6B6A62);
  static const Color coral = Color(0xFFC4502F);
  static const Color green = Color(0xFF4D7A37);

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBF5EC), Color(0xFFFBF7F1)],
  );
}

enum NuviTile { sage, peach, gold, mint, lavender, rose }

/// 135° tile gradients for category cards, skeletons and soft panels.
class NuviGradients {
  static const Map<NuviTile, List<Color>> _tiles = {
    NuviTile.sage: [Color(0xFFEEF3E0), Color(0xFFDCE7C6)],
    NuviTile.peach: [Color(0xFFFDEEE6), Color(0xFFF9D9CB)],
    NuviTile.gold: [Color(0xFFFEF3DD), Color(0xFFFADDB0)],
    NuviTile.mint: [Color(0xFFE5F3EB), Color(0xFFCDE8D9)],
    NuviTile.lavender: [Color(0xFFF1ECF8), Color(0xFFDED4EF)],
    NuviTile.rose: [Color(0xFFFDE8EC), Color(0xFFF6CDD5)],
  };

  static List<Color> colors(NuviTile tile) => _tiles[tile]!;

  static LinearGradient tile(NuviTile tile) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _tiles[tile]!,
  );

  /// Stable tint per label: Girls → rose, Boys → mint, otherwise cycled.
  static NuviTile forLabel(String label, int index) {
    final l = label.toLowerCase();
    if (l.contains('girl')) return NuviTile.rose;
    if (l.contains('boy')) return NuviTile.mint;
    if (l.contains('baby') || l.contains('newborn')) return NuviTile.peach;
    if (l.contains('sale')) return NuviTile.gold;
    const order = [
      NuviTile.sage,
      NuviTile.peach,
      NuviTile.gold,
      NuviTile.mint,
      NuviTile.lavender,
      NuviTile.rose,
    ];
    return order[index % order.length];
  }
}

/// Occasion tones (tint / blob / accent).
class NuviTone {
  final Color tint;
  final Color blob;
  final Color accent;

  const NuviTone(this.tint, this.blob, this.accent);

  static const gold = NuviTone(
    Color(0xFFFBF0D9),
    Color(0xFFF5D58C),
    Color(0xFFD48A12),
  );
  static const pink = NuviTone(
    Color(0xFFFDE9EB),
    Color(0xFFF6BCC4),
    Color(0xFFD2404D),
  );
  static const sage = NuviTone(
    Color(0xFFEDF2E3),
    Color(0xFFC9DAB0),
    Color(0xFF2F5E43),
  );
  static const sky = NuviTone(
    Color(0xFFE6EFF9),
    Color(0xFFB5D1EE),
    Color(0xFF22476E),
  );
  static const peach = NuviTone(
    Color(0xFFFDECE4),
    Color(0xFFF5C9B6),
    Color(0xFFC8473A),
  );
  static const sun = NuviTone(
    Color(0xFFFDF3D8),
    Color(0xFFF7D982),
    Color(0xFFD99A06),
  );
  static const lavender = NuviTone(
    Color(0xFFEDEAF7),
    Color(0xFFD0C8EA),
    Color(0xFF26305E),
  );
  static const cream = NuviTone(
    Color(0xFFFBF1E0),
    Color(0xFFEDD6AE),
    Color(0xFFA8711E),
  );

  static const List<NuviTone> all = [
    gold,
    pink,
    sage,
    sky,
    peach,
    sun,
    lavender,
    cream,
  ];
}
