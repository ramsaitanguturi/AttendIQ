package com.ramsa.attendiq.attend_iq

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class MonthWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.month_widget_large).apply {
                val jsonString = widgetData.getString("month_widget_data", null)
                if (jsonString != null) {
                    try {
                        val json = JSONObject(jsonString)
                        val monthTitle = json.optString("monthTitle", "Academic Calendar")
                        setTextViewText(R.id.tv_month_title, monthTitle)

                        val daysArray = json.optJSONArray("days")
                        if (daysArray != null) {
                            val dayIds = arrayOf(
                                R.id.tv_day_1, R.id.tv_day_2, R.id.tv_day_3,
                                R.id.tv_day_4, R.id.tv_day_5
                            )
                            for (i in 0 until minOf(daysArray.length(), 5)) {
                                val dayObj = daysArray.getJSONObject(i)
                                val dayNum = dayObj.optInt("dayNumber", 1)
                                setTextViewText(dayIds[i], dayNum.toString())
                            }
                        }

                        val upcomingArray = json.optJSONArray("upcomingItems")
                        if (upcomingArray != null) {
                            val upcomingIds = arrayOf(
                                R.id.tv_upcoming_1, R.id.tv_upcoming_2, R.id.tv_upcoming_3
                            )
                            for (i in 0 until 3) {
                                if (i < upcomingArray.length()) {
                                    val item = upcomingArray.getJSONObject(i)
                                    val dateText = item.optString("dateText", "")
                                    val title = item.optString("title", "")
                                    setTextViewText(upcomingIds[i], "$dateText  •  $title")
                                    setViewVisibility(upcomingIds[i], android.view.View.VISIBLE)
                                } else {
                                    setViewVisibility(upcomingIds[i], android.view.View.GONE)
                                }
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }

                // Deep link intent on tap -> opens Academic Calendar
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("attendiq://calendar")).apply {
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
