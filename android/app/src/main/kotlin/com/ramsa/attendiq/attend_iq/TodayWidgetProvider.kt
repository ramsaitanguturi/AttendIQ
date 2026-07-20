package com.ramsa.attendiq.attend_iq

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.today_widget_medium).apply {
                val jsonString = widgetData.getString("today_widget_data", null)
                if (jsonString != null) {
                    try {
                        val json = JSONObject(jsonString)
                        val dateText = json.optString("dateText", "Today")
                        val isHoliday = json.optBoolean("isHoliday", false)
                        val holidayTitle = json.optString("holidayTitle", "Holiday")

                        setTextViewText(R.id.tv_date, "Today - $dateText")

                        if (isHoliday) {
                            setViewVisibility(R.id.layout_classes, View.GONE)
                            setViewVisibility(R.id.tv_empty, View.VISIBLE)
                            setTextViewText(R.id.tv_empty, "🎉 $holidayTitle")
                        } else {
                            val classesArray = json.optJSONArray("classes")
                            if (classesArray != null && classesArray.length() > 0) {
                                setViewVisibility(R.id.layout_classes, View.VISIBLE)
                                setViewVisibility(R.id.tv_empty, View.GONE)

                                val class1 = if (classesArray.length() > 0) classesArray.getJSONObject(0) else null
                                val class2 = if (classesArray.length() > 1) classesArray.getJSONObject(1) else null
                                val class3 = if (classesArray.length() > 2) classesArray.getJSONObject(2) else null

                                if (class1 != null) {
                                    setTextViewText(R.id.tv_class_1, "${class1.optString("startTime")} - ${class1.optString("endTime")}  •  ${class1.optString("subjectName")}")
                                    setViewVisibility(R.id.tv_class_1, View.VISIBLE)
                                } else setViewVisibility(R.id.tv_class_1, View.GONE)

                                if (class2 != null) {
                                    setTextViewText(R.id.tv_class_2, "${class2.optString("startTime")} - ${class2.optString("endTime")}  •  ${class2.optString("subjectName")}")
                                    setViewVisibility(R.id.tv_class_2, View.VISIBLE)
                                } else setViewVisibility(R.id.tv_class_2, View.GONE)

                                if (class3 != null) {
                                    setTextViewText(R.id.tv_class_3, "${class3.optString("startTime")} - ${class3.optString("endTime")}  •  ${class3.optString("subjectName")}")
                                    setViewVisibility(R.id.tv_class_3, View.VISIBLE)
                                } else setViewVisibility(R.id.tv_class_3, View.GONE)
                            } else {
                                setViewVisibility(R.id.layout_classes, View.GONE)
                                setViewVisibility(R.id.tv_empty, View.VISIBLE)
                                setTextViewText(R.id.tv_empty, "No classes today 🎉")
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                } else {
                    setTextViewText(R.id.tv_empty, "No classes today 🎉")
                    setViewVisibility(R.id.layout_classes, View.GONE)
                    setViewVisibility(R.id.tv_empty, View.VISIBLE)
                }

                // Deep link intent on tap
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("attendiq://today")).apply {
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
                setOnClickPendingIntent(R.id.btn_refresh, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
