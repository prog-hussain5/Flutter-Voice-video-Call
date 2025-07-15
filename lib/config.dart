class AgoraConfig {
  // Replace with your Agora App ID
  static const String appId = '6ee72f9f598047c79b065de8dbee29d3';
  
  // Replace with your Agora Token (for production)
  // For testing, you can use null or empty string
  static const String token = "007eJxTYODj6T5s/irFcf7lJe/2rnwmfuPrB9bq0t3/Xh6xt6ng9k5VYDBLTTU3SrNMM7W0MDAxTza3TDIwM01JtUhJSk01skwxNtxaktEQyMggUV3AyMgAgSA+C0NJanEJAwMA2HUg4A==";
  
  // Agora Certificate (for token generation)
  static const String appCertificate = 'bf3cac1d1e874470a831095e8942c672';
  
  // Token expiration time (in seconds)
  static const int tokenExpireTime = 3600;
  
  // Channel settings
  static const int maxUsersPerChannel = 8;
  static const String defaultChannelName = 'flutter_call';
}
