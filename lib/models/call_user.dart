class CallUser {
  final int uid;
  final String name;
  final bool isLocal;
  bool isMuted;
  bool isVideoEnabled;
  
  CallUser({
    required this.uid,
    required this.name,
    required this.isLocal,
    this.isMuted = false,
    this.isVideoEnabled = true,
  });
  
  CallUser copyWith({
    int? uid,
    String? name,
    bool? isLocal,
    bool? isMuted,
    bool? isVideoEnabled,
  }) {
    return CallUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isLocal: isLocal ?? this.isLocal,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
    );
  }
}