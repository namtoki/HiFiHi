import 'dart:async';
import 'package:flutter/services.dart';

class DiscoveredBroadcast {
  final String address;
  final int addressType;
  final String? name;
  final int rssi;
  final int broadcastId;
  final int advertisingSid;
  final bool isEncrypted;

  DiscoveredBroadcast({
    required this.address,
    required this.addressType,
    this.name,
    required this.rssi,
    required this.broadcastId,
    required this.advertisingSid,
    required this.isEncrypted,
  });

  factory DiscoveredBroadcast.fromMap(Map<String, dynamic> map) {
    return DiscoveredBroadcast(
      address: map['address'] as String,
      addressType: map['addressType'] as int,
      name: map['name'] as String?,
      rssi: map['rssi'] as int,
      broadcastId: map['broadcastId'] as int,
      advertisingSid: map['advertisingSid'] as int,
      isEncrypted: map['isEncrypted'] as bool,
    );
  }

  String get displayName =>
      name ?? 'Broadcast ${broadcastId.toRadixString(16).toUpperCase().padLeft(6, '0')}';

  String get broadcastIdHex =>
      broadcastId.toRadixString(16).toUpperCase().padLeft(6, '0');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredBroadcast &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}

class AuracastService {
  static const _methodChannel = MethodChannel('com.auracast.auracast_hub/method');
  static const _scanEventChannel = EventChannel('com.auracast.auracast_hub/scan');

  static final AuracastService _instance = AuracastService._internal();
  factory AuracastService() => _instance;
  AuracastService._internal();

  Future<bool> isLeAudioSupported() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isLeAudioSupported') ?? false;
    } on PlatformException catch (e) {
      print('Error checking LE Audio support: ${e.message}');
      return false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isBluetoothEnabled') ?? false;
    } on PlatformException catch (e) {
      print('Error checking Bluetooth status: ${e.message}');
      return false;
    }
  }

  Stream<DiscoveredBroadcast> get scanStream {
    return _scanEventChannel.receiveBroadcastStream().map((event) {
      return DiscoveredBroadcast.fromMap(Map<String, dynamic>.from(event));
    });
  }

  Future<void> stopScan() async {
    try {
      await _methodChannel.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      print('Error stopping scan: ${e.message}');
    }
  }
}
