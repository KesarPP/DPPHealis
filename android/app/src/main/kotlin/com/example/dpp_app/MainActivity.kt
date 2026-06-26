package com.example.dpp_app

import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.dpp_app/app_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAppInstalled" -> {
                    val packageId = call.argument<String>("packageId")
                    if (packageId != null) {
                        result.success(checkAppInstalled(packageId))
                    } else {
                        result.error("INVALID_ARGUMENT", "Package ID cannot be null", null)
                    }
                }
                "launchOrInstallApp" -> {
                    val packageId = call.argument<String>("packageId")
                    if (packageId != null) {
                        launchOrInstall(packageId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package ID cannot be null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkAppInstalled(packageId: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageId, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        } catch (e: Exception) {
            false
        }
    }

    private fun launchOrInstall(packageId: String) {
        if (checkAppInstalled(packageId)) {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageId)
            if (launchIntent != null) {
                startActivity(launchIntent)
            }
        } else {
            try {
                val marketIntent = Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$packageId"))
                marketIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(marketIntent)
            } catch (e: Exception) {
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$packageId"))
                webIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(webIntent)
            }
        }
    }
}
