package com.furkanages.cardenceapp

import androidx.appcompat.app.AppCompatDelegate
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var savedNightMode: Int? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cardence/appearance",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAppearance" -> {
                    val brightness = call.argument<String>("brightness")
                    if (brightness.isNullOrEmpty()) {
                        result.error(
                            "INVALID_ARGUMENT",
                            "brightness is required",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    setAppearance(brightness)
                    result.success(null)
                }

                "resetAppearance" -> {
                    resetAppearance()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun setAppearance(brightness: String) {
        if (savedNightMode == null) {
            savedNightMode = AppCompatDelegate.getDefaultNightMode()
        }
        AppCompatDelegate.setDefaultNightMode(
            if (brightness == "dark") {
                AppCompatDelegate.MODE_NIGHT_YES
            } else {
                AppCompatDelegate.MODE_NIGHT_NO
            },
        )
    }

    private fun resetAppearance() {
        AppCompatDelegate.setDefaultNightMode(
            savedNightMode ?: AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM,
        )
        savedNightMode = null
    }
}
