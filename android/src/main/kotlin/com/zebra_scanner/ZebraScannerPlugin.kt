package com.zebra_scanner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * ZebraScannerPlugin
 *
 * Flutter plugin for Zebra barcode scanner devices using the DataWedge API.
 * Consumers do NOT need to modify their MainActivity — this plugin self-registers
 * via Flutter's v2 embedding plugin mechanism.
 */
class ZebraScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var context: Context? = null

    private val TAG = "ZebraScanner"

    // ── DataWedge intent constants ────────────────────────────────────────────

    companion object {
        private const val CHANNEL_NAME = "zebra_barcode_scanner"

        private const val ACTION_DATAWEDGE = "com.symbol.datawedge.api.ACTION"
        private const val EXTRA_SOFT_SCAN_TRIGGER = "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER"

        private const val ACTION_SCAN_RESULT = "com.symbol.datawedge.api.RESULT"
        private const val EXTRA_SCAN_DATA = "com.symbol.datawedge.data_string"
        private const val EXTRA_SCAN_TYPE = "com.symbol.datawedge.label_type"

        private const val ACTION_RESULT_NOTIFICATION = "com.symbol.datawedge.api.NOTIFICATION_ACTION"
        private const val EXTRA_NOTIFICATION_TYPE = "com.symbol.datawedge.api.NOTIFICATION_TYPE"

        private const val PROFILE_NAME = "ZebraFlutterProfile"
    }

    // ── BroadcastReceiver for scan results ────────────────────────────────────

    private val scanReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            when (intent?.action) {
                ACTION_SCAN_RESULT -> {
                    val data = intent.getStringExtra(EXTRA_SCAN_DATA)?.trim() ?: return
                    val type = intent.getStringExtra(EXTRA_SCAN_TYPE)
                    Log.d(TAG, "Scan received: $data  type: $type")

                    val payload = mapOf(
                        "data" to data,
                        "type" to type,
                        "timestamp" to System.currentTimeMillis(),
                        "source" to "barcode_scan"
                    )
                    channel.invokeMethod("onScanResult", payload)
                }
                ACTION_RESULT_NOTIFICATION -> {
                    val notifType = intent.getStringExtra(EXTRA_NOTIFICATION_TYPE) ?: return
                    Log.d(TAG, "DataWedge notification: $notifType")
                    channel.invokeMethod("onStatusChange", notifType.lowercase())
                }
            }
        }
    }

    // ── FlutterPlugin ─────────────────────────────────────────────────────────

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        Log.d(TAG, "Plugin attached to engine")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        unregisterScanReceiver()
        context = null
        Log.d(TAG, "Plugin detached from engine")
    }

    // ── ActivityAware — needed to register/unregister receiver with Activity context ──

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        context = binding.activity
        registerScanReceiver()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unregisterScanReceiver()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        context = binding.activity
        registerScanReceiver()
    }

    override fun onDetachedFromActivity() {
        unregisterScanReceiver()
        context = null
    }

    // ── MethodCallHandler ─────────────────────────────────────────────────────

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initializeScanner" -> {
                try {
                    initializeDataWedge()
                    result.success("DataWedge initialized successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "initializeScanner failed", e)
                    result.error("INIT_ERROR", e.message, null)
                }
            }
            "startScanning" -> {
                try {
                    sendDataWedgeIntent(EXTRA_SOFT_SCAN_TRIGGER, "START_SCANNING")
                    result.success("Scanning started")
                } catch (e: Exception) {
                    Log.e(TAG, "startScanning failed", e)
                    result.error("SCAN_ERROR", e.message, null)
                }
            }
            "stopScanning" -> {
                try {
                    sendDataWedgeIntent(EXTRA_SOFT_SCAN_TRIGGER, "STOP_SCANNING")
                    result.success("Scanning stopped")
                } catch (e: Exception) {
                    Log.e(TAG, "stopScanning failed", e)
                    result.error("STOP_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    // ── DataWedge helpers ─────────────────────────────────────────────────────

    private fun initializeDataWedge() {
        val ctx = context ?: throw IllegalStateException("Context is null")

        // 1. Create profile
        ctx.sendBroadcast(Intent(ACTION_DATAWEDGE).apply {
            putExtra("com.symbol.datawedge.api.CREATE_PROFILE", PROFILE_NAME)
        })

        // 2. Configure profile — associate with this app and set intent output
        val appConfig = Bundle().apply {
            putString("PACKAGE_NAME", ctx.packageName)
            putStringArray("ACTIVITY_LIST", arrayOf("*"))
        }
        val intentParams = Bundle().apply {
            putString("intent_output_enabled", "true")
            putString("intent_action", ACTION_SCAN_RESULT)
            putString("intent_delivery", "2") // broadcast
        }
        val intentPlugin = Bundle().apply {
            putString("PLUGIN_NAME", "INTENT")
            putString("RESET_CONFIG", "true")
            putBundle("PARAM_LIST", intentParams)
        }
        val profileConfig = Bundle().apply {
            putString("PROFILE_NAME", PROFILE_NAME)
            putString("PROFILE_ENABLED", "true")
            putString("CONFIG_MODE", "UPDATE")
            putParcelableArray("APP_LIST", arrayOf(appConfig))
            putBundle("PLUGIN_CONFIG", intentPlugin)
        }
        ctx.sendBroadcast(Intent(ACTION_DATAWEDGE).apply {
            putExtra("com.symbol.datawedge.api.SET_CONFIG", profileConfig)
        })

        // 3. Register for scanner status notifications
        ctx.sendBroadcast(Intent(ACTION_DATAWEDGE).apply {
            putExtra(
                "com.symbol.datawedge.api.REGISTER_FOR_NOTIFICATION",
                Bundle().apply {
                    putString("com.symbol.datawedge.api.APPLICATION_NAME", ctx.packageName)
                    putString("com.symbol.datawedge.api.NOTIFICATION_TYPE", "SCANNER_STATUS")
                }
            )
        })

        Log.d(TAG, "DataWedge profile configured: $PROFILE_NAME")
    }

    private fun sendDataWedgeIntent(extraKey: String, extraValue: String) {
        val ctx = context ?: throw IllegalStateException("Context is null")
        ctx.sendBroadcast(Intent(ACTION_DATAWEDGE).apply {
            putExtra(extraKey, extraValue)
        })
        Log.d(TAG, "DataWedge intent sent: $extraKey = $extraValue")
    }

    private fun registerScanReceiver() {
        val ctx = context ?: return
        val filter = IntentFilter().apply {
            addAction(ACTION_SCAN_RESULT)
            addAction(ACTION_RESULT_NOTIFICATION)
            addCategory(Intent.CATEGORY_DEFAULT)
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ctx.registerReceiver(scanReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                ctx.registerReceiver(scanReceiver, filter)
            }
            Log.d(TAG, "Scan receiver registered")
        } catch (e: Exception) {
            Log.w(TAG, "Receiver already registered: ${e.message}")
        }
    }

    private fun unregisterScanReceiver() {
        try {
            context?.unregisterReceiver(scanReceiver)
            Log.d(TAG, "Scan receiver unregistered")
        } catch (e: Exception) {
            Log.w(TAG, "Receiver not registered: ${e.message}")
        }
    }
}
