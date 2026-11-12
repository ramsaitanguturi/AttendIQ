import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../../../core/background/background_worker.dart';
import '../domain/widget_models.dart';
import '../services/widget_refresh_service.dart';

typedef WidgetScheduleSyncCallback = Future<void> Function(
  WidgetSettingsModel settings,
);

final widgetConfigProvider =
    StateNotifierProvider<WidgetConfigNotifier, WidgetSettingsModel>((ref) {
  final refreshService = ref.watch(widgetRefreshServiceProvider);
  return WidgetConfigNotifier(refreshService);
});

class WidgetConfigNotifier extends StateNotifier<WidgetSettingsModel> {
  final WidgetRefreshService _refreshService;
  final WidgetScheduleSyncCallback _syncSchedule;
  final bool _autoLoad;

  WidgetConfigNotifier(
    this._refreshService, {
    WidgetScheduleSyncCallback? syncSchedule,
    bool autoLoad = true,
  })  : _syncSchedule = syncSchedule ?? WidgetBackgroundScheduler.syncSchedule,
        _autoLoad = autoLoad,
        super(
          const WidgetSettingsModel(
            enabled: true,
            refreshFrequency: 'auto',
          ),
        ) {
    if (_autoLoad) {
      _loadSettings();
    }
  }

  static const _prefKey = 'widget_settings_config';

  Future<void> _loadSettings() async {
    try {
      final jsonStr = await HomeWidget.getWidgetData<String>(_prefKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        state = WidgetSettingsModel.fromJson(jsonStr);
      }
      await _syncSchedule(state);
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _saveSettings();
    await _syncSchedule(state);
    if (enabled) {
      await _refreshService.refreshAllWidgets();
    } else {
      await _refreshService.notifyProvidersUpdated();
    }
  }

  Future<void> setRefreshFrequency(String frequency) async {
    state = state.copyWith(refreshFrequency: frequency);
    await _saveSettings();
    await _syncSchedule(state);
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
