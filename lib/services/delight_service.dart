import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'platform_interactions.dart';

class DelightService {
  static DelightService? _instance;
  static DelightService get instance => _instance ??= DelightService._();
  DelightService._();

  static const String _easterEggCountKey = 'easter_egg_count';
  static const String _firstLaunchKey = 'first_launch_timestamp';
  
  final Random _random = Random();
  int _easterEggCount = 0;
  int _confettiCount = 0;
  int _heartCount = 0;
  DateTime? _firstLaunchTime;
  
  // Playful messages for different occasions
  static const List<String> _loadingMessages = [
    'Finding the most epic events...',
    'Summoning party vibes...',
    'Asking the event gods for favors...',
    'Loading some serious fun...',
    'Brewing up something amazing...',
    'Collecting all the good vibes...',
    'Hunting down your next adventure...',
    'Shaking up the event calendar...',
    'Mixing the perfect event cocktail...',
    'Assembling your dream weekend...',
  ];
  
  static const List<String> _confettiMessages = [
    'You are absolutely crushing it!',
    'Another one bites the dust!',
    'You have excellent taste!',
    'This deserves a celebration!',
    'You are on fire today!',
    'Making memories like a pro!',
    'Your social calendar is blessed!',
    'Living your best life!',
  ];
  
  static const List<String> _easterEggMessages = [
    'You found a secret! Keep exploring...',
    'Curiosity rewarded! You are awesome!',
    'Hidden gems are the best gems!',
    'Secret unlocked! You have great instincts!',
    'Easter egg hunter extraordinaire!',
    'You have discovered our little secret!',
    'Bonus points for being thorough!',
  ];
  
  static const List<String> _shareMessages = [
    'Spreading the good vibes!',
    'Your friends are so lucky!',
    'Sharing is caring, and you care!',
    'Making the world more fun, one share at a time!',
    'You are the friend everyone needs!',
  ];
  
  static const List<String> _emptyStateMessages = [
    'No events yet? Time to make your own fun!',
    'Your calendar is as clean as your conscience',
    'So empty, you could hear a pin drop... or plan something!',
    'Nothing here but possibilities',
    'Clean slate = endless opportunities',
    'Your future self will thank you for planning ahead',
  ];
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _easterEggCount = prefs.getInt(_easterEggCountKey) ?? 0;
    
