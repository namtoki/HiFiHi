package com.auracast.auracast_hub.bluetooth

import android.os.ParcelUuid
import java.util.UUID

object BluetoothUuids {
    // Broadcast Audio Announcement Service (for scanning)
    val BROADCAST_AUDIO_ANNOUNCEMENT_SERVICE: ParcelUuid =
        ParcelUuid.fromString("00001852-0000-1000-8000-00805F9B34FB")

    // Broadcast Audio Scan Service (on earbuds GATT)
    val BASS_SERVICE: UUID =
        UUID.fromString("0000184F-0000-1000-8000-00805F9B34FB")

    // BASS Characteristics
    val BROADCAST_AUDIO_SCAN_CONTROL_POINT: UUID =
        UUID.fromString("00002BC7-0000-1000-8000-00805F9B34FB")

    val BROADCAST_RECEIVE_STATE: UUID =
        UUID.fromString("00002BC8-0000-1000-8000-00805F9B34FB")

    // Client Characteristic Configuration Descriptor
    val CCCD: UUID =
        UUID.fromString("00002902-0000-1000-8000-00805F9B34FB")
}
