package com.ramsa.attendiq.attend_iq

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class MonthWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val dayIds = arrayOf(
            R.id.tv_day_1,
            R.id.tv_day_2,
            R.id.tv_day_3,
            R.id.tv_day_4,
            R.id.tv_day_5
        )
        val defaultDayLabels = arrayOf("M", "T", "W", "T", "F")
        val upcomingIds = arrayOf(
            R.id.tv_upcoming_1,
            R.id.tv_upcoming_2,
            R.id.tv_upcoming_3
        )

        val white = Color.parseColor("#FFFFFF")
        val muted = Color.parseColor("#A0A5BD")
        val todayAccent = Color.parseColor("#6C5CE7")
        val examRed = Color.parseColor("#EF5350")
        val holidayYellow = Color.parseColor("#FFCA28")
        val taskOrange = Color.parseColor("#FF9800")
        val eventPurple = Color.parseColor("#AB47BC")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.month_widget_large).apply {
                setTextViewText(R.id.tv_brand, context.getString(R.string.app_name))

                fun resetEmpty(title: String, emptyMessage: String) {
                    setTextViewText(R.id.tv_month_title, title)
                    for (i in dayIds.indices) {
                        setTextViewText(dayIds[i], defaultDayLabels[i])
                        setTextColor(dayIds[i], muted)
                    }
                    for (id in upcomingIds) {
                        setViewVisibility(id, View.GONE)
                    }
                    setViewVisibility(R.id.tv_upcoming_empty, View.VISIBLE)
                    setTextViewText(R.id.tv_upcoming_empty, emptyMessage)
                }

                if (!WidgetHelper.areWidgetsEnabled(widgetData)) {
                    resetEmpty("Paused", "Widgets disabled in Settings")
                } else {
                    val jsonString = widgetData.getString(WidgetHelper.KEY_MONTH_DATA, null)
                    if (jsonString.isNullOrBlank()) {
                        resetEmpty("Academic Calendar", "No upcoming events")
                    } else {
                        try {
                            val json = JSONObject(jsonString)
                            val monthTitle = json.optCleanString("monthTitle", "Academic Calendar")
                            setTextViewText(R.id.tv_month_title, monthTitle)

                            val daysArray = json.optJSONArray("days")
                            for (i in dayIds.indices) {
                                val dayObj = if (daysArray != null && i < daysArray.length()) {
                                    daysArray.optJSONObject(i)
                                } else {
                                    null
                                }
                                if (dayObj == null) {
                                    setTextViewText(dayIds[i], defaultDayLabels[i])
                                    setTextColor(dayIds[i], muted)
                                    continue
                                }

                                val dayNum = dayObj.optInt("dayNumber", 0)
                                val dayStr = dayObj.optCleanString("dateString")
                                val label = when {
                                    dayStr.isNotEmpty() && dayNum > 0 -> "$dayStr $dayNum"
                                    dayNum > 0 -> dayNum.toString()
                                    else -> defaultDayLabels[i]
                                }
                                setTextViewText(dayIds[i], label)

                                val isToday = dayObj.optBoolean("isToday", false)
                                val hasExams = dayObj.optBoolean("hasExams", false)
                                val hasHolidays = dayObj.optBoolean("hasHolidays", false)
                                val dayColor = when {
                                    isToday -> todayAccent
                                    hasExams -> examRed
                                    hasHolidays -> holidayYellow
                                    else -> white
                                }
                                setTextColor(dayIds[i], dayColor)
                            }

                            val upcomingArray = json.optJSONArray("upcomingItems")
                            val count = upcomingArray?.length() ?: 0
                            if (count == 0) {
                                for (id in upcomingIds) {
                                    setViewVisibility(id, View.GONE)
                                }
                                setViewVisibility(R.id.tv_upcoming_empty, View.VISIBLE)
                                setTextViewText(R.id.tv_upcoming_empty, "No upcoming events")
                            } else {
                                setViewVisibility(R.id.tv_upcoming_empty, View.GONE)
                                for (i in upcomingIds.indices) {
                                    if (i < count) {
                                        val item = upcomingArray?.optJSONObject(i)
                                        if (item != null) {
                                            val dateText = item.optCleanString("dateText")
                                            val title = item.optCleanString("title")
                                            val type = item.optCleanString("type", "EVENT").uppercase()
                                            val color = when (type) {
                                                "EXAM" -> examRed
                                                "TASK" -> taskOrange
                                                "HOLIDAY" -> holidayYellow
                                                else -> eventPurple
                                            }
                                            val text = if (dateText.isNotEmpty()) {
                                                "$dateText  •  $title"
                                            } else {
                                                title
                                            }
                                            setTextViewText(upcomingIds[i], text)
                                            setTextColor(upcomingIds[i], color)
                                            setViewVisibility(upcomingIds[i], View.VISIBLE)
                                        } else {
                                            setViewVisibility(upcomingIds[i], View.GONE)
                                        }
                                    } else {
                                        setViewVisibility(upcomingIds[i], View.GONE)
                                    }
                                }
                            }
                        } catch (_: Exception) {
                            resetEmpty("Academic Calendar", "No upcoming events")
                        }
                    }
                }

                val pendingIntent = WidgetHelper.createLaunchPendingIntent(context, "calendar")
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
