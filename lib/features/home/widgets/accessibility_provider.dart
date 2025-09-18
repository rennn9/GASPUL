// lib/features/home/widgets/accessibility_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessibilityState {
  final bool highContrast;
  final bool largeText;
  final bool readContent;

  const AccessibilityState({
    this.highContrast = false,
    this.largeText = false,
    this.readContent = false,
  });

  AccessibilityState copyWith({
    bool? highContrast,
    bool? largeText,
    bool? readContent,
  }) {
    return AccessibilityState(
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      readContent: readContent ?? this.readContent,
    );
  }
}

class AccessibilityNotifier extends StateNotifier<AccessibilityState> {
  AccessibilityNotifier() : super(const AccessibilityState());

  void toggleHighContrast() {
    state = state.copyWith(highContrast: !state.highContrast);
  }

  void toggleLargeText() {
    state = state.copyWith(largeText: !state.largeText);
  }

  void toggleReadContent() {
    state = state.copyWith(readContent: !state.readContent);
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilityState>(
  (ref) => AccessibilityNotifier(),
);
