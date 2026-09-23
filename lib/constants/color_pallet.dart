import 'package:flutter/material.dart';

/// Raw, theme-agnostic color values. These never change based on
/// light/dark mode — AppColors decides which shade applies when.

class NeutralColors {
  static const n50 = Color(0xFFF9FAFB);
  static const n100 = Color(0xFFF3F4F6);
  static const n200 = Color(0xFFE5E7EB);
  static const n300 = Color(0xFFD1D5DB);
  static const n400 = Color(0xFF9CA3AF);
  static const n500 = Color(0xFF6B7280);
  static const n600 = Color(0xFF4B5563);
  static const n700 = Color(0xFF374151);
  static const n800 = Color(0xFF1F2937);
  static const n900 = Color(0xFF111827);
  static const n950 = Color(0xFF030712);
}

class PrimaryColors {
  static const p50 = Color(0xFFEAF7FF);
  static const p100 = Color(0xFFCFECFF);
  static const p200 = Color(0xFFAADFFF);
  static const p300 = Color(0xFF6FCDFF);
  static const p400 = Color(0xFF2CB1FF);
  static const p500 = Color(0xFF008FFF);
  static const p600 = Color(0xFF007EFF);
  static const p700 = Color(0xFF0071FF);
  static const p800 = Color(0xFF005DE0);
  static const p900 = Color(0xFF004CAE);
  static const p950 = Color(0xFF033782);
}

class InfoColors {
  static const i50 = Color(0xFFEFF6FF);
  static const i100 = Color(0xFFDBEAFE);
  static const i200 = Color(0xFFBFDBFE);
  static const i300 = Color(0xFF93C5FD);
  static const i400 = Color(0xFF60A5FA);
  static const i500 = Color(0xFF3B82F6);
  static const i600 = Color(0xFF2563EB);
  static const i700 = Color(0xFF1D4ED8);
  static const i800 = Color(0xFF1E40AF);
  static const i900 = Color(0xFF1E3A8A);
  static const i950 = Color(0xFF172554);
}

class SuccessColors {
  static const s50 = Color(0xFFECFDF5);
  static const s100 = Color(0xFFD1FAE5);
  static const s200 = Color(0xFFA7F3D0);
  static const s300 = Color(0xFF6EE7B7);
  static const s400 = Color(0xFF34D399);
  static const s500 = Color(0xFF10B981);
  static const s600 = Color(0xFF059669);
  static const s700 = Color(0xFF047857);
  static const s800 = Color(0xFF065F46);
  static const s900 = Color(0xFF064E3B);
  static const s950 = Color(0xFF022C22);
}

class WarningColors {
  static const w50 = Color(0xFFFFFBEB);
  static const w100 = Color(0xFFFEF3C7);
  static const w200 = Color(0xFFFDE68A);
  static const w300 = Color(0xFFFCD34D);
  static const w400 = Color(0xFFFBBF24);
  static const w500 = Color(0xFFF59E0B);
  static const w600 = Color(0xFFD97706);
  static const w700 = Color(0xFFB45309);
  static const w800 = Color(0xFF92400E);
  static const w900 = Color(0xFF78350F);
  static const w950 = Color(0xFF451A03);
}

class ErrorColors {
  static const e50 = Color(0xFFFEF2F2);
  static const e100 = Color(0xFFFEE2E2);
  static const e200 = Color(0xFFFECACA);
  static const e300 = Color(0xFFFCA5A5);
  static const e400 = Color(0xFFF87171);
  static const e500 = Color(0xFFEF4444);
  static const e600 = Color(0xFFDC2626);
  static const e700 = Color(0xFFB91C1C);
  static const e800 = Color(0xFF991B1B);
  static const e900 = Color(0xFF7F1D1D);
  static const e950 = Color(0xFF450A0A);
}

/// One-off / static-only colors that never adapt to theme.
class GradientColors {
  static const neutral1 = Color(0xFFE5E7EB);
  static const neutral2 = Color(0xFFD1D5DB);
  static const neutral3 = Color(0xFF9CA3AF);

  static const primaryStart = Color(0xFF007EFF);
  static const primaryEnd = Color(0xFF2CB1FF);

  static const info1 = Color(0xFFBFDBFE);
  static const info2 = Color(0xFF93C5FD);
  static const info3 = Color(0xFF60A5FA);

  static const success1 = Color(0xFFA7F3D0);
  static const success2 = Color(0xFF6EE7B7);
  static const success3 = Color(0xFF34D399);

  static const warning1 = Color(0xFFFDE68A);
  static const warning2 = Color(0xFFFCD34D);
  static const warning3 = Color(0xFFFBBF24);

  static const declined1 = Color(0xFFFECACA);
  static const declined2 = Color(0xFFFCA5A5);
  static const declined3 = Color(0xFFF87171);
}

class MiscColors {
  static const greysummary = Color(0xFFCFE0FF);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const inProgress = Color(0xFF2F6FE6);
}
