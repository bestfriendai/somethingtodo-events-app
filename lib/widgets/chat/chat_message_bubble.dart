import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final VoidCallback? onTap;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: AppTheme.spaceSm),
          ] else if (!isUser) ...[
            const SizedBox(width: 40),
          ],
          
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppTheme.primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg).copyWith(
                    bottomLeft: isUser
                        ? Radius.circular(AppTheme.radiusLg)
                        : Radius.circular(AppTheme.radiusXs),
                    bottomRight: isUser
                        ? Radius.circular(AppTheme.radiusXs)
                        : Radius.circular(AppTheme.radiusLg),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 15,
                      ),
                    ),
                    
                    if (message.recommendations.isNotEmpty) ...[
                      SizedBox(height: AppTheme.spaceSm),
                      ...message.recommendations.map(
                        (rec) => _buildRecommendationCard(context, rec),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          if (isUser && showAvatar) ...[
            SizedBox(width: AppTheme.spaceSm),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.secondaryColor,
              child: Text(
                'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else if (isUser) ...[
            const SizedBox(width: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, EventRecommendation rec) {
    return Container(
      margin: EdgeInsets.only(top: AppTheme.spaceSm),
      padding: EdgeInsets.all(AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          if (rec.description.isNotEmpty) ...[
            SizedBox(height: AppTheme.spaceXs),
            Text(
              rec.description,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (rec.reasons.isNotEmpty) ...[
            SizedBox(height: AppTheme.spaceXs),
            Text(
              rec.reasons.first,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (rec.confidenceScore > 0) ...[
            SizedBox(height: AppTheme.spaceXs),
            Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber),
                SizedBox(width: AppTheme.spaceXs),
                Text(
                  'Confidence: ${(rec.confidenceScore * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
