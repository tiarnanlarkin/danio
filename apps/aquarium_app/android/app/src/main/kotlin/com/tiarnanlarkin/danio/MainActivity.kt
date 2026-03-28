package com.tiarnanlarkin.danio

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val ACCESSIBILITY_CHANNEL = "com.tiarnanlarkin.aquarium/accessibility"

    // QA fast-entry: debug-only deep link channel
    private val QA_LINKS_CHANNEL = "danio/qa_links"
    private var qaLinksChannel: MethodChannel? = null

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
        super.onNewIntent(intent)
        if (BuildConfig.DEBUG) {
            val uri = intent.data?.toString()
            if (uri != null && uri.startsWith("danio://qa")) {
                qaLinksChannel?.invokeMethod("onNewIntent", uri)
            }
        }
    }
}
