import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:math' as math;

import '../../models/user.dart';
import '../../models/event.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/event_card.dart';
import '../events/event_details_screen.dart';
import '../settings/glass_settings_screen.dart';
import '../premium/premium_screen.dart';
import '../favorites/favorites_screen.dart';
import '../notifications/notifications_screen.dart';

class GlassProfileScreen extends StatefulWidget {
  const GlassProfileScreen({super.key});

  @override
  State<GlassProfileScreen> createState() => _GlassProfileScreenState();
}

class _GlassProfileScreenState extends State<GlassProfileScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _avatarAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _orbAnimationController;
  late List<AnimationController> _orbControllers;
  late List<FloatingOrb> _orbs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _avatarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _orbAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _initializeOrbs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _avatarAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _statsAnimationController.forward();
      });
    });
  }

  void _initializeOrbs() {
    _orbControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(seconds: 10 + (index * 2)),
        vsync: this,
      )..repeat(),
    );

    _orbs = List.generate(
      5,
      (index) => FloatingOrb(
        size: 20 + (index * 15).toDouble(),
        color: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.05),
        ][index],
        controller: _orbControllers[index],
      ),
    );
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    _statsAnimationController.dispose();
    _orbAnimationController.dispose();
    for (var controller in _orbControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    final eventsProvider = context.read<EventsProvider>();

    if (authProvider.currentUser != null) {
      await eventsProvider.loadFavoriteEvents(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated floating orbs background
          ...List.generate(
            _orbs.length,
            (index) => AnimatedBuilder(
              animation: _orbs[index].controller,
              builder: (context, child) => _buildFloatingOrb(_orbs[index]),
            ),
          ),

          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.currentUser == null) {
                return _buildSignInPrompt();
              }

              return RefreshIndicator(
                onRefresh: _loadUserData,
                backgroundColor: Colors.transparent,
                color: Colors.white,
                child: CustomScrollView(
                  slivers: [
                    _buildGlassAppBar(authProvider.currentUser!),
                    _buildUserInfo(authProvider.currentUser!),
                    _buildPremiumBanner(authProvider.currentUser!),
                    _buildQuickStats(),
                    _buildMenuItems(),
                    _buildRecentActivity(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(FloatingOrb orb) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: (screenWidth * 0.1) + (screenWidth * 0.8 * orb.controller.value),
      top:
          (screenHeight * 0.1) +
          (screenHeight * 0.8 * math.sin(orb.controller.value * 2 * math.pi)),
      child: Container(
        width: orb.size,
        height: orb.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: orb.color,
          boxShadow: [
            BoxShadow(
              color: orb.color.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 400,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sign in to access your profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Save your favorite events, get personalized recommendations, and sync across devices.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GlassmorphicContainer(
                  width: 200,
                  height: 50,
                  borderRadius: 25,
                  blur: 10,
                  alignment: Alignment.center,
                  border: 1,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/auth'),
                    borderRadius: BorderRadius.circular(25),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildGlassAppBar(AppUser user) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        user.displayName ?? 'Profile',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        GlassmorphicContainer(
          width: 40,
          height: 40,
          borderRadius: 20,
          blur: 10,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GlassSettingsScreen(),
              ),
            ),
            icon: const Icon(Icons.settings, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black12],
            ),
          ),
          child: const Center(
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(AppUser user) {
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: const Offset(0, -50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 200,
            borderRadius: 20,
            blur: 20,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  AnimatedBuilder(
                    animation: _avatarAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _avatarAnimationController.value,
                        child: Stack(
                          children: [
                            GlassmorphicContainer(
                              width: 100,
                              height: 100,
                              borderRadius: 50,
                              blur: 10,
                              alignment: Alignment.center,
                              border: 2,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              child: ClipOval(
                                child: user.photoUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: user.photoUrl!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            user.displayName
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                'U',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            if (user.isPremium)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GlassmorphicContainer(
                                  width: 24,
                                  height: 24,
                                  borderRadius: 12,
                                  blur: 10,
                                  alignment: Alignment.center,
                                  border: 2,
                                  linearGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.warningColor.withValues(
                                        alpha: 0.8,
                                      ),
                                      AppTheme.warningColor.withValues(
                                        alpha: 0.6,
                                      ),
                                    ],
                                  ),
                                  borderGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Name and email
                  Text(
                    user.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (user.isPremium) ...[
                    const SizedBox(height: 12),
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: 32,
                      borderRadius: 16,
                      blur: 10,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.warningColor.withValues(alpha: 0.2),
                          AppTheme.warningColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.warningColor.withValues(alpha: 0.3),
                          AppTheme.warningColor.withValues(alpha: 0.1),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppTheme.warningColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Premium Member',
                              style: TextStyle(
                                color: AppTheme.warningColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Edit Profile Button
                  GlassmorphicContainer(
                    width: 160,
                    height: 40,
                    borderRadius: 20,
                    blur: 10,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    child: InkWell(
                      onTap: _showEditProfileDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildPremiumBanner(AppUser user) {
    if (user.isPremium) return const SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 80,
          borderRadius: 16,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.warningColor.withValues(alpha: 0.2),
              AppTheme.warningColor.withValues(alpha: 0.1),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.warningColor.withValues(alpha: 0.3),
              AppTheme.warningColor.withValues(alpha: 0.1),
            ],
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PremiumScreen()),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppTheme.warningColor, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Get unlimited recommendations and exclusive events',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3),
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _statsAnimationController,
          builder: (context, child) {
            return Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Favorites',
                        eventsProvider.favoriteEvents.length.toString(),
                        Icons.favorite,
                        AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Events Attended',
                        '12', // This would come from user data
                        Icons.event_available,
                        AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Reviews',
                        '8', // This would come from user data
                        Icons.rate_review,
                        AppTheme.primaryColor,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Transform.scale(
      scale: _statsAnimationController.value,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 100,
        borderRadius: 16,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 200,
          borderRadius: 16,
          blur: 20,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                Icons.favorite,
                'My Favorites',
                'Saved events you love',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.notifications,
                'Notifications',
                'Event reminders and updates',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.history,
                'Event History',
                'Events you\'ve attended',
                () {
                  // Navigate to event history
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.rate_review,
                'My Reviews',
                'Reviews you\'ve written',
                () {
                  // Navigate to reviews
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.help_outline,
                'Help & Support',
                'Get help or contact support',
                () {
                  // Navigate to help
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.logout,
                'Sign Out',
                'Sign out of your account',
                _showSignOutDialog,
                textColor: AppTheme.errorColor,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildRecentActivity() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                if (eventsProvider.favoriteEvents.isEmpty) {
                  return GlassmorphicContainer(
                    width: double.infinity,
                    height: 200,
                    borderRadius: 16,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start exploring events to see your activity here',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: eventsProvider.favoriteEvents
                      .take(3)
                      .map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassmorphicContainer(
                            width: double.infinity,
                            height: 200,
                            borderRadius: 12,
                            blur: 15,
                            alignment: Alignment.center,
                            border: 1,
                            linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                            borderGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                            child: EventCard(
                              event: event,
                              compact: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailsScreen(event: event),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
    );
  }

  void _showEditProfileDialog() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser!;

    final nameController = TextEditingController(text: user.displayName);
    final phoneController = TextEditingController(text: user.phoneNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.phone,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update user profile
              // authProvider.updateProfile(...)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class FloatingOrb {
  final double size;
  final Color color;
  final AnimationController controller;

  FloatingOrb({
    required this.size,
    required this.color,
    required this.controller,
  });
}
