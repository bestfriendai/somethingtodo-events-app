import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/user.dart';
import '../../models/event.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/event_card.dart';
import '../events/event_details_screen.dart';
import 'settings_screen.dart';
import '../premium/premium_screen.dart';
import '../favorites/favorites_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _avatarAnimationController;
  late AnimationController _statsAnimationController;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _avatarAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _statsAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    _statsAnimationController.dispose();
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return _buildSignInPrompt();
          }

          return RefreshIndicator(
            onRefresh: _loadUserData,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(authProvider.currentUser!),
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
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Sign in to access your profile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Save your favorite events, get personalized recommendations, and sync across devices.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildSliverAppBar(AppUser user) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      title: Text(user.displayName ?? 'Profile'),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.settings),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor],
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
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? Text(
                                      user.displayName
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          'U',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            if (user.isPremium)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
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
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  if (user.isPremium) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                  ],

                  const SizedBox(height: 16),

                  // Edit Profile Button
                  OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
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
        child: Card(
          color: AppTheme.warningColor,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PremiumScreen()),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
        child: Card(
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
              const Divider(height: 1),
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
              const Divider(height: 1),
              _buildMenuItem(
                Icons.history,
                'Event History',
                'Events you\'ve attended',
                () {
                  // Navigate to event history
                },
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.rate_review,
                'My Reviews',
                'Reviews you\'ve written',
                () {
                  // Navigate to reviews
                },
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.help_outline,
                'Help & Support',
                'Get help or contact support',
                () {
                  // Navigate to help
                },
              ),
              const Divider(height: 1),
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

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                if (eventsProvider.favoriteEvents.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start exploring events to see your activity here',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
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
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update user profile
              // authProvider.updateProfile(...)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
