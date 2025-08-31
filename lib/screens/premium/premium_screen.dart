import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _featuresAnimationController;
  late AnimationController _plansAnimationController;
  
  int _selectedPlanIndex = 1; // Default to annual plan
  bool _isProcessing = false;
  
  final List<PremiumPlan> _plans = [
    PremiumPlan(
      id: 'monthly',
      name: 'Monthly',
      price: 9.99,
      period: 'month',
      originalPrice: null,
      badge: null,
    ),
    PremiumPlan(
      id: 'annual',
      name: 'Annual',
      price: 79.99,
      period: 'year',
      originalPrice: 119.88,
      badge: 'Save 33%',
    ),
    PremiumPlan(
      id: 'lifetime',
      name: 'Lifetime',
      price: 199.99,
      period: 'one-time',
      originalPrice: null,
      badge: 'Best Value',
    ),
  ];
  
  final List<PremiumFeature> _features = [
    PremiumFeature(
      icon: Icons.star,
      title: 'Unlimited Event Recommendations',
      description: 'Get personalized AI-powered event suggestions based on your preferences',
      color: AppTheme.warningColor,
    ),
    PremiumFeature(
      icon: Icons.flash_on,
      title: 'Early Access to Events',
      description: 'Be the first to know about exclusive events before they\'re public',
      color: AppTheme.primaryColor,
    ),
    PremiumFeature(
      icon: Icons.notifications_active,
      title: 'Smart Notifications',
      description: 'Advanced notifications for events you\'ll love, delivered at the perfect time',
      color: AppTheme.successColor,
    ),
    PremiumFeature(
      icon: Icons.favorite,
      title: 'Unlimited Favorites',
      description: 'Save as many events as you want without any limits',
      color: AppTheme.errorColor,
    ),
    PremiumFeature(
      icon: Icons.analytics,
      title: 'Event Analytics',
      description: 'Detailed insights about your event preferences and attendance history',
      color: AppTheme.primaryDarkColor,
    ),
    PremiumFeature(
      icon: Icons.support_agent,
      title: 'Priority Support',
      description: '24/7 priority customer support to help you with any issues',
      color: AppTheme.secondaryColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _featuresAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _plansAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _startAnimations();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _featuresAnimationController.dispose();
    _plansAnimationController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _featuresAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _plansAnimationController.forward();
    });
  }

  Future<void> _subscribeToPlan(PremiumPlan plan) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // In a real app, you would implement the payment flow here
      // For now, we'll simulate the process
      await Future.delayed(const Duration(seconds: 2));
      
      // Update user's premium status
      final authProvider = context.read<AuthProvider>();
      // await authProvider.updatePremiumStatus(plan);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully subscribed to ${plan.name} plan!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription failed. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _restorePurchases() async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // In a real app, you would restore purchases here
      await Future.delayed(const Duration(seconds: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No previous purchases found'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to restore purchases'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isPremiumActive) {
            return _buildAlreadyPremiumState();
          }
          
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildHeader(),
              _buildFeatures(),
              _buildPlans(),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlreadyPremiumState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: AppTheme.warningColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'You\'re Premium!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enjoy all the premium features and benefits.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.warningColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.warningColor,
                AppTheme.warningColor.withOpacity(0.8),
              ],
            ),
          ),
          child: AnimatedBuilder(
            animation: _headerAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _headerAnimationController.value,
                child: const Center(
                  child: Icon(
                    Icons.star,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Upgrade to Premium',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock the full potential of event discovery',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('7-day free trial'),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.cancel,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('Cancel anytime'),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5),
    );
  }

  Widget _buildFeatures() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _featuresAnimationController,
              builder: (context, child) {
                return Column(
                  children: _features.map((feature) {
                    final index = _features.indexOf(feature);
                    final delay = index * 0.1;
                    
                    return Transform.translate(
                      offset: Offset(
                        50 * (1 - _featuresAnimationController.value),
                        0,
                      ),
                      child: Opacity(
                        opacity: _featuresAnimationController.value,
                        child: _buildFeatureCard(feature),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(PremiumFeature feature) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _plansAnimationController,
              builder: (context, child) {
                return Column(
                  children: _plans.map((plan) {
                    final index = _plans.indexOf(plan);
                    final isSelected = index == _selectedPlanIndex;
                    
                    return Transform.scale(
                      scale: 0.8 + (0.2 * _plansAnimationController.value),
                      child: Opacity(
                        opacity: _plansAnimationController.value,
                        child: _buildPlanCard(plan, index, isSelected),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PremiumPlan plan, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedPlanIndex,
              onChanged: (value) => setState(() => _selectedPlanIndex = value!),
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (plan.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plan.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (plan.originalPrice != null) ...[
                        Text(
                          '\$${plan.originalPrice!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '\$${plan.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                      Text(
                        plan.period == 'one-time' ? '' : ' / ${plan.period}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing 
                    ? null 
                    : () => _subscribeToPlan(_plans[_selectedPlanIndex]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Start Free Trial',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: _isProcessing ? null : _restorePurchases,
              child: const Text('Restore Purchases'),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Show terms of service
                  },
                  child: const Text('Terms of Service'),
                ),
                const Text(' • '),
                TextButton(
                  onPressed: () {
                    // Show privacy policy
                  },
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class PremiumPlan {
  final String id;
  final String name;
  final double price;
  final String period;
  final double? originalPrice;
  final String? badge;

  PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    this.originalPrice,
    this.badge,
  });
}

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}