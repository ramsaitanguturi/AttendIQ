import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../domain/widget_models.dart';
import '../services/widget_refresh_service.dart';

final widgetConfigProvider = StateNotifierProvider<WidgetConfigNotifier, WidgetSettingsModel>((ref) {
  final refreshService = ref.watch(widgetRefreshServiceProvider);
  return WidgetConfigNotifier(refreshService);
});

class WidgetConfigNotifier extends StateNotifier<WidgetSettingsModel> {
  final WidgetRefreshService _refreshService;

  WidgetConfigNotifier(this._refreshService)
      : super(const WidgetSettingsModel(enabled: true, refreshFrequency: 'auto')) {
    _loadSettings();
  }

  static const _prefKey = 'widget_settings_config';

  Future<void> _loadSettings() async {
    try {
      final jsonStr = await HomeWidget.getWidgetData<String>(_prefKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        state = WidgetSettingsModel.fromJson(jsonStr);
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _saveSettings();
    if (enabled) {
      await _refreshService.refreshAllWidgets();
    }
  }

  Future<void> setRefreshFrequency(String frequency) async {
    state = state.copyWith(refreshFrequency: frequency);
    await _saveSettings();
    await _refreshService.refreshAllWidgets();
  }

  Future<void> _saveSettings() async {
    try {
      await HomeWidget.saveWidgetData<String>(_prefKey, state.toJson());
    } catch (_) {}
  }

  Future<void> forceRefresh() async {
    await _refreshService.refreshAllWidgets();
  }
}
