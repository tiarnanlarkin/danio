## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep data classes (adjust package name as needed)
-keep class com.tiarnanlarkin.danio.** { *; }

## Hive database
-keep class io.hive.** { *; }
-keep class * extends io.hive.TypeAdapter { *; }

## Play Core (deferred components - not used but required by Flutter)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
