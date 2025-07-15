import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

class CallInfoHeader extends StatefulWidget {
  final String channelName;
  final bool isGroupCall;
  final int userCount;

  const CallInfoHeader({
    super.key,
    required this.channelName,
    required this.isGroupCall,
    required this.userCount,
  });

  @override
  State<CallInfoHeader> createState() => _CallInfoHeaderState();
}

class _CallInfoHeaderState extends State<CallInfoHeader> {
  late Stream<String> _timerStream;
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    _callStartTime = DateTime.now();
    _timerStream = _createTimerStream();
  }

  Stream<String> _createTimerStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      if (_callStartTime != null) {
        final duration = DateTime.now().difference(_callStartTime!);
        yield _formatDuration(duration);
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Call Status Indicator
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                
                // Channel Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.channelName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.isGroupCall 
                            ? 'مكالمة جماعية • ${widget.userCount} مشارك'
                            : 'مكالمة فردية',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Call Timer
                StreamBuilder<String>(
                  stream: _timerStream,
                  builder: (context, snapshot) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        snapshot.data ?? '00:00',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            // Connection Quality Indicator
            if (widget.isGroupCall) ...[
              SizedBox(height: 12.h),
              _buildConnectionQuality(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionQuality() {
    return Row(
      children: [
        Icon(
          Icons.signal_cellular_4_bar,
          size: 16.sp,
          color: AppColors.success,
        ),
        SizedBox(width: 6.w),
        Text(
          'جودة الاتصال ممتازة',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
        const Spacer(),
        
        // Encryption Indicator
        Icon(
          Icons.lock,
          size: 16.sp,
          color: AppColors.success,
        ),
        SizedBox(width: 6.w),
        Text(
          'مشفر',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}