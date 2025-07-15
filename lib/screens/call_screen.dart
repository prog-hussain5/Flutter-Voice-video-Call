import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_voice_call/widgets/call_controller.dart';
import 'package:provider/provider.dart';
import '../providers/call_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/user_video_view.dart';
import '../widgets/call_info_header.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final bool isGroupCall;

  const CallScreen({
    super.key,
    required this.channelName,
    required this.isGroupCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> fadeAnimation;
  bool _showControls = true;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    
    // Join the channel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallProvider>().joinChannel(
        widget.channelName,
        isGroupCall: widget.isGroupCall,
      );
    });
    
    // Auto-hide controls after 3 seconds
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _startAutoHideTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _startAutoHideTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallProvider>(
        builder: (context, callProvider, child) {
          if (!callProvider.isJoined) {
            return _buildLoadingScreen();
          }
          
          return GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // Video Views
                _buildVideoViews(callProvider),
                
                // Call Info Header
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CallInfoHeader(
                    channelName: widget.channelName,
                    isGroupCall: widget.isGroupCall,
                    userCount: callProvider.remoteUsers.length + 1,
                  ),
                ),
                
                // Call Controls
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  bottom: _showControls ? 40.h : -200.h,
                  left: 0,
                  right: 0,
                  child: CallControls(
                    onEndCall: () => _endCall(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF000000),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
              ),
              child: Icon(
                Icons.videocam_rounded,
                size: 60.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'جاري الاتصال...',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'القناة: ${widget.channelName}',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 32.h),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViews(CallProvider callProvider) {
    
    if (widget.isGroupCall) {
      return _buildGroupCallView(callProvider);
    } else {
      return _buildOneToOneCallView(callProvider);
    }
  }

  Widget _buildOneToOneCallView(CallProvider callProvider) {
    final remoteUsers = callProvider.remoteUsers;
    
    return Stack(
      children: [
        // Remote user video (full screen)
        if (remoteUsers.isNotEmpty)
          UserVideoView(
            user: remoteUsers.first,
            isFullScreen: true,
          )
        else
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2A2A2A),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
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
                      size: 60.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'في انتظار المشارك...',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Local user video (small overlay)
        if (callProvider.localUser != null)
          Positioned(
            top: 60.h,
            right: 20.w,
            child: Container(
              width: 120.w,
              height: 160.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: UserVideoView(
                  user: callProvider.localUser!,
                  isFullScreen: false,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGroupCallView(CallProvider callProvider) {
    final allUsers = [
      if (callProvider.localUser != null) callProvider.localUser!,
      ...callProvider.remoteUsers,
    ];
    
    if (allUsers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: allUsers.length <= 2 ? 1 : 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.75,
      ),
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        final user = allUsers[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: UserVideoView(
              user: user,
              isFullScreen: false,
            ),
          ),
        );
      },
    );
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkSurface 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'إنهاء المكالمة',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من إنهاء المكالمة؟',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<CallProvider>().leaveChannel();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'إنهاء',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}