    final firstLaunchTimestamp = prefs.getInt(_firstLaunchKey);
    if (firstLaunchTimestamp != null) {
      _firstLaunchTime = DateTime.fromMillisecondsSinceEpoch(firstLaunchTimestamp);
    } else {
      _firstLaunchTime = DateTime.now();
      await prefs.setInt(_firstLaunchKey, _firstLaunchTime!.millisecondsSinceEpoch);
    }
  }
  
  // Celebration Confetti
  void showConfetti(BuildContext context, {String? customMessage}) {
    _confettiCount++;
    PlatformInteractions.mediumImpact();
    
    final message = customMessage ?? _getRandomMessage(_confettiMessages);
    
    // Show confetti overlay
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => ConfettiOverlay(
        onComplete: () => overlayEntry.remove(),
        message: message,
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Achievement check
    if (_confettiCount % 10 == 0) {
      _showAchievement(context, 'Celebration Master!', 'You have triggered ${ _confettiCount} celebrations!');
    }
  }
  
  // Heart explosion for likes
  void showHeartExplosion(BuildContext context, Offset position) {
    _heartCount++;
    PlatformInteractions.lightImpact();
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => HeartExplosion(
        position: position,
        onComplete: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  // Easter egg discovery
  void triggerEasterEgg(BuildContext context, String eggType) async {
    _easterEggCount++;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_easterEggCountKey, _easterEggCount);
    
    PlatformInteractions.heavyImpact();
    
    final message = _getRandomMessage(_easterEggMessages);
    _showToastWithAnimation(context, message, Icons.egg, Colors.orange);
    
    // Special rewards for dedicated explorers
    if (_easterEggCount == 5) {
      _showAchievement(context, 'Explorer!', 'You have found 5 easter eggs!');
    } else if (_easterEggCount == 15) {
      _showAchievement(context, 'Master Detective!', 'You have discovered 15 hidden secrets!');
    }
  }
  
  // Loading with personality
  String getRandomLoadingMessage() {
    return _getRandomMessage(_loadingMessages);
  }
  
  String getRandomEmptyStateMessage() {
    return _getRandomMessage(_emptyStateMessages);
  }
  
  String getRandomShareMessage() {
    return _getRandomMessage(_shareMessages);
  }
  
  // Fun facts based on usage
  String? getDayStreakMessage() {
    if (_firstLaunchTime == null) return null;
    
    final daysSinceLaunch = DateTime.now().difference(_firstLaunchTime!).inDays;
    
    if (daysSinceLaunch == 7) {
      return 'One week of epic event hunting! You are on a roll!';
    } else if (daysSinceLaunch == 30) {
      return 'One month of adventures planned! You are a scheduling superstar!';
    } else if (daysSinceLaunch == 100) {
      return '100 days of making memories! You are officially legendary!';
    }
    
    return null;
  }
  
  // Time-based easter eggs
  String? getTimeBasedMessage() {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    
    // 11:11 wish time
    if ((hour == 11 || hour == 23) && minute == 11) {
      return 'It is 11:11! Make a wish for your next amazing event!';
    }
    
    // Weekend motivation
    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.friday && hour >= 17) {
      return 'FRIDAY EVENING! Time to find something epic for the weekend!';
    }
    
    // Late night browsing
    if (hour >= 23 || hour <= 5) {
      return 'Night owl mode activated! Planning tomorrow\'s adventures?';
    }
    
    return null;
  }
  
  // Secret konami code counter
  int _konamiSequence = 0;
  static const List<String> _konamiCode = ['up', 'up', 'down', 'down', 'left', 'right', 'left', 'right'];
  
  void inputKonamiDirection(String direction, BuildContext context) {
    if (_konamiCode[_konamiSequence] == direction) {
      _konamiSequence++;
      if (_konamiSequence >= _konamiCode.length) {
        _konamiSequence = 0;
        _triggerKonamiEasterEgg(context);
      }
    } else {
      _konamiSequence = 0;
    }
  }
  
  void _triggerKonamiEasterEgg(BuildContext context) {
    showConfetti(context, customMessage: 'KONAMI CODE UNLOCKED! You are a true gamer!');
    _showAchievement(context, '🎮 Gaming Legend!', 'You entered the legendary Konami Code!');
  }
  
  // Helper methods
  String _getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }
  
  void _showAchievement(BuildContext context, String title, String description) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => AchievementToast(
        title: title,
        description: description,
        onComplete: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  void _showToastWithAnimation(BuildContext context, String message, IconData icon, Color color) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => DelightToast(
        message: message,
        icon: icon,
        color: color,
        onComplete: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  // Shake detection easter egg
  void onShakeDetected(BuildContext context) {
    final messages = [
      'Shake it off! Here are some fresh events!',
      'Someone\'s excited! Let\'s find you something fun!',
      'Shake to refresh? We love the enthusiasm!',
      'Whoa there! Refreshing your adventure list!',
    ];
    
    _showToastWithAnimation(context, _getRandomMessage(messages), Icons.refresh, Colors.blue);
    PlatformInteractions.mediumImpact();
  }
  
  // Long press easter eggs
  void onLongPress(BuildContext context, String element) {
    final messages = {
      'logo': 'You found our logo secret! We love attention to detail!',
      'search': 'Persistent searcher! We admire your dedication!',
      'favorite': 'You REALLY love that heart button! We get it!',
      'profile': 'Getting to know yourself better? We approve!',
    };
    
    if (messages.containsKey(element)) {
      triggerEasterEgg(context, element);
    }
  }
  
  // Mini celebration for small interactions
  void showMiniCelebration(BuildContext context, String emoji) {
    PlatformInteractions.lightImpact();
    _showToastWithAnimation(context, '$emoji Nice!', Icons.celebration, Colors.amber);
  }
  
  // Sparkle effect for special interactions
  void showSparkleEffect(BuildContext context, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => SparkleEffect(
        position: position,
        onComplete: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

// Confetti Overlay Widget
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final String message;
  
  const ConfettiOverlay({
    super.key,
    required this.onComplete,
    required this.message,
  });
  
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _generateParticles();
    _controller.forward().then((_) => widget.onComplete());
  }
  
  void _generateParticles() {
    final random = Random();
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];
    
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        startX: random.nextDouble(),
        startY: -0.1,
        endX: random.nextDouble(),
        endY: 1.2,
        color: colors[random.nextInt(colors.length)],
        size: random.nextDouble() * 10 + 5,
        rotation: random.nextDouble() * 6.28,
      ));
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(_particles, _controller.value),
                size: Size.infinite,
              );
            },
          ),
          // Message
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate(delay: 500.ms)
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8))
              .slideY(begin: 0.3),
          ),
        ],
      ),
    );
  }
}

