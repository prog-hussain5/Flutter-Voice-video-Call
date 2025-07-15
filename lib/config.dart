class AgoraConfig {
  // Replace with your Agora App ID
  static const String appId = 'YOUR_AGORA_APP_ID_HERE';
  
  // Replace with your Agora Token (for production)
  // For testing, you can use null or empty string
  static const String token = "YOUR_AGORA_TOKEN_HERE";
  
  // Agora Certificate (for token generation)
  static const String appCertificate = 'YOUR_AGORA_APP_CERTIFICATE_HERE';
  
  // Token expiration time (in seconds)
  static const int tokenExpireTime = 3600;
  
  // Channel settings
  static const int maxUsersPerChannel = 8;
  static const String defaultChannelName = 'flutter_call';
}
