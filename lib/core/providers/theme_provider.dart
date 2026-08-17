import 'package:flutter/material.dart';

class ThemeProvider extends StatefulWidget {
  final Widget child;

  const ThemeProvider({super.key, required this.child});

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();

  static ThemeProviderState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ThemeInherited>()!
        .state;
  }

  static bool isDark(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ThemeInherited>()!
        .isDark;
  }
}

class ThemeProviderState extends State<ThemeProvider> {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  void setDark(bool value) {
    if (_isDark != value) setState(() => _isDark = value);
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeInherited(
      state: this,
      isDark: _isDark,
      child: widget.child,
    );
  }
}

// Keep private alias for createState
class _ThemeProviderState extends ThemeProviderState {}

class _ThemeInherited extends InheritedWidget {
  final ThemeProviderState state;
  final bool isDark;

  const _ThemeInherited({
    required this.state,
    required this.isDark,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ThemeInherited old) => isDark != old.isDark;
}
