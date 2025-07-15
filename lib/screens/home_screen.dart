import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_voice_call/widgets/custom_text_field.dart';
import 'package:flutter_voice_call/widgets/gradiant_buttom.dart';
import '../utils/app_colors.dart';
import 'call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _channelController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : [AppColors.background, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                
                // App Logo and Title
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.videocam_rounded,
                              size: 60.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'مرحباً بك في أجورا',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'ابدأ مكالمة صوتية أو مرئية عالية الجودة',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // Channel Input
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _channelController,
                            hintText: 'أدخل اسم القناة',
                            prefixIcon: Icons.meeting_room_rounded,
                          ),
                          SizedBox(height: 32.h),
                          
                          // Call Options
                          Row(
                            children: [
                              Expanded(
                                child: GradientButton(
                                  onPressed: () => _startCall(false),
                                  text: 'مكالمة فردية',
                                  gradient: AppColors.callGradient,
                                  icon: Icons.person_rounded,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: GradientButton(
                                  onPressed: () => _startCall(true),
                                  text: 'مكالمة جماعية',
                                  gradient: AppColors.primaryGradient,
                                  icon: Icons.group_rounded,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24.h),
                          
                          // Quick Join Button
                          GradientButton(
                            onPressed: () => _quickJoin(),
                            text: 'انضمام سريع',
                            gradient: const [
                              Color(0xFFFF6B6B),
                              Color(0xFFFF8E8E),
                            ],
                            icon: Icons.flash_on_rounded,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 40.h),
                
                // Features List
                _buildFeaturesList(isDark),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      'مكالمات عالية الجودة HD',
      'دعم المكالمات الجماعية',
      'تشفير آمن للمكالمات',
      'واجهة سهلة الاستخدام',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المميزات:',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        ...features.map((feature) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                feature,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _startCall(bool isGroupCall) {
    final channelName = _channelController.text.trim();
    if (channelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى إدخال اسم القناة'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelName: channelName,
          isGroupCall: isGroupCall,
        ),
      ),
    );
  }

  void _quickJoin() {
    final channelName = 'quick_${DateTime.now().millisecondsSinceEpoch}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelName: channelName,
          isGroupCall: false,
        ),
      ),
    );
  }
}