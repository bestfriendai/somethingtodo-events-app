class SampleChatResponses {
  static String getResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return "Hello! I'm your AI assistant for discovering events. How can I help you find something amazing to do today?";
    }

    if (message.contains('event') && message.contains('near')) {
      return "I'd love to help you find events nearby! Could you tell me your location or what type of events you're interested in?";
    }

    if (message.contains('music') || message.contains('concert')) {
      return "Music events are always a great choice! I can help you find concerts, festivals, and live performances in your area. What genre are you interested in?";
    }

    if (message.contains('food') || message.contains('restaurant') || message.contains('eat')) {
      return "Food events can be so much fun! From food festivals to cooking classes, there's always something delicious happening. What type of cuisine interests you?";
    }

    if (message.contains('sports') || message.contains('game')) {
      return "Sports events are perfect for getting that adrenaline going! I can find you games, matches, tournaments, and more. What sport are you most excited about?";
    }

    if (message.contains('recommend') || message.contains('suggest')) {
      return "I'd be happy to recommend some events based on your interests! Tell me a bit about what you enjoy - music, food, sports, art, or something else?";
    }

    if (message.contains('free') || message.contains('cheap')) {
      return "Looking for free or low-cost events? Great choice! There are always amazing free events happening. What type of activities interest you?";
    }

    if (message.contains('tonight') || message.contains('today')) {
      return "Planning something for tonight? Let me help you find the best events happening today! What's your location and what are you in the mood for?";
    }

    if (message.contains('weekend') || message.contains('this weekend')) {
      return "Weekend plans are the best! I can help you find amazing events for the upcoming weekend. What sounds good to you?";
    }

    // Default response
    return "I'm here to help you discover amazing events! Whether you're looking for concerts, food festivals, sports games, or cultural events, I can find the perfect activities for you. What are you interested in?";
  }
}