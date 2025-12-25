import 'dart:collection';

import '../network/audio_packet.dart';

/// Jitter buffer for smooth audio playback.
/// Buffers incoming packets and releases them at the correct time.
class AudioBuffer {
  final int targetBufferMs;
  final int sampleRate;
  final int bytesPerSample;

  final SplayTreeMap<int, AudioPacket> _packets = SplayTreeMap();
  int _nextExpectedSeq = 0;
  int _lastPlayedTimeUs = 0;
  bool _isBuffering = true;
  int _minBufferPackets = 5; // Minimum packets before starting playback

  /// Statistics
  int _packetsReceived = 0;
  int _packetsDropped = 0;
  int _packetsLate = 0;

  AudioBuffer({
    this.targetBufferMs = 100,
    this.sampleRate = 48000,
    this.bytesPerSample = 2,
  }) {
    // Calculate minimum buffer packets based on target buffer time
    // Assuming ~20ms worth of audio per packet
    _minBufferPackets = (targetBufferMs / 20).clamp(3, 10).toInt();
  }

  /// Whether the buffer is still filling up.
  bool get isBuffering => _isBuffering;

  /// Number of packets currently buffered.
  int get bufferedPackets => _packets.length;

  /// Buffer fill level as percentage (0.0 - 1.0).
  double get fillLevel {
    if (_packets.isEmpty) return 0.0;

    final oldestTime = _packets.values.first.playTimeUs;
    final newestTime = _packets.values.last.playTimeUs;
    final bufferedDurationUs = newestTime - oldestTime;
    final targetDurationUs = targetBufferMs * 1000;

    return (bufferedDurationUs / targetDurationUs).clamp(0.0, 1.0);
  }

  /// Add a packet to the buffer.
  void addPacket(AudioPacket packet) {
    _packetsReceived++;

    // Drop very old packets (more than 20 behind expected sequence)
    if (_nextExpectedSeq > 0 && packet.sequenceNumber < _nextExpectedSeq - 20) {
      _packetsDropped++;
      return;
    }

    // Check if packet is very late (already past play time by more than 50ms)
    // Be more lenient to avoid dropping too many packets
    if (_lastPlayedTimeUs > 0 && packet.playTimeUs < _lastPlayedTimeUs - 50000) {
      _packetsLate++;
      return;
    }

    _packets[packet.sequenceNumber] = packet;

    // Check if buffer has enough packets to start playback
    // Use packet count instead of fillLevel for more reliable buffering
    if (_isBuffering && _packets.length >= _minBufferPackets) {
      _isBuffering = false;
    }

    // Limit buffer size to prevent memory issues
    while (_packets.length > 150) {
      _packets.remove(_packets.firstKey());
      _packetsDropped++;
    }
  }

  /// Get the next packet to play if it's time.
  AudioPacket? getNextPacket(int currentTimeUs) {
    if (_isBuffering || _packets.isEmpty) return null;

    // Find packets that should be played
    final readyPackets = _packets.entries
        .where((e) => e.value.playTimeUs <= currentTimeUs)
        .toList();

    if (readyPackets.isEmpty) return null;

    // Return the oldest ready packet
    final entry = readyPackets.first;
    _packets.remove(entry.key);
    _nextExpectedSeq = entry.key + 1;
    _lastPlayedTimeUs = entry.value.playTimeUs;

    // Drop any older packets
    _packets.removeWhere((seq, _) => seq < _nextExpectedSeq);

    return entry.value;
  }

  /// Get all packets ready to be played.
  /// Returns packets in sequence order for smooth playback.
  List<AudioPacket> getReadyPackets(int currentTimeUs) {
    if (_isBuffering || _packets.isEmpty) return [];

    final result = <AudioPacket>[];
    final keysToRemove = <int>[];

    // Get packets that are ready or slightly overdue
    // Include packets up to 30ms ahead to ensure smooth continuous playback
    final lookAheadUs = currentTimeUs + 30000;

    for (final entry in _packets.entries) {
      if (entry.value.playTimeUs <= lookAheadUs) {
        result.add(entry.value);
        keysToRemove.add(entry.key);
        _nextExpectedSeq = entry.key + 1;
        _lastPlayedTimeUs = entry.value.playTimeUs;
      } else {
        break;
      }
    }

    for (final key in keysToRemove) {
      _packets.remove(key);
    }

    return result;
  }

  /// Reset the buffer.
  void reset() {
    _packets.clear();
    _nextExpectedSeq = 0;
    _lastPlayedTimeUs = 0;
    _isBuffering = true;
  }

  /// Get buffer statistics.
  BufferStats getStats() {
    return BufferStats(
      bufferedPackets: _packets.length,
      fillLevel: fillLevel,
      packetsReceived: _packetsReceived,
      packetsDropped: _packetsDropped,
      packetsLate: _packetsLate,
    );
  }
}

class BufferStats {
  final int bufferedPackets;
  final double fillLevel;
  final int packetsReceived;
  final int packetsDropped;
  final int packetsLate;

  const BufferStats({
    required this.bufferedPackets,
    required this.fillLevel,
    required this.packetsReceived,
    required this.packetsDropped,
    required this.packetsLate,
  });

  double get dropRate =>
      packetsReceived > 0 ? packetsDropped / packetsReceived : 0.0;

  double get lateRate =>
      packetsReceived > 0 ? packetsLate / packetsReceived : 0.0;
}
