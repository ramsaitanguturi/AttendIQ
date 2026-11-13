package com.ramsa.attendiq.attend_iq

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val views = buildViews(context, options, widgetData)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = buildViews(context, newOptions, widgetData)
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun buildViews(
        context: Context,
        options: Bundle?,
        widgetData: SharedPreferences
    ): RemoteViews {
        val minWidth = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110) ?: 110
        val useCompactLayout = minWidth in 1 until 200
        return if (useCompactLayout) {
            buildSmallViews(context, widgetData)
        } else {
            buildMediumViews(context, widgetData)
        }
    }

    private fun buildSmallViews(
        context: Context,
        widgetData: SharedPreferences
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.today_widget_small)
        val launchIntent = WidgetHelper.createLaunchPendingIntent(context, "today")
        views.setOnClickPendingIntent(R.id.widget_container, launchIntent)
        views.setTextViewText(R.id.tv_brand, context.getString(R.string.app_name))

        if (!WidgetHelper.areWidgetsEnabled(widgetData)) {
            views.setTextViewText(R.id.tv_widget_tag, "Paused")
            views.setViewVisibility(R.id.layout_next_class, View.GONE)
            views.setViewVisibility(R.id.tv_status, View.GONE)
            views.setViewVisibility(R.id.tv_empty_small, View.VISIBLE)
            views.setTextViewText(R.id.tv_empty_small, "Widgets disabled in Settings")
            return views
        }

        val jsonString = widgetData.getString(WidgetHelper.KEY_TODAY_DATA, null)
        if (jsonString.isNullOrBlank()) {
            views.setTextViewText(R.id.tv_widget_tag, "Today")
            views.setViewVisibility(R.id.layout_next_class, View.GONE)
            views.setViewVisibility(R.id.tv_status, View.GONE)
            views.setViewVisibility(R.id.tv_empty_small, View.VISIBLE)
            views.setTextViewText(R.id.tv_empty_small, "No classes today")
            return views
        }

        try {
            val json = JSONObject(jsonString)
            val isHoliday = json.optBoolean("isHoliday", false)
            val holidayTitle = json.optCleanString("holidayTitle", "Holiday")

            if (isHoliday) {
                views.setTextViewText(R.id.tv_widget_tag, "Holiday")
                views.setViewVisibility(R.id.layout_next_class, View.GONE)
                views.setViewVisibility(R.id.tv_status, View.GONE)
                views.setViewVisibility(R.id.tv_empty_small, View.VISIBLE)
                views.setTextViewText(R.id.tv_empty_small, "🎉 $holidayTitle")
                return views
            }

            val nextClass = json.optJSONObject("nextClass")
            val classesArray = json.optJSONArray("classes")
            val targetClass = nextClass ?: if (classesArray != null && classesArray.length() > 0) {
                classesArray.optJSONObject(0)
            } else {
                null
            }

            if (targetClass != null) {
                val startTime = targetClass.optCleanString("startTime")
                val endTime = targetClass.optCleanString("endTime")
                val subjectName = targetClass.optCleanString("subjectName", "Class")
                val room = targetClass.optCleanString("room")
                val status = targetClass.optCleanString("status", "UPCOMING")

                views.setTextViewText(
                    R.id.tv_widget_tag,
                    if (status == "UPCOMING") "Next Class" else "Today"
                )
                views.setViewVisibility(R.id.layout_next_class, View.VISIBLE)
                views.setViewVisibility(R.id.tv_empty_small, View.GONE)
                views.setTextViewText(
                    R.id.tv_time,
                    if (startTime.isNotEmpty() && endTime.isNotEmpty()) {
                        "$startTime - $endTime"
                    } else {
                        startTime
                    }
                )
                views.setTextViewText(R.id.tv_subject, subjectName)

                if (room.isNotEmpty()) {
                    views.setViewVisibility(R.id.tv_room, View.VISIBLE)
                    views.setTextViewText(R.id.tv_room, room)
                } else {
                    views.setViewVisibility(R.id.tv_room, View.GONE)
                }

                views.setViewVisibility(R.id.tv_status, View.VISIBLE)
                views.setTextViewText(R.id.tv_status, status.uppercase())
                views.setTextColor(R.id.tv_status, WidgetHelper.smallStatusBadgeColor(status))
            } else {
                views.setTextViewText(R.id.tv_widget_tag, "Today")
                views.setViewVisibility(R.id.layout_next_class, View.GONE)
                views.setViewVisibility(R.id.tv_status, View.GONE)
                views.setViewVisibility(R.id.tv_empty_small, View.VISIBLE)
                views.setTextViewText(R.id.tv_empty_small, "No classes today")
            }
        } catch (_: Exception) {
            views.setTextViewText(R.id.tv_widget_tag, "Today")
            views.setViewVisibility(R.id.layout_next_class, View.GONE)
            views.setViewVisibility(R.id.tv_status, View.GONE)
            views.setViewVisibility(R.id.tv_empty_small, View.VISIBLE)
            views.setTextViewText(R.id.tv_empty_small, "Tap to open ACEDRA")
        }

        return views
    }

    private fun buildMediumViews(
        context: Context,
        widgetData: SharedPreferences
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.today_widget_medium)
        val launchIntent = WidgetHelper.createLaunchPendingIntent(context, "today")
        val refreshIntent = WidgetHelper.createRefreshBroadcastPendingIntent(context)
        views.setOnClickPendingIntent(R.id.widget_container, launchIntent)
        views.setOnClickPendingIntent(R.id.btn_refresh, refreshIntent)
        views.setTextViewText(R.id.tv_brand, context.getString(R.string.app_name))

        val classRowIds = arrayOf(R.id.tv_class_1, R.id.tv_class_2, R.id.tv_class_3)

        if (!WidgetHelper.areWidgetsEnabled(widgetData)) {
            views.setTextViewText(R.id.tv_date, "Paused")
            views.setViewVisibility(R.id.layout_classes, View.GONE)
            views.setViewVisibility(R.id.tv_empty, View.VISIBLE)
            views.setTextViewText(R.id.tv_empty, "Widgets disabled in Settings")
            return views
        }

        val jsonString = widgetData.getString(WidgetHelper.KEY_TODAY_DATA, null)
        if (jsonString.isNullOrBlank()) {
            views.setTextViewText(R.id.tv_date, "Today")
            views.setViewVisibility(R.id.layout_classes, View.GONE)
            views.setViewVisibility(R.id.tv_empty, View.VISIBLE)
            views.setTextViewText(R.id.tv_empty, "No classes today")
            return views
        }

        try {
            val json = JSONObject(jsonString)
            val dateText = json.optCleanString("dateText", "Today")
            val isHoliday = json.optBoolean("isHoliday", false)
            val holidayTitle = json.optCleanString("holidayTitle", "Holiday")

            views.setTextViewText(R.id.tv_date, "Today - $dateText")

            if (isHoliday) {
                views.setViewVisibility(R.id.layout_classes, View.GONE)
                views.setViewVisibility(R.id.tv_empty, View.VISIBLE)
                views.setTextViewText(R.id.tv_empty, "🎉 $holidayTitle")
            } else {
                val classesArray = json.optJSONArray("classes")
                if (classesArray != null && classesArray.length() > 0) {
                    views.setViewVisibility(R.id.layout_classes, View.VISIBLE)
                    views.setViewVisibility(R.id.tv_empty, View.GONE)

                    for (i in classRowIds.indices) {
                        val cls = if (i < classesArray.length()) classesArray.optJSONObject(i) else null
                        if (cls != null) {
                            val start = cls.optCleanString("startTime")
                            val end = cls.optCleanString("endTime")
                            val subject = cls.optCleanString("subjectName", "Class")
                            val status = cls.optCleanString("status", "UPCOMING")
                            val prefix = WidgetHelper.statusPrefix(status)
                            val timeRange = if (start.isNotEmpty() && end.isNotEmpty()) {
                                "$start - $end"
                            } else {
                                start
                            }
                            views.setTextViewText(classRowIds[i], "$prefix$timeRange  •  $subject")
                            views.setTextColor(classRowIds[i], WidgetHelper.statusColor(status))
                            views.setViewVisibility(classRowIds[i], View.VISIBLE)
                        } else {
                            views.setViewVisibility(classRowIds[i], View.GONE)
                        }
                    }
                } else {
                    views.setViewVisibility(R.id.layout_classes, View.GONE)
                    views.setViewVisibility(R.id.tv_empty, View.VISIBLE)
                    views.setTextViewText(R.id.tv_empty, "No classes today 🎉")
                }
            }
        } catch (_: Exception) {
            views.setTextViewText(R.id.tv_date, "Today")
            views.setViewVisibility(R.id.layout_classes, View.GONE)
            views.setViewVisibility(R.id.tv_empty, View.VISIBLE)
            views.setTextViewText(R.id.tv_empty, "Tap to open ACEDRA")
            views.setTextColor(R.id.tv_empty, Color.parseColor("#A0A5BD"))
        }

        return views
    }
}
