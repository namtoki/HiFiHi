package com.auracast.auracast_hub.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.os.Build
import android.util.Log
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

data class DiscoveredBroadcast(
    val address: String,
    val addressType: Int,
    val name: String?,
    val rssi: Int,
    val broadcastId: Int,          // 24-bit Broadcast_ID
    val advertisingSid: Int,        // ADV SID (0x00-0x0F)
    val isEncrypted: Boolean
)

class AuracastScanner(
    private val bluetoothAdapter: BluetoothAdapter
) {
    companion object {
        private const val TAG = "AuracastScanner"
    }

    private var scanner: BluetoothLeScanner? = null
    private var scanCallback: ScanCallback? = null

    fun startScan(): Flow<DiscoveredBroadcast> = callbackFlow {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            close(IllegalStateException("LE Audio requires Android 13+"))
            return@callbackFlow
        }

        scanner = bluetoothAdapter.bluetoothLeScanner
        if (scanner == null) {
            close(IllegalStateException("BluetoothLeScanner not available"))
            return@callbackFlow
        }

        val filter = ScanFilter.Builder()
            .setServiceUuid(BluetoothUuids.BROADCAST_AUDIO_ANNOUNCEMENT_SERVICE)
            .build()

        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setLegacy(false)  // Extended Advertising support required
            .setPhy(ScanSettings.PHY_LE_ALL_SUPPORTED)
            .build()

        scanCallback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                Log.d(TAG, "Scan result: ${result.device.address}, RSSI: ${result.rssi}")
                parseBroadcastSource(result)?.let { broadcast ->
                    Log.d(TAG, "Parsed broadcast: ${broadcast.name ?: broadcast.address}, ID: ${broadcast.broadcastId.toString(16)}")
                    trySend(broadcast)
                }
            }

            override fun onScanFailed(errorCode: Int) {
                Log.e(TAG, "Scan failed with error: $errorCode")
                close(ScanException("Scan failed with error: $errorCode"))
            }
        }

        Log.d(TAG, "Starting Auracast broadcast scan...")
        scanner?.startScan(listOf(filter), settings, scanCallback)

        awaitClose {
            Log.d(TAG, "Stopping scan...")
            stopScan()
        }
    }

    fun stopScan() {
        scanCallback?.let { callback ->
            try {
                scanner?.stopScan(callback)
            } catch (e: Exception) {
                Log.w(TAG, "Error stopping scan: ${e.message}")
            }
        }
        scanCallback = null
    }

    private fun parseBroadcastSource(result: ScanResult): DiscoveredBroadcast? {
        val record = result.scanRecord ?: return null

        // Service Data from Broadcast Audio Announcement
        val serviceData = record.getServiceData(
            BluetoothUuids.BROADCAST_AUDIO_ANNOUNCEMENT_SERVICE
        ) ?: return null

        if (serviceData.size < 4) {
            Log.w(TAG, "Service data too short: ${serviceData.size} bytes")
            return null
        }

        // Parse Broadcast Audio Announcement Service Data
        // Format: Broadcast_ID (3 bytes) + Public Broadcast Announcement features (1 byte)
        val broadcastId = (serviceData[0].toInt() and 0xFF) or
                         ((serviceData[1].toInt() and 0xFF) shl 8) or
                         ((serviceData[2].toInt() and 0xFF) shl 16)

        val pbpFeatures = serviceData[3].toInt() and 0xFF
        val isEncrypted = (pbpFeatures and 0x01) != 0

        return DiscoveredBroadcast(
            address = result.device.address,
            addressType = result.device.addressType,
            name = record.deviceName,
            rssi = result.rssi,
            broadcastId = broadcastId,
            advertisingSid = result.advertisingSid,
            isEncrypted = isEncrypted
        )
    }
}

class ScanException(message: String) : Exception(message)
