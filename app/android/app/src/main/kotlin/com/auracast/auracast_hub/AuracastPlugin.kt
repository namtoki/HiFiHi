package com.auracast.auracast_hub

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothStatusCodes
import android.content.Context
import android.os.Build
import android.util.Log
import com.auracast.auracast_hub.bluetooth.AuracastScanner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class AuracastPlugin : FlutterPlugin {
    companion object {
        private const val TAG = "AuracastPlugin"
        private const val METHOD_CHANNEL = "com.auracast.auracast_hub/method"
        private const val SCAN_EVENT_CHANNEL = "com.auracast.auracast_hub/scan"
    }

    private lateinit var methodChannel: MethodChannel
    private lateinit var scanEventChannel: EventChannel

    private lateinit var context: Context
    private var bluetoothAdapter: BluetoothAdapter? = null

    private var scanner: AuracastScanner? = null

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var scanJob: Job? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter

        bluetoothAdapter?.let {
            scanner = AuracastScanner(it)
        }

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isLeAudioSupported" -> {
                    result.success(isLeAudioSupported())
                }
                "isBluetoothEnabled" -> {
                    result.success(bluetoothAdapter?.isEnabled ?: false)
                }
                "stopScan" -> {
                    stopScan()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        scanEventChannel = EventChannel(binding.binaryMessenger, SCAN_EVENT_CHANNEL)
        scanEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            private var eventSink: EventChannel.EventSink? = null

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                Log.d(TAG, "Scan stream listener attached")
                eventSink = events
                startScanWithEventSink(events)
            }

            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "Scan stream listener cancelled")
                scanJob?.cancel()
                scanner?.stopScan()
                eventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        scope.cancel()
        methodChannel.setMethodCallHandler(null)
    }

    private fun isLeAudioSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            Log.d(TAG, "LE Audio not supported: Android version < 13")
            return false
        }

        val adapter = bluetoothAdapter ?: return false

        return try {
            val supported = adapter.isLeAudioBroadcastSourceSupported == BluetoothStatusCodes.FEATURE_SUPPORTED
            Log.d(TAG, "LE Audio Broadcast Source supported: $supported")
            supported
        } catch (e: Exception) {
            Log.w(TAG, "Error checking LE Audio support: ${e.message}")
            // Even if this check fails, we can still try to scan for broadcasts
            true
        }
    }

    private fun startScanWithEventSink(events: EventChannel.EventSink?) {
        val currentScanner = scanner
        if (currentScanner == null) {
            events?.error("SCANNER_NOT_AVAILABLE", "Bluetooth scanner not available", null)
            return
        }

        scanJob = scope.launch {
            try {
                currentScanner.startScan().collect { broadcast ->
                    events?.success(mapOf(
                        "address" to broadcast.address,
                        "addressType" to broadcast.addressType,
                        "name" to broadcast.name,
                        "rssi" to broadcast.rssi,
                        "broadcastId" to broadcast.broadcastId,
                        "advertisingSid" to broadcast.advertisingSid,
                        "isEncrypted" to broadcast.isEncrypted
                    ))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Scan error: ${e.message}")
                events?.error("SCAN_ERROR", e.message, null)
            }
        }
    }

    private fun stopScan() {
        scanJob?.cancel()
        scanner?.stopScan()
    }
}
