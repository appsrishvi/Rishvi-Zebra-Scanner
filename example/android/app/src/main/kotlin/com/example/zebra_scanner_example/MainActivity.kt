package com.example.zebra_scanner_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.util.Log
import android.os.Bundle
import android.app.Activity
import android.os.Build
import androidx.core.os.bundleOf
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.Manifest

class MainActivity : FlutterActivity() {
    private val CHANNEL = "zebra_barcode_scanner"
    private val TAG = "ZebraDataWedge"
    private var methodChannel: MethodChannel? = null
    private val REQ_CODE_SCAN_SKU_BARCODE_TITLE_STOCK_TAKE = 1001
    private val CAMERA_PERMISSION_REQUEST_CODE = 1002

    companion object {
        const val ACTION_RESULT_NOTIFICATION = "com.symbol.datawedge.api.NOTIFICATION_ACTION"
        const val ACTION_RESULT = "com.symbol.datawedge.api.RESULT_ACTION"
        const val EXTRA_KEY_APPLICATION_NAME = "com.symbol.datawedge.api.APPLICATION_NAME"
        const val EXTRA_KEY_NOTIFICATION_TYPE = "com.symbol.datawedge.api.NOTIFICATION_TYPE"
        const val EXTRA_KEY_VALUE_SCANNER_STATUS = "SCANNER_STATUS"
        const val EXTRA_UNREGISTER_NOTIFICATION = "com.symbol.datawedge.api.UNREGISTER_FOR_NOTIFICATION"
        const val ACTION_DATAWEDGE = "com.symbol.datawedge.api.ACTION"
        const val EXTRA_SOFT_SCAN_TRIGGER = "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER"
        
        // DataWedge scan result intent
        const val ACTION_SCAN_RESULT = "com.symbol.datawedge.api.RESULT"
        const val EXTRA_SCAN_DATA = "com.symbol.datawedge.data_string"
        const val EXTRA_SCAN_TYPE = "com.symbol.datawedge.label_type"

        const val ACTION_DATA_CODE_RECEIVED = "com.dwbasicintent1.ACTION"
        const val DATA_STRING = "com.symbol.datawedge.data_string"
        const val ACTION_DATA_SCANNER_APPEARED = "com.hyperstock.zebra_device_appeared"
        const val ACTION_DATA_SCANNER_BARCODE = "com.hyperstock.zebra_device_barcode"
    }
    
    private val dataWedgeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                ACTION_SCAN_RESULT -> {
                    val scanData = intent.getStringExtra(EXTRA_SCAN_DATA)
                    val scanType = intent.getStringExtra(EXTRA_SCAN_TYPE)
                    
                    Log.d(TAG, "Scan result received: $scanData, type: $scanType")
                    
                    scanData?.let {
                        getApiData(it.trim(), isFromBarcodeScan = true)
                    }
                }
                ACTION_RESULT_NOTIFICATION -> {
                    val notificationType = intent.getStringExtra(EXTRA_KEY_NOTIFICATION_TYPE)
                    Log.d(TAG, "DataWedge notification: $notificationType")
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkAndRequestPermissions()
        registerReceiver()
        registerDataWedgeReceiver()
    }
    