class ConfettiParticle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final Color color;
  final double size;
  final double rotation;
  
  const ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
    required this.size,
    required this.rotation,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  
  ConfettiPainter(this.particles, this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()..color = particle.color;
      
      final x = (particle.startX + (particle.endX - particle.startX) * progress) * size.width;
      final y = (particle.startY + (particle.endY - particle.startY) * progress) * size.height;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation * progress * 4);
      
      // Draw different shapes for variety
      if (particle.size > 8) {
        // Star shape
        final path = Path();
        for (int i = 0; i < 5; i++) {
          final angle = (i * 2 * pi / 5) - pi / 2;
          final x = cos(angle) * particle.size / 2;
          final y = sin(angle) * particle.size / 2;
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        // Circle
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      }
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Heart Explosion Widget
class HeartExplosion extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;
  
  const HeartExplosion({
    super.key,
    required this.position,
    required this.onComplete,
  });
  
  @override
  State<HeartExplosion> createState() => _HeartExplosionState();
}

class _HeartExplosionState extends State<HeartExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<HeartParticle> _hearts = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _generateHearts();
    _controller.forward().then((_) => widget.onComplete());
  }
  
  void _generateHearts() {
    final random = Random();
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) + random.nextDouble() * 0.5;
      _hearts.add(HeartParticle(
        startX: widget.position.dx,
        startY: widget.position.dy,
        endX: widget.position.dx + cos(angle) * 100,
        endY: widget.position.dy + sin(angle) * 100,
        size: random.nextDouble() * 15 + 10,
      ));
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: HeartExplosionPainter(_hearts, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class HeartParticle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  
  const HeartParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
  });
}

class HeartExplosionPainter extends CustomPainter {
  final List<HeartParticle> hearts;
  final double progress;
  
  HeartExplosionPainter(this.hearts, this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.withOpacity(1 - progress)
      ..style = PaintingStyle.fill;
    
    for (final heart in hearts) {
      final x = heart.startX + (heart.endX - heart.startX) * progress;
      final y = heart.startY + (heart.endY - heart.startY) * progress;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(heart.size / 20 * (1 - progress * 0.5));
      
      // Draw heart shape
      final path = Path();
      path.moveTo(0, 5);
      path.cubicTo(-10, -10, -20, -5, -10, 0);
      path.cubicTo(-5, -5, 0, 0, 0, 5);
      path.cubicTo(0, 0, 5, -5, 10, 0);
      path.cubicTo(20, -5, 10, -10, 0, 5);
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Sparkle Effect Widget
class SparkleEffect extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;
  
  const SparkleEffect({
    super.key,
    required this.position,
    required this.onComplete,
  });
  
  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<SparkleParticle> _sparkles = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _generateSparkles();
    _controller.forward().then((_) => widget.onComplete());
  }
  
  void _generateSparkles() {
    final random = Random();
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + random.nextDouble() * 0.3;
      _sparkles.add(SparkleParticle(
        startX: widget.position.dx,
        startY: widget.position.dy,
        endX: widget.position.dx + cos(angle) * 30,
        endY: widget.position.dy + sin(angle) * 30,
        size: random.nextDouble() * 4 + 2,
      ));
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: SparkleEffectPainter(_sparkles, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class SparkleParticle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  
  const SparkleParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
  });
}

class SparkleEffectPainter extends CustomPainter {
  final List<SparkleParticle> sparkles;
  final double progress;
  
  SparkleEffectPainter(this.sparkles, this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(1 - progress)
      ..style = PaintingStyle.fill;
    
    for (final sparkle in sparkles) {
      final x = sparkle.startX + (sparkle.endX - sparkle.startX) * progress;
      final y = sparkle.startY + (sparkle.endY - sparkle.startY) * progress;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * pi * 2);
      
      // Draw star shape
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = (i * pi / 2);
        final x = cos(angle) * sparkle.size;
        final y = sin(angle) * sparkle.size;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Achievement Toast
class AchievementToast extends StatefulWidget {
  final String title;
  final String description;
  final VoidCallback onComplete;
  
  const AchievementToast({
    super.key,
    required this.title,
    required this.description,
    required this.onComplete,
  });
  
  @override
  State<AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<AchievementToast> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), widget.onComplete);
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate()
          .slideX(begin: 1, duration: 600.ms, curve: Curves.elasticOut)
          .fadeIn()
          .then(delay: 3.seconds)
          .slideX(end: 1, duration: 400.ms)
          .fadeOut(),
      ),
    );
  }
}

// Delight Toast
class DelightToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onComplete;
  
  const DelightToast({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    required this.onComplete,
  });
  
  @override
  State<DelightToast> createState() => _DelightToastState();
}

class _DelightToastState extends State<DelightToast> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), widget.onComplete);
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 100,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate()
          .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut)
          .fadeIn()
          .then(delay: 2.5.seconds)
          .scale(end: const Offset(0.8, 0.8), duration: 200.ms)
          .fadeOut(),
      ),
    );
  }
}