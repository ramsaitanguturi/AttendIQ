# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# JNI & Native Methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Isar Core & Native Bindings
-keep class dev.isar.** { *; }
-keep class * implements dev.isar.Isar { *; }

# AndroidX WorkManager
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }

# Android Home Screen AppWidgets
-keep class com.ramsa.attendiq.attend_iq.** extends android.appwidget.AppWidgetProvider { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class * extends android.content.BroadcastReceiver { *; }
-keep class * extends android.app.Service { *; }

