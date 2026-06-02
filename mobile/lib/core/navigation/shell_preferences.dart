import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sidebarCollapsedProvider =
    StateNotifierProvider<SidebarCollapsedController, bool>((ref) {
  return SidebarCollapsedController();
});

class SidebarCollapsedController extends StateNotifier<bool> {
  SidebarCollapsedController() : super(false) {
    _load();
  }

  static const _key = 'rbp_sidebar_collapsed';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }

  Future<void> setCollapsed(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
