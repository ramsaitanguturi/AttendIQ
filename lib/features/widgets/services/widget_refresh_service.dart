import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/widget_data_service.dart';

final widgetRefreshServiceProvider = Provider<WidgetRefreshService>((ref) {
  final dataService = ref.watch(widgetDataServiceProvider);
  return WidgetRefreshService(dataService);
});

class WidgetRefreshService {
  final WidgetDataService _dataService;

  WidgetRefreshService(this._dataService);

  /// Trigger full widget refresh across all home screen widgets
  Future<void> refreshAllWidgets() async {
    if (kDebugMode) {
      developer.log('Triggering Widget Refresh Service...', name: 'WidgetRefreshService');
    }
    await _dataService.updateAllWidgets();
  }
}
