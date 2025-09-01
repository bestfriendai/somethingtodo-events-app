import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../widgets/cards/premium_event_card.dart';
import '../../widgets/cards/mini_event_card.dart';

class EventCardsDemo extends StatefulWidget {
  const EventCardsDemo({Key? key}) : super(key: key);

  @override
  State<EventCardsDemo> createState() => _EventCardsDemoState();
}

class _EventCardsDemoState extends State<EventCardsDemo> {
  final ScrollController _scrollController = ScrollController();
  bool _showMiniCards = false;
  Set<String> _likedEvents = {};
  Set<String> _savedEvents = {};
  Set<String> _hiddenEvents = {};

  final List<Map<String, dynamic>> _premiumEvents = [
    {
      'id': '1',
      'title': 'Coachella Music Festival',
      'description': 'The biggest music festival with world-class artists and unforgettable experiences',
      'imageUrl': 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
      'category': 'Music',
      'price': 450.0,
      'distance': '2.5 mi',
      'dateTime': DateTime.now().add(const Duration(days: 30)),
      'attendeeAvatars': [
        'https://i.pravatar.cc/150?img=1',
        'https://i.pravatar.cc/150?img=2',
        'https://i.pravatar.cc/150?img=3',
        'https://i.pravatar.cc/150?img=4',
      ],
      'totalAttendees': 250,
      'isPremium': true,
    },
    {
      'id': '2',
      'title': 'Tech Summit 2025',
      'description': 'Connect with industry leaders and explore cutting-edge technology',
      'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
      'category': 'Tech',
      'price': 199.0,
      'distance': '1.2 mi',
      'dateTime': DateTime.now().add(const Duration(days: 15)),
      'attendeeAvatars': [
        'https://i.pravatar.cc/150?img=5',
        'https://i.pravatar.cc/150?img=6',
        'https://i.pravatar.cc/150?img=7',
      ],
      'totalAttendees': 85,
      'isPremium': true,
    },
    {
      'id': '3',
      'title': 'Food & Wine Festival',
      'description': 'Savor culinary delights from renowned chefs and wineries',
      'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1',
      'category': 'Food',
      'price': 0.0,
      'distance': '0.8 mi',
      'dateTime': DateTime.now().add(const Duration(days: 7)),
      'attendeeAvatars': [
        'https://i.pravatar.cc/150?img=8',
        'https://i.pravatar.cc/150?img=9',
      ],
      'totalAttendees': 120,
      'isPremium': false,
    },
    {
      'id': '4',
      'title': 'Art Gallery Opening',
      'description': 'Experience contemporary art from emerging artists worldwide',
      'imageUrl': 'https://images.unsplash.com/photo-1531913764164-f85c52e6e654',
      'category': 'Art',
      'price': 75.0,
      'distance': '3.0 mi',
      'dateTime': DateTime.now().add(const Duration(days: 3)),
      'attendeeAvatars': [
        'https://i.pravatar.cc/150?img=10',
        'https://i.pravatar.cc/150?img=11',
        'https://i.pravatar.cc/150?img=12',
        'https://i.pravatar.cc/150?img=13',
        'https://i.pravatar.cc/150?img=14',
      ],
      'totalAttendees': 45,
      'isPremium': true,
    },
  ];

