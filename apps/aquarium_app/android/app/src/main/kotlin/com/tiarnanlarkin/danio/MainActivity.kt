package com.tiarnanlarkin.danio

import android.content.Intent
import android.os.SystemClock
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val ACCESSIBILITY_CHANNEL = "com.tiarnanlarkin.aquarium/accessibility"
    private val PROFILE_PERFORMANCE_CHANNEL = "danio/profile_performance"
    private val PROFILE_PERFORMANCE_LOG_TAG = "DanioPerformance"

    private var coldReadyReported = false
    private var readyReportedForResume = false

    // QA fast-entry: debug-only deep link channel
    private val QA_LINKS_CHANNEL = "danio/qa_links"
    private var qaLinksChannel: MethodChannel? = null

    override fun onResume() {
        readyReportedForResume = false
        super.onResume()
    }

    private fun isDebugQaIntent(intent: Intent?): Boolean {
        if (!BuildConfig.DEBUG) return false
        return intent?.data?.toString()?.startsWith("danio://qa") == true
    }

    override fun shouldHandleDeeplinking(): Boolean {
        if (isDebugQaIntent(intent)) return false
        return super.shouldHandleDeeplinking()
    }

    override fun getInitialRoute(): String? {
        if (isDebugQaIntent(intent)) return "/"
        return super.getInitialRoute()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAnimationScale" -> {
                        // Check system animation scale setting
                        // Returns 0.0 when animations are disabled, 1.0 when enabled
                        val animationScale = try {
                            Settings.Global.getFloat(
                                contentResolver,
                                Settings.Global.ANIMATOR_DURATION_SCALE,
                                1.0f
                            )
                        } catch (e: Exception) {
                            1.0f // Default to enabled if can't read setting
                        }
                        result.success(animationScale.toDouble())
                    }
                    else -> result.notImplemented()
                }
            }

        // Inert unless the local profile-only Dart marker invokes it.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PROFILE_PERFORMANCE_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method != "markTankReady") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (readyReportedForResume) {
                result.success(null)
                return@setMethodCallHandler
            }

            readyReportedForResume = true
            val scenario = if (!coldReadyReported) {
                coldReadyReported = true
                "cold_start"
            } else {
                "warm_resume"
            }
            val readyMilliseconds = SystemClock.elapsedRealtimeNanos() / 1_000_000
            Log.i(
                PROFILE_PERFORMANCE_LOG_TAG,
                "DANIO_PERF_READY|$scenario|$readyMilliseconds"
            )
            result.success(readyMilliseconds)
        }

        // QA deep link channel — only registered in debug builds
        if (BuildConfig.DEBUG) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, QA_LINKS_CHANNEL)
            qaLinksChannel = channel
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialUri" -> result.success(intent?.data?.toString())
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        if (isDebugQaIntent(intent)) {
            val uri = intent.data?.toString()
            if (uri != null) {
                qaLinksChannel?.invokeMethod("onNewIntent", uri)
                return
            }
        }

        super.onNewIntent(intent)
    }
}
