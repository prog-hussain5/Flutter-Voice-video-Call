import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/call_provider.dart';
import '../utils/app_colors.dart';

class CallControls extends StatelessWidget {
  final VoidCallback onEndCall;

  const CallControls({
    super.key,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Consumer<CallProvider>(
        builder: (context, callProvider, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute Button
              _buildControlButton(
                icon: callProvider.isMuted ? Icons.mic_off : Icons.mic,
                isActive: !callProvider.isMuted,
                onTap: () => callProvider.toggleMute(),
                tooltip: callProvider.isMuted ? 'إلغاء الكتم' : 'كتم الصوت',
              ),
              
              // Video Toggle Button
              _buildControlButton(
                icon: callProvider.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                isActive: callProvider.isVideoEnabled,
                onTap: () => callProvider.toggleVideo(),
                tooltip: callProvider.isVideoEnabled ? 'إيقاف الفيديو' : 'تشغيل الفيديو',
              ),
              
              // Speaker Button
              _buildControlButton(
                icon: callProvider.isSpeakerEnabled ? Icons.volume_up : Icons.volume_down,
                isActive: callProvider.isSpeakerEnabled,
                onTap: () => callProvider.toggleSpeaker(),
                tooltip: callProvider.isSpeakerEnabled ? 'إيقاف السماعة' : 'تشغيل السماعة',
              ),
              
              // Camera Switch Button
              _buildControlButton(
                icon: Icons.flip_camera_ios,
                isActive: true,
                onTap: () => callProvider.switchCamera(),
                tooltip: 'تبديل الكاميرا',
              ),
              
              // End Call Button
              _buildEndCallButton(onEndCall),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? AppColors.activeButton.withOpacity(0.2)
                : AppColors.muteButton.withOpacity(0.2),
            border: Border.all(
              color: isActive 
                  ? AppColors.activeButton
                  : AppColors.muteButton,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isActive 
                ? AppColors.activeButton
                : AppColors.muteButton,
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEndCallButton(VoidCallback onTap) {
    return Tooltip(
      message: 'إنهاء المكالمة',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: AppColors.endCallGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.callReject.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.call_end,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      ),
    );
  }
}