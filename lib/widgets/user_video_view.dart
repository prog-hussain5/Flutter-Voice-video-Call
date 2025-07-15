import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../providers/call_provider.dart';
import '../models/call_user.dart';
import '../utils/app_colors.dart';

class UserVideoView extends StatelessWidget {
  final CallUser user;
  final bool isFullScreen;

  const UserVideoView({
    super.key,
    required this.user,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, callProvider, child) {
        return Stack(
          children: [
            // Video View
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: isFullScreen ? BorderRadius.zero : BorderRadius.circular(12.r),
              ),
              child: _buildVideoWidget(callProvider),
            ),
            
            // User Info Overlay
            if (!isFullScreen || !user.isVideoEnabled)
              _buildUserInfoOverlay(),
            
            // Mute Indicator
            if (user.isMuted)
              _buildMuteIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildVideoWidget(CallProvider callProvider) {
    if (callProvider.engine == null) {
      return _buildPlaceholder();
    }

    if (user.isLocal) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: callProvider.engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: callProvider.engine!,
          canvas: VideoCanvas(uid: user.uid),
          connection: RtcConnection(channelId: callProvider.channelName),
        ),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: isFullScreen ? BorderRadius.zero : BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isFullScreen ? 120.w : 60.w,
              height: isFullScreen ? 120.w : 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: isFullScreen ? 60.sp : 30.sp,
                color: AppColors.primary,
              ),
            ),
            if (isFullScreen) ...[
              SizedBox(height: 16.h),
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoOverlay() {
    return Positioned(
      bottom: 8.h,
      left: 8.w,
      right: 8.w,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              user.isLocal ? Icons.person : Icons.person_outline,
              size: 16.sp,
              color: Colors.white,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!user.isVideoEnabled) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.videocam_off,
                size: 16.sp,
                color: Colors.white70,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMuteIndicator() {
    return Positioned(
      top: 8.h,
      right: 8.w,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(
          Icons.mic_off,
          size: 16.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}