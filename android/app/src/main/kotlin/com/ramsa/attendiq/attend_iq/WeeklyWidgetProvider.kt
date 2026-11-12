package com.ramsa.attendiq.attend_iq

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class WeeklyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val defaultHeaders = arrayOf("MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN")
        val headerIds = arrayOf(
            R.id.tv_day_mon_header,
            R.id.tv_day_tue_header,
            R.id.tv_day_wed_header,
            R.id.tv_day_thu_header,
            R.id.tv_day_fri_header,
            R.id.tv_day_sat_header,
            R.id.tv_day_sun_header
        )
        val contentIds = arrayOf(
            R.id.tv_day_mon_content,
            R.id.tv_day_tue_content,
            R.id.tv_day_wed_content,
            R.id.tv_day_thu_content,
            R.id.tv_day_fri_content,
            R.id.tv_day_sat_content,
            R.id.tv_day_sun_content
        )

        val white = Color.parseColor("#FFFFFF")
        val muted = Color.parseColor("#A0A5BD")
        val holidayAmber = Color.parseColor("#FFCA28")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.weekly_widget_large).apply {
                setTextViewText(R.id.tv_brand, context.getString(R.string.app_name))

                fun resetEmpty(title: String, emptyMessage: String) {
                    setTextViewText(R.id.tv_week_title, title)
                    for (i in headerIds.indices) {
                        setTextViewText(headerIds[i], defaultHeaders[i])
                        setTextViewText(contentIds[i], emptyMessage)
                        setTextColor(contentIds[i], muted)
                    }
                }

                if (!WidgetHelper.areWidgetsEnabled(widgetData)) {
                    resetEmpty("Paused", "Widgets disabled in Settings")
                } else {
                    val jsonString = widgetData.getString(WidgetHelper.KEY_WEEKLY_DATA, null)
                    if (jsonString.isNullOrBlank()) {
                        resetEmpty("This Week", "No Classes")
                    } else {
                        try {
                            val json = JSONObject(jsonString)
                            val weekTitle = json.optCleanString("weekTitle", "This Week")
                            setTextViewText(R.id.tv_week_title, weekTitle)

                            val daysArray = json.optJSONArray("days")
                            for (i in headerIds.indices) {
                                val dayObj = if (daysArray != null && i < daysArray.length()) {
                                    daysArray.optJSONObject(i)
                                } else {
                                    null
                                }
                                if (dayObj == null) {
                                    setTextViewText(headerIds[i], defaultHeaders[i])
                                    setTextViewText(contentIds[i], "No Classes")
                                    setTextColor(contentIds[i], muted)
                                    continue
                                }

                                val dayName = dayObj.optCleanString("dayName", defaultHeaders[i])
                                val isHoliday = dayObj.optBoolean("isHoliday", false)
                                val holidayTitle = dayObj.optCleanString("holidayTitle", "Holiday")

                                setTextViewText(headerIds[i], dayName)

                                if (isHoliday) {
                                    setTextViewText(contentIds[i], "🎉 $holidayTitle")
                                    setTextColor(contentIds[i], holidayAmber)
                                } else {
                                    val classesArray = dayObj.optJSONArray("classes")
                                    if (classesArray != null && classesArray.length() > 0) {
                                        val sb = StringBuilder()
                                        for (j in 0 until classesArray.length()) {
                                            val cls = classesArray.optJSONObject(j) ?: continue
                                            val name = cls.optCleanString("subjectName", "Class")
                                            val time = cls.optCleanString("startTime")
                                            val isCancelled = cls.optBoolean("isCancelled", false)
                                            if (sb.isNotEmpty()) sb.append("  •  ")
                                            if (isCancelled) sb.append("⊘ ")
                                            sb.append(if (time.isNotEmpty()) "$name $time" else name)
                                        }
                                        val line = sb.toString()
                                        if (line.isNotEmpty()) {
                                            setTextViewText(contentIds[i], line)
                                            setTextColor(contentIds[i], white)
                                        } else {
                                            setTextViewText(contentIds[i], "No Classes")
                                            setTextColor(contentIds[i], muted)
                                        }
                                    } else {
                                        setTextViewText(contentIds[i], "No Classes")
                                        setTextColor(contentIds[i], muted)
                                    }
                                }
                            }
                        } catch (_: Exception) {
                            resetEmpty("This Week", "No Classes")
                        }
                    }
                }

                val pendingIntent = WidgetHelper.createLaunchPendingIntent(context, "timetable")
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