  final List<Map<String, dynamic>> _miniEvents = [
    {
      'id': 'm1',
      'title': 'Morning Yoga Session',
      'subtitle': 'Start your day with relaxation',
      'imageUrl': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
      'category': 'Wellness',
      'price': 15.0,
      'time': '6:00 AM',
      'isPremium': false,
    },
    {
      'id': 'm2',
      'title': 'Basketball Tournament',
      'subtitle': '3v3 street basketball championship',
      'imageUrl': 'https://images.unsplash.com/photo-1546519638-68e109498ffc',
      'category': 'Sports',
      'price': 0.0,
      'time': '2:00 PM',
      'isPremium': false,
    },
    {
      'id': 'm3',
      'title': 'Startup Networking',
      'subtitle': 'Connect with entrepreneurs and investors',
      'imageUrl': 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7',
      'category': 'Business',
      'price': 50.0,
      'time': '6:30 PM',
      'isPremium': true,
    },
    {
      'id': 'm4',
      'title': 'Live Jazz Night',
      'subtitle': 'Smooth jazz with local artists',
      'imageUrl': 'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f',
      'category': 'Music',
      'price': 25.0,
      'time': '8:00 PM',
      'isPremium': false,
    },
    {
      'id': 'm5',
      'title': 'Cooking Masterclass',
      'subtitle': 'Learn Italian cuisine from chef Marco',
      'imageUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136',
      'category': 'Food',
      'price': 80.0,
      'time': '11:00 AM',
      'isPremium': true,
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleLike(String eventId) {
    setState(() {
      if (_likedEvents.contains(eventId)) {
        _likedEvents.remove(eventId);
      } else {
        _likedEvents.add(eventId);
      }
    });
  }

  void _toggleSave(String eventId) {
    setState(() {
      if (_savedEvents.contains(eventId)) {
        _savedEvents.remove(eventId);
      } else {
        _savedEvents.add(eventId);
      }
    });
  }

  void _hideEvent(String eventId) {
    setState(() {
      _hiddenEvents.add(eventId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Event hidden'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _hiddenEvents.remove(eventId);
            });
          },
        ),
      ),
    );
  }

  void _shareEvent(String eventId) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would open share sheet'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showEventDetails(String eventId, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.grey[900]!.withOpacity(0.9),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Event Details Would Go Here',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Premium Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showMiniCards ? Icons.view_agenda : Icons.view_carousel,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _showMiniCards = !_showMiniCards;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _showMiniCards
                      ? _buildMiniCardsList()
                      : _buildPremiumCardsList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget _buildPremiumCardsList() {
    return ListView.builder(
      key: const ValueKey('premium'),
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _premiumEvents.length,
      itemBuilder: (context, index) {
        final event = _premiumEvents[index];
        return PremiumEventCard(
          id: event['id'],
          title: event['title'],
          description: event['description'],
          imageUrl: event['imageUrl'],
          category: event['category'],
          price: event['price'],
          distance: event['distance'],
          dateTime: event['dateTime'],
          attendeeAvatars: List<String>.from(event['attendeeAvatars']),
          totalAttendees: event['totalAttendees'],
          isPremium: event['isPremium'],
          isLiked: _likedEvents.contains(event['id']),
          isSaved: _savedEvents.contains(event['id']),
          onTap: () => _showEventDetails(event['id'], event['title']),
          onLike: () => _toggleLike(event['id']),
          onSave: () => _toggleSave(event['id']),
          onShare: () => _shareEvent(event['id']),
        );
      },
    );
  }

  Widget _buildMiniCardsList() {
    final visibleEvents = _miniEvents
        .where((event) => !_hiddenEvents.contains(event['id']))
        .toList();

    return ListView.builder(
      key: const ValueKey('mini'),
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: visibleEvents.length + 2, // Add loading cards at the end
      itemBuilder: (context, index) {
        if (index >= visibleEvents.length) {
          // Show skeleton loading cards
          return const MiniEventCard(
            id: 'loading',
            title: '',
            subtitle: '',
            imageUrl: '',
            category: '',
            time: '',
            isLoading: true,
          );
        }

        final event = visibleEvents[index];
        return MiniEventCard(
          id: event['id'],
          title: event['title'],
          subtitle: event['subtitle'],
          imageUrl: event['imageUrl'],
          category: event['category'],
          price: event['price'],
          time: event['time'],
          isPremium: event['isPremium'],
          isSaved: _savedEvents.contains(event['id']),
          onTap: () => _showEventDetails(event['id'], event['title']),
          onSave: () => _toggleSave(event['id']),
          onShare: () => _shareEvent(event['id']),
          onHide: () => _hideEvent(event['id']),
          onLongPress: () {
            debugPrint('Long press on ${event['title']}');
          },
        );
      },
    );
  }
}