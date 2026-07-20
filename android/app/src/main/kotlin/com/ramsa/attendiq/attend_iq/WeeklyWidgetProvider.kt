package com.ramsa.attendiq.attend_iq

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class WeeklyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.weekly_widget_large).apply {
                val jsonString = widgetData.getString("weekly_widget_data", null)
                if (jsonString != null) {
                    try {
                        val json = JSONObject(jsonString)
                        val weekTitle = json.optString("weekTitle", "This Week")
                        setTextViewText(R.id.tv_week_title, weekTitle)

                        val daysArray = json.optJSONArray("days")
                        if (daysArray != null) {
                            val headerIds = arrayOf(
                                R.id.tv_day_mon_header, R.id.tv_day_tue_header, R.id.tv_day_wed_header,
                                R.id.tv_day_thu_header, R.id.tv_day_fri_header
                            )
                            val contentIds = arrayOf(
                                R.id.tv_day_mon_content, R.id.tv_day_tue_content, R.id.tv_day_wed_content,
                                R.id.tv_day_thu_content, R.id.tv_day_fri_content
                            )

                            for (i in 0 until minOf(daysArray.length(), 5)) {
                                val dayObj = daysArray.getJSONObject(i)
                                val dayName = dayObj.optString("dayName", "")
                                val isHoliday = dayObj.optBoolean("isHoliday", false)
                                val holidayTitle = dayObj.optString("holidayTitle", "Holiday")

                                setTextViewText(headerIds[i], dayName)

                                if (isHoliday) {
                                    setTextViewText(contentIds[i], "🎉 $holidayTitle")
                                } else {
                                    val classesArray = dayObj.optJSONArray("classes")
                                    if (classesArray != null && classesArray.length() > 0) {
                                        val sb = StringBuilder()
                                        for (j in 0 until classesArray.length()) {
                                            val cls = classesArray.getJSONObject(j)
                                            val name = cls.optString("subjectName", "")
                                            val time = cls.optString("startTime", "")
                                            if (j > 0) sb.append("  •  ")
                                            sb.append("$name $time")
                                        }
                                        setTextViewText(contentIds[i], sb.toString())
                                    } else {
                                        setTextViewText(contentIds[i], "No Classes")
                                    }
                                }
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }

                // Deep link intent on tap -> opens Weekly Timetable
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("attendiq://timetable")).apply {
                    setPackage(context.packageName)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
