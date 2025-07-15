import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_voice_call/config.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/call_user.dart';

class CallProvider extends ChangeNotifier {
  RtcEngine? _engine;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isSpeakerEnabled = true;
  String _channelName = '';
  final List<CallUser> _remoteUsers = [];
  CallUser? _localUser;
  bool _isGroupCall = false;
  
  // Getters
  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isFrontCamera => _isFrontCamera;
  bool get isSpeakerEnabled => _isSpeakerEnabled;
  String get channelName => _channelName;
  List<CallUser> get remoteUsers => _remoteUsers;
  CallUser? get localUser => _localUser;
  bool get isGroupCall => _isGroupCall;
  RtcEngine? get engine => _engine;
  
  // Initialize Agora Engine
  Future<void> initializeEngine() async {
    try {
      await _requestPermissions();
      
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,       
      ));
      
      _registerEventHandlers();
      
      // Enable video by default
      await _engine!.enableVideo();
      await _engine!.enableAudio();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing Agora engine: $e');
    }
  }
  
  // Request permissions
  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
      Permission.camera,
    ].request();
  }
  
  // Register event handlers
  void _registerEventHandlers() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
          _channelName = connection.channelId!;
          _localUser = CallUser(
            uid: connection.localUid!,
            name: 'أنت',
            isLocal: true,
          );
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _remoteUsers.add(CallUser(
            uid: remoteUid,
            name: 'مستخدم $remoteUid',
            isLocal: false,
          ));
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _remoteUsers.removeWhere((user) => user.uid == remoteUid);
          notifyListeners();
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          _isJoined = false;
          _remoteUsers.clear();
          _localUser = null;
          notifyListeners();
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora Error: $err - $msg');
        },
      ),
    );
  }
  
  // Join channel
  Future<void> joinChannel(String channelName, {bool isGroupCall = false}) async {
    if (_engine == null) {
      await initializeEngine();
    }
    
    _isGroupCall = isGroupCall;
    
    try {
      await _engine!.joinChannel(
        token: AgoraConfig.token,
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          audienceLatencyLevel: AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
        ),
      );
    } catch (e) {
      debugPrint('Error joining channel: $e');
    }
  }
  
  // Leave channel
  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }
  
  // Toggle mute
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _engine?.muteLocalAudioStream(_isMuted);
    notifyListeners();
  }
  
  // Toggle video
  Future<void> toggleVideo() async {
    _isVideoEnabled = !_isVideoEnabled;
    await _engine?.muteLocalVideoStream(!_isVideoEnabled);
    notifyListeners();
  }
  
  // Switch camera
  Future<void> switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _engine?.switchCamera();
    notifyListeners();
  }
  
  // Toggle speaker
  Future<void> toggleSpeaker() async {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    await _engine?.setEnableSpeakerphone(_isSpeakerEnabled);
    notifyListeners();
  }
  
  // Dispose
  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}