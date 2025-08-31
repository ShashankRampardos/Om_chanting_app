class OmDetectionState {
  final bool isRecording;
  final bool isDetected;
  final bool isStreamActive;
  final int omCount;

  const OmDetectionState({
    required this.isRecording,
    required this.isDetected,
    required this.isStreamActive,
    required this.omCount,
  });

  OmDetectionState copyWith({
    bool? isRecording,
    bool? isDetected,
    bool? isStreamActive,
    int? omCount,
  }) {
    return OmDetectionState(
      isRecording: isRecording ?? this.isRecording,
      isDetected: isDetected ?? this.isDetected,
      isStreamActive: isStreamActive ?? this.isStreamActive,
      omCount: omCount ?? this.omCount,
    );
  }

  static const initial = OmDetectionState(
    isRecording: false,
    isDetected: false,
    isStreamActive: false,
    omCount: 0,
  );
}
