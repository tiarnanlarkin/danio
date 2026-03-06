package com.tiarnanlarkin.danio

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val ACCESSIBILITY_CHANNEL = "com.tiarnanlarkin.aquarium/accessibility"
    
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
    }
}
