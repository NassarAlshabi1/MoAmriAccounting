/// Window Manager Stub - Used on mobile platforms (Android, iOS)
/// This file provides empty implementations for platforms that don't support window_manager

import 'package:flutter/material.dart';

/// Initialize window manager - Stub implementation for mobile
/// Does nothing on mobile platforms
Future<void> initializeWindowManager() async {
  // No-op on mobile platforms
  return;
}

/// Check if current platform is desktop
bool get isDesktopPlatform => false;

/// Window options class - Stub for mobile
class WindowOptions {
  final Size size;
  final bool center;
  final Color backgroundColor;
  final bool skipTaskbar;
  final dynamic titleBarStyle;

  const WindowOptions({
    required this.size,
    this.center = true,
    required this.backgroundColor,
    this.skipTaskbar = false,
    this.titleBarStyle,
  });
}
