package com.ramsa.attendiq.attend_iq

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.OutOfQuotaPolicy
import dev.fluttercommunity.workmanager.SharedPreferenceHelper
import dev.fluttercommunity.workmanager.WM

class WidgetBootAndRefreshReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_REFRESH_WIDGETS = "com.ramsa.attendiq.action.REFRESH_WIDGETS"
        const val REFRESH_REQUEST_CODE = 1001
        const val DART_WIDGET_REFRESH_TASK = "com.ramsa.attendiq.widget_refresh"
        private const val UNIQUE_ONE_OFF_NAME = "attendiq_widget_refresh_once"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        val shouldHandle = action == ACTION_REFRESH_WIDGETS ||
            action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == Intent.ACTION_TIME_CHANGED ||
            action == Intent.ACTION_TIMEZONE_CHANGED ||
            action == Intent.ACTION_DATE_CHANGED
        if (!shouldHandle) return

        val appContext = context.applicationContext
        if (SharedPreferenceHelper.hasCallbackHandle(appContext)) {
            try {
                WM.enqueueOneOffTask(
                    context = appContext,
                    uniqueName = UNIQUE_ONE_OFF_NAME,
                    dartTask = DART_WIDGET_REFRESH_TASK,
                    payload = null,
                    tag = UNIQUE_ONE_OFF_NAME,
                    isInDebugMode = false,
                    existingWorkPolicy = ExistingWorkPolicy.REPLACE,
                    initialDelaySeconds = 0L,
                    constraintsConfig = Constraints.NONE,
                    outOfQuotaPolicy = OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST,
                    backoffPolicyConfig = null
                )
            } catch (_: Exception) {
                broadcastWidgetUpdate(appContext)
            }
        } else {
            broadcastWidgetUpdate(appContext)
        }
    }

    private fun broadcastWidgetUpdate(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val providers = listOf(
            TodayWidgetProvider::class.java,
            WeeklyWidgetProvider::class.java,
            MonthWidgetProvider::class.java
        )
        for (providerClass in providers) {
            val ids = manager.getAppWidgetIds(ComponentName(context, providerClass))
            if (ids.isNotEmpty()) {
                val updateIntent = Intent(context, providerClass).apply {
                    this.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(updateIntent)
            }
        }
    }
}

