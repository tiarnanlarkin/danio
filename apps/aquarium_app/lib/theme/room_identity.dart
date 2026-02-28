import 'package:flutter/material.dart';

/// Shared cozy room identity tokens used across navigation and headers.
///
/// Phase 2.1 mapping:
/// - Living Room (Home)      → warm amber
/// - Library (Learn)         → teal/blue
/// - Lab (Water & Health)    → green
/// - Workshop (Tank tools)   → purple/indigo
/// - Closet (Settings)       → neutral grey
class RoomIdentity {
  // Names
  static const String livingRoomName = 'Living Room';
  static const String libraryName = 'Library';
  static const String labName = 'Lab';
  static const String workshopName = 'Workshop';
  static const String closetName = 'Closet';

  // Accent colors
  static const Color livingRoomAccent = Color(0xFFE8A87C); // warm amber
  static const Color libraryAccent = AppColors.primary; // brand amber
  static const Color labAccent = Color(0xFF5AAF7A); // green
  static const Color workshopAccent = Color(0xFF9C78FF); // purple/indigo
  static const Color closetAccent = Color(0xFF9CA3AF); // neutral grey

  // Soft background tints for headers/cards
  static const Color livingRoomTint = Color(0x33E8A87C);
  static const Color libraryTint = Color(0x335B9A8B);
  static const Color labTint = Color(0x335AAF7A);
  static const Color workshopTint = Color(0x339C78FF);
  static const Color closetTint = Color(0x339CA3AF);
}