    private fun checkAndRequestPermissions() {
        val permissions = mutableListOf<String>()
        
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) 
            != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.CAMERA)
        }
        
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) 
                != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            }
        }
        
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.S_V2) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) 
                != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
        }
        
        if (permissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this, 
                permissions.toTypedArray(), 
                CAMERA_PERMISSION_REQUEST_CODE
            )
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        when (requestCode) {
            CAMERA_PERMISSION_REQUEST_CODE -> {
                val allPermissionsGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
                if (allPermissionsGranted) {
                    Log.d(TAG, "All permissions granted")
                } else {
                    Log.w(TAG, "Some permissions were denied")
                }
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        unRegisterReceiver()
        unregisterReceiver(dataWedgeReceiver)
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeScanner" -> {
                    try {
                        Log.d(TAG, "Initializing DataWedge")
                        initializeDataWedge()
                        result.success("DataWedge initialized successfully")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to initialize DataWedge", e)
                        result.error("INIT_ERROR", "Failed to initialize DataWedge: ${e.message}", null)
                    }
                }
                "startScanning" -> {
                    try {
                        Log.d(TAG, "Starting soft scan trigger")
                        startSoftScanTrigger(REQ_CODE_SCAN_SKU_BARCODE_TITLE_STOCK_TAKE)
                        result.success("Scanning started")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to start scanning", e)
                        result.error("SCAN_ERROR", "Failed to start scanning: ${e.message}", null)
                    }
                }
                "stopScanning" -> {
                    try {
                        Log.d(TAG, "Stopping soft scan trigger")
                        stopSoftScanTrigger()
                        result.success("Scanning stopped")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to stop scanning", e)
                        result.error("STOP_ERROR", "Failed to stop scanning: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun registerDataWedgeReceiver() {
        val filter = IntentFilter().apply {
            addAction(ACTION_SCAN_RESULT)
            addAction(ACTION_RESULT_NOTIFICATION)
            addCategory(Intent.CATEGORY_DEFAULT)
        }
        
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(dataWedgeReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(dataWedgeReceiver, filter)
        }
        
        Log.d(TAG, "DataWedge receiver registered")
    }
    
    private fun initializeDataWedge() {
        createDataWedgeProfile()
        registerForNotifications()
    }
    
    private fun createDataWedgeProfile() {
        val profileName = "ZebraFlutterProfile"
        val packageName = packageName
        
        val profileIntent = Intent().apply {
            action = ACTION_DATAWEDGE
            putExtra("com.symbol.datawedge.api.CREATE_PROFILE", profileName)
        }
        sendBroadcast(profileIntent)
        
        val configBundle = Bundle().apply {
            putString("PROFILE_NAME", profileName)
            putString("PROFILE_ENABLED", "true")
            putString("CONFIG_MODE", "UPDATE")
            
            val appConfig = Bundle().apply {
                putString("PACKAGE_NAME", packageName)
                putStringArray("ACTIVITY_LIST", arrayOf("*"))
            }
            putParcelableArray("APP_LIST", arrayOf(appConfig))
            
            val intentConfig = Bundle().apply {
                putString("PLUGIN_NAME", "INTENT")
                putString("RESET_CONFIG", "true")
                
                val intentProps = Bundle().apply {
                    putString("intent_output_enabled", "true")
                    putString("intent_action", ACTION_SCAN_RESULT)
                    putString("intent_delivery", "2")
                }
                putBundle("PARAM_LIST", intentProps)
            }
            putBundle("PLUGIN_CONFIG", intentConfig)
        }
        
        val configIntent = Intent().apply {
            action = ACTION_DATAWEDGE
            putExtra("com.symbol.datawedge.api.SET_CONFIG", configBundle)
        }
        sendBroadcast(configIntent)
        
        Log.d(TAG, "DataWedge profile created: $profileName")
    }
    
    private fun registerForNotifications() {
        val intent = Intent().apply {
            action = ACTION_DATAWEDGE
            putExtra("com.symbol.datawedge.api.REGISTER_FOR_NOTIFICATION", 
                Bundle().apply {
                    putString("com.symbol.datawedge.api.APPLICATION_NAME", packageName)
                    putString("com.symbol.datawedge.api.NOTIFICATION_TYPE", "SCANNER_STATUS")
                })
        }
        sendBroadcast(intent)
        Log.d(TAG, "Registered for DataWedge notifications")
    }
    
    private fun startSoftScanTrigger(requestCode: Int) {
        sendDataWedgeIntentWithExtra(
            ACTION_DATAWEDGE,
            EXTRA_SOFT_SCAN_TRIGGER,
            "START_SCANNING"
        )
    }
    
    private fun stopSoftScanTrigger() {
        sendDataWedgeIntentWithExtra(
            ACTION_DATAWEDGE,
            EXTRA_SOFT_SCAN_TRIGGER,
            "STOP_SCANNING"
        )
    }
    
    private val receiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            var code = ""
            if (intent.action ==  ACTION_DATA_CODE_RECEIVED) {
                try {
                    code = intent.getStringExtra( DATA_STRING) ?: ""
                } catch (e: java.lang.Exception) {
                    //  Catch if the UI does not exist when we receive the broadcast
                }
            }

            if (code.isNotEmpty()  ) {

            }
        }
    }

    private fun registerReceiver() {
        val filter = IntentFilter()
        filter.addAction( ACTION_DATA_CODE_RECEIVED)
        filter.addAction( ACTION_DATA_SCANNER_APPEARED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
    }

    private fun unRegisterReceiver() {
        try {
            unregisterReceiver(receiver)
        }catch (e:Exception){
            e.printStackTrace()
        }
    }
    
    private fun sendDataWedgeIntentWithExtra(
        action: String,
        extraKey: String,
        extraValue: String
    ) {
        val dwIntent = Intent()
        dwIntent.setAction(action)
        dwIntent.putExtra(extraKey, extraValue)
        sendBroadcast(dwIntent)
        Log.d(TAG, "Sent DataWedge intent: $action with $extraKey = $extraValue")
    }
    
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        when (requestCode) {
            REQ_CODE_SCAN_SKU_BARCODE_TITLE_STOCK_TAKE -> {
                if (resultCode == Activity.RESULT_OK) {
                    Log.d(TAG, "Activity result received for barcode scan")
                }
            }
            else -> {
                super.onActivityResult(requestCode, resultCode, data)
            }
        }
    }
    
    private fun getApiData(barcodeData: String, isFromBarcodeScan: Boolean) {
        Log.d(TAG, "Processing barcode data: $barcodeData, fromScan: $isFromBarcodeScan")
        
        if (isFromBarcodeScan) {
            val result = mapOf(
                "data" to barcodeData,
                "timestamp" to System.currentTimeMillis(),
                "source" to "barcode_scan"
            )
            
            methodChannel?.invokeMethod("onScanResult", result)
        }
    }
}
