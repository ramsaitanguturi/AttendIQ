package com.ramsa.attendiq.attend_iq

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONObject

internal object WidgetHelper {
    const val KEY_TODAY_DATA = "today_widget_data"
    const val KEY_WEEKLY_DATA = "weekly_widget_data"
    const val KEY_MONTH_DATA = "month_widget_data"
    const val KEY_WIDGET_SETTINGS = "widget_settings_config"

    fun buildDeepLinkUri(context: Context, host: String): Uri {
        val scheme = context.getString(R.string.deep_link_scheme)
        return Uri.parse("$scheme://$host")
    }

    fun createLaunchPendingIntent(context: Context, host: String): PendingIntent {
        val uri = buildDeepLinkUri(context, host)
        return HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)
    }

    fun createRefreshBroadcastPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, WidgetBootAndRefreshReceiver::class.java).apply {
            action = WidgetBootAndRefreshReceiver.ACTION_REFRESH_WIDGETS
        }
        return PendingIntent.getBroadcast(
            context,
            WidgetBootAndRefreshReceiver.REFRESH_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun areWidgetsEnabled(widgetData: SharedPreferences): Boolean {
        val raw = widgetData.getString(KEY_WIDGET_SETTINGS, null) ?: return true
        return try {
            JSONObject(raw).optBoolean("enabled", true)
        } catch (_: Exception) {
            true
        }
    }

    fun statusPrefix(status: String): String {
        return when (status.uppercase()) {
            "PRESENT", "EXTRA_PRESENT" -> "✓ "
            "ABSENT", "EXTRA_ABSENT" -> "✗ "
            "CANCELLED" -> "⊘ "
            else -> ""
        }
    }

    fun statusColor(status: String): Int {
        return when (status.uppercase()) {
            "PRESENT", "EXTRA_PRESENT" -> Color.parseColor("#4CAF50")
            "ABSENT", "EXTRA_ABSENT" -> Color.parseColor("#EF5350")
            "CANCELLED" -> Color.parseColor("#9E9E9E")
            else -> Color.parseColor("#FFFFFF")
        }
    }

    fun smallStatusBadgeColor(status: String): Int {
        return when (status.uppercase()) {
            "PRESENT", "EXTRA_PRESENT" -> Color.parseColor("#4CAF50")
            "ABSENT", "EXTRA_ABSENT" -> Color.parseColor("#EF5350")
            "CANCELLED" -> Color.parseColor("#9E9E9E")
            else -> Color.parseColor("#6C5CE7")
        }
    }
}

internal fun JSONObject.optCleanString(key: String, fallback: String = ""): String {
    if (!has(key) || isNull(key)) return fallback
    val value = optString(key, fallback)
    return if (value.isBlank() || value == "null") fallback else value
}

