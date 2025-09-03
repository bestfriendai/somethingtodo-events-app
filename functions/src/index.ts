import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import cors from 'cors';
import express, { Request, Response, NextFunction } from 'express';
import { OpenAI } from 'openai';
import axios from 'axios';

// Load environment variables from .env file in development
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

// Get configuration from Firebase Functions config in production or .env in development
const getConfig = () => {
  // In production, use Firebase Functions config
  if (process.env.NODE_ENV === 'production' || process.env.FUNCTIONS_EMULATOR !== 'true') {
    const config = functions.config();
    return {
      OPENAI_API_KEY: config.openai?.api_key || process.env.OPENAI_API_KEY,
      RAPIDAPI_KEY: config.rapidapi?.key || process.env.RAPIDAPI_KEY,
      ALLOWED_ORIGINS: config.app?.allowed_origins || process.env.ALLOWED_ORIGINS || 'http://localhost:3000',
      RATE_LIMIT_MAX: config.security?.rate_limit_max || process.env.RATE_LIMIT_MAX || '100',
      RATE_LIMIT_WINDOW: config.security?.rate_limit_window || process.env.RATE_LIMIT_WINDOW || '60000',
    };
  }
  // In development, use environment variables from .env file
  return {
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,
    RAPIDAPI_KEY: process.env.RAPIDAPI_KEY,
    ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS || 'http://localhost:3000,http://localhost:5173,http://localhost:5000',
    RATE_LIMIT_MAX: process.env.RATE_LIMIT_MAX || '100',
    RATE_LIMIT_WINDOW: process.env.RATE_LIMIT_WINDOW || '60000',
  };
};

// Load configuration
const config = getConfig();

// Validate required configuration at startup
const validateEnvironment = () => {
  const required = ['OPENAI_API_KEY', 'RAPIDAPI_KEY'];
  const missing = required.filter(key => !config[key as keyof typeof config]);
  
  if (missing.length > 0) {
    console.error(`Missing required configuration: ${missing.join(', ')}`);
    console.error('Please set these in Firebase Functions configuration or .env file for local development');
    console.error('For production: Run ./set-config.sh to set Firebase Functions configuration');
    console.error('For development: Create a .env file with the required keys');
  }
};

// Validate on startup
validateEnvironment();

// Initialize Firebase Admin
admin.initializeApp();

// Initialize Express
const app = express();

// Parse allowed origins from config
const getAllowedOrigins = (): string[] => {
  const originsStr = config.ALLOWED_ORIGINS || '';
  const origins = originsStr.split(',').map((origin: string) => origin.trim()).filter(Boolean);
  
  // Default origins for development if none specified
  if (origins.length === 0) {
    return ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:5000'];
  }
  
  return origins;
};

// Configure CORS with specific allowed origins
const corsOptions: cors.CorsOptions = {
  origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
    const allowedOrigins = getAllowedOrigins();
    
    // Allow requests with no origin (e.g., mobile apps, Postman)
    if (!origin) {
      callback(null, true);
      return;
    }
    
    // Check if origin is allowed
    if (allowedOrigins.includes(origin) || 
        allowedOrigins.some(allowed => allowed === '*' || origin.startsWith(allowed.replace('*', '')))) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400 // Cache preflight for 24 hours
};

app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' })); // Limit request size

// Rate limiting implementation
interface RateLimitEntry {
  count: number;
  resetTime: number;
}

const rateLimitMap = new Map<string, RateLimitEntry>();

const rateLimitMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const identifier = req.ip || 'unknown';
  const now = Date.now();
  const windowMs = parseInt(config.RATE_LIMIT_WINDOW || '60000');
  const maxRequests = parseInt(config.RATE_LIMIT_MAX || '100');
  
  const entry = rateLimitMap.get(identifier);
  
  if (!entry || now > entry.resetTime) {
    // Create new entry or reset existing
    rateLimitMap.set(identifier, {
      count: 1,
      resetTime: now + windowMs
    });
    next();
  } else if (entry.count < maxRequests) {
    // Increment count
    entry.count++;
    next();
  } else {
    // Rate limit exceeded
    res.status(429).json({
      error: 'Too many requests',
      retryAfter: Math.ceil((entry.resetTime - now) / 1000)
    });
  }
};

// Apply rate limiting to all routes
app.use(rateLimitMiddleware);

// Input validation middleware
const validateInput = (schema: any) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      // Basic input sanitization
      const sanitizeString = (str: any): string => {
        if (typeof str !== 'string') return '';
        // Remove potential script tags and SQL injection attempts
        return str
          .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
          .replace(/[';]|(--)|(\*|\/\*|\*\/)|(\bOR\b|\bAND\b)/gi, '')
          .trim()
          .slice(0, 1000); // Limit string length
      };
      
      const sanitizeObject = (obj: any): any => {
        if (typeof obj !== 'object' || obj === null) return obj;
        
        const sanitized: any = Array.isArray(obj) ? [] : {};
        for (const key in obj) {
          if (obj.hasOwnProperty(key)) {
            const value = obj[key];
            if (typeof value === 'string') {
              sanitized[key] = sanitizeString(value);
            } else if (typeof value === 'object') {
              sanitized[key] = sanitizeObject(value);
            } else {
              sanitized[key] = value;
            }
          }
        }
        return sanitized;
      };
      
      // Sanitize request body
      if (req.body) {
        req.body = sanitizeObject(req.body);
      }
      
      // Sanitize query parameters
      if (req.query) {
        req.query = sanitizeObject(req.query);
      }
      
      next();
    } catch (error) {
      res.status(400).json({ error: 'Invalid input' });
    }
  };
};

// Authentication middleware
const authenticateUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }
    
    const token = authHeader.substring(7);
    const decodedToken = await admin.auth().verifyIdToken(token);
    (req as any).user = decodedToken;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid authentication token' });
  }
};

// Initialize OpenAI with secure API key from config
const openai = new OpenAI({
  apiKey: config.OPENAI_API_KEY,
});

// Types
interface ChatRequest {
  sessionId: string;
  message: string;
  userId: string;
  chatType: 'eventDiscovery' | 'eventPlanning' | 'generalSupport';
  context?: Record<string, any>;
}

interface EventSyncRequest {
  eventId: string;
  action: 'create' | 'update' | 'delete';
}

// Sanitized error response helper
const sendErrorResponse = (res: Response, statusCode: number, message: string, details?: string) => {
  // Never expose sensitive information in error messages
  const sanitizedDetails = details ? 
    details.replace(/[A-Za-z0-9_-]{20,}/g, '[REDACTED]') // Remove potential API keys
    .replace(/\b(?:\d{1,3}\.){3}\d{1,3}\b/g, '[IP]') // Remove IP addresses
    : undefined;
  
  res.status(statusCode).json({
    error: message,
    ...(process.env.NODE_ENV !== 'production' && sanitizedDetails ? { details: sanitizedDetails } : {})
  });
};

// API Routes

// Chat endpoint with authentication and validation
app.post('/chat', authenticateUser, validateInput({}), async (req: Request, res: Response) => {
  try {
    const { sessionId, message, userId, chatType, context }: ChatRequest = req.body;

    if (!sessionId || !message || !userId || !chatType) {
      return sendErrorResponse(res, 400, 'Missing required fields');
    }
    
    // Validate message length
    if (message.length > 1000) {
      return sendErrorResponse(res, 400, 'Message too long');
    }
    
    // Validate chat type
    if (!['eventDiscovery', 'eventPlanning', 'generalSupport'].includes(chatType)) {
      return sendErrorResponse(res, 400, 'Invalid chat type');
    }

    const messagesRef = admin.firestore()
      .collection('messages')
      .where('sessionId', '==', sessionId)
      .orderBy('timestamp', 'desc')
      .limit(20);

    const messagesSnapshot = await messagesRef.get();
    const chatHistory = messagesSnapshot.docs.map(doc => doc.data()).reverse();

    const aiResponse = await generateAIResponse(message, chatHistory, chatType, context);

    await admin.firestore().collection('messages').add({
      sessionId,
      userId,
      role: 'user',
      content: message,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    await admin.firestore().collection('messages').add({
      sessionId,
      userId,
      role: 'assistant',
      content: aiResponse.content,
      type: aiResponse.type || 'text',
      actions: aiResponse.actions || [],
      metadata: aiResponse.metadata || {},
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    await admin.firestore()
      .collection('chatSessions')
      .doc(sessionId)
      .update({
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return res.json({
      success: true,
      response: aiResponse,
    });
  } catch (error) {
    console.error('Chat API error:', error);
    return sendErrorResponse(res, 500, 'Failed to process chat message');
  }
});

// Event sync endpoint with authentication
app.post('/events/sync', authenticateUser, validateInput({}), async (req: Request, res: Response) => {
  try {
    const { eventId, action }: EventSyncRequest = req.body;

    if (!eventId || !action) {
      return sendErrorResponse(res, 400, 'Missing required fields');
    }
    
    // Validate action
    if (!['create', 'update', 'delete'].includes(action)) {
      return sendErrorResponse(res, 400, 'Invalid action');
    }

    switch (action) {
      case 'create':
        await handleEventCreated(eventId);
        break;
      case 'update':
        await handleEventUpdated(eventId);
        break;
      case 'delete':
        await handleEventDeleted(eventId);
        break;
    }

    return res.json({ success: true });
  } catch (error) {
    console.error('Event sync error:', error);
    return sendErrorResponse(res, 500, 'Failed to sync event');
  }
});

// Events search endpoint - with rate limiting and validation
app.get('/events/search', validateInput({}), async (req: Request, res: Response) => {
  try {
    const { lat, lng, radius = 10, category, limit = 20, page = 1, query, location, start, end } = req.query;
    
    // Validate numeric parameters
    if ((lat && isNaN(Number(lat))) || (lng && isNaN(Number(lng)))) {
      return sendErrorResponse(res, 400, 'Invalid coordinates');
    }
    
    if (limit && (isNaN(Number(limit)) || Number(limit) > 100)) {
      return sendErrorResponse(res, 400, 'Invalid limit parameter');
    }

    // Check if RapidAPI key is configured
    if (!config.RAPIDAPI_KEY) {
      console.error('RapidAPI key is not configured');
      // Return mock data in development if no API key
      return res.json({
        data: getMockEvents(Number(lat) || 0, Number(lng) || 0, Number(limit))
      });
    }

    const response = await axios.get('https://real-time-events-search.p.rapidapi.com/search-events', {
      params: {
        ...(query ? { query: String(query).slice(0, 100) } : {}),
        ...(location ? { location: String(location).slice(0, 100) } : 
            (lat && lng ? { location: `${lat},${lng}` } : {})),
        ...(radius ? { radius: Math.min(Number(radius), 50) } : {}),
        ...(start ? { start: String(start).slice(0, 20) } : {}),
        ...(end ? { end: String(end).slice(0, 20) } : {}),
        ...(category ? { category: String(category).slice(0, 50) } : {}),
        limit: Math.min(Number(limit) || 20, 100),
        page: Math.max(1, Number(page) || 1),
        sort: 'date'
      },
      headers: {
        'X-RapidAPI-Key': config.RAPIDAPI_KEY,
        'X-RapidAPI-Host': 'real-time-events-search.p.rapidapi.com'
      },
      timeout: 15000
    });

    return res.json(response.data);
  } catch (error) {
    console.error('Events search error:', error);
    // Return mock data on error to keep app functional
    const { lat, lng, limit = 20 } = req.query;
    return res.json({
      data: getMockEvents(Number(lat) || 0, Number(lng) || 0, Number(limit))
    });
  }
});

// Events trending endpoint
app.get('/events/trending', validateInput({}), async (req: Request, res: Response) => {
  try {
    const { location, limit } = req.query as any;
    
    if (limit && (isNaN(Number(limit)) || Number(limit) > 100)) {
      return sendErrorResponse(res, 400, 'Invalid limit parameter');
    }

    if (!config.RAPIDAPI_KEY) {
      return res.json({
        data: getMockEvents(0, 0, Number(limit) || 20)
      });
    }

    const response = await axios.get('https://real-time-events-search.p.rapidapi.com/search-events', {
      params: {
        query: 'events trending music concert sports',
        ...(location ? { location: String(location).slice(0, 100) } : {}),
        limit: Math.min(Number(limit) || 20, 100)
      },
      headers: {
        'X-RapidAPI-Key': config.RAPIDAPI_KEY,
        'X-RapidAPI-Host': 'real-time-events-search.p.rapidapi.com'
      },
      timeout: 15000
    });

    return res.json(response.data);
  } catch (error) {
    console.error('Trending events error');
    return sendErrorResponse(res, 500, 'Failed to get trending events');
  }
});

// Events nearby endpoint
app.get('/events/nearby', validateInput({}), async (req: Request, res: Response) => {
  try {
    const { lat, lng, radius, limit } = req.query as any;
    
    if (!lat || !lng || isNaN(Number(lat)) || isNaN(Number(lng))) {
      return sendErrorResponse(res, 400, 'Invalid coordinates');
    }
    
    if (radius && (isNaN(Number(radius)) || Number(radius) > 50)) {
      return sendErrorResponse(res, 400, 'Invalid radius parameter');
    }
    
    if (limit && (isNaN(Number(limit)) || Number(limit) > 100)) {
      return sendErrorResponse(res, 400, 'Invalid limit parameter');
    }

    if (!config.RAPIDAPI_KEY) {
      return res.json({
        data: getMockEvents(Number(lat), Number(lng), Number(limit) || 20)
      });
    }

    const response = await axios.get('https://real-time-events-search.p.rapidapi.com/search-events', {
      params: {
        query: 'events',
        location: `${lat},${lng}`,
        radius: Math.min(Number(radius) || 10, 50),
        limit: Math.min(Number(limit) || 20, 100)
      },
      headers: {
        'X-RapidAPI-Key': config.RAPIDAPI_KEY,
        'X-RapidAPI-Host': 'real-time-events-search.p.rapidapi.com'
      },
      timeout: 15000
    });

    return res.json(response.data);
  } catch (error) {
    console.error('Nearby events error');
    return sendErrorResponse(res, 500, 'Failed to get nearby events');
  }
});

// Event details endpoint
app.get('/events/details', validateInput({}), async (req: Request, res: Response) => {
  try {
    const { event_id } = req.query as any;
    
    if (!event_id) {
      return sendErrorResponse(res, 400, 'Missing event ID');
    }

    if (!config.RAPIDAPI_KEY) {
      return sendErrorResponse(res, 503, 'Service temporarily unavailable');
    }

    const response = await axios.get('https://real-time-events-search.p.rapidapi.com/event-details', {
      params: { event_id: String(event_id).slice(0, 100) },
      headers: {
        'X-RapidAPI-Key': config.RAPIDAPI_KEY,
        'X-RapidAPI-Host': 'real-time-events-search.p.rapidapi.com'
      },
      timeout: 10000
    });

    return res.json(response.data);
  } catch (error) {
    console.error('Event details error');
    return sendErrorResponse(res, 500, 'Failed to get event details');
  }
});

// Events by category endpoint
app.get('/events/category', validateInput({}), async (req: Request, res: Response) => {
  try {
    const { category, location, limit } = req.query as any;
    
    if (!category) {
      return sendErrorResponse(res, 400, 'Missing category parameter');
    }
    
    if (limit && (isNaN(Number(limit)) || Number(limit) > 100)) {
      return sendErrorResponse(res, 400, 'Invalid limit parameter');
    }

    if (!config.RAPIDAPI_KEY) {
      return res.json({
        data: getMockEvents(0, 0, Number(limit) || 20)
      });
    }

    const response = await axios.get('https://real-time-events-search.p.rapidapi.com/events-by-category', {
      params: {
        category: String(category).slice(0, 50),
        ...(location ? { location: String(location).slice(0, 100) } : {}),
        limit: Math.min(Number(limit) || 20, 100)
      },
      headers: {
        'X-RapidAPI-Key': config.RAPIDAPI_KEY,
        'X-RapidAPI-Host': 'real-time-events-search.p.rapidapi.com'
      },
      timeout: 10000
    });

    return res.json(response.data);
  } catch (error) {
    console.error('Category events error');
    return sendErrorResponse(res, 500, 'Failed to get events by category');
  }
});

// Generate recommendations endpoint with authentication
app.post('/recommendations/generate', authenticateUser, validateInput({}), async (req: Request, res: Response) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return sendErrorResponse(res, 400, 'Missing userId');
    }

    const recommendations = await generatePersonalizedRecommendations(userId);

    return res.json({
      success: true,
      recommendations,
    });
  } catch (error) {
    console.error('Recommendations error:', error);
    return sendErrorResponse(res, 500, 'Failed to generate recommendations');
  }
});

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Helper function to generate mock events for development/demo
function getMockEvents(lat: number, lng: number, limit: number) {
  const events = [];
  const categories = ['Concert', 'Festival', 'Sports', 'Theater', 'Comedy', 'Art'];
  const venues = ['Madison Square Garden', 'Central Park', 'Brooklyn Bowl', 'Blue Note', 'Apollo Theater'];
  
  for (let i = 0; i < Math.min(limit, 20); i++) {
    const randomDate = new Date();
    randomDate.setDate(randomDate.getDate() + Math.floor(Math.random() * 30));
    
    events.push({
      id: `mock_${i + 1}`,
      name: `${categories[i % categories.length]} Event ${i + 1}`,
      description: `Amazing ${categories[i % categories.length].toLowerCase()} event happening soon!`,
      venue: {
        name: venues[i % venues.length],
        address: `${100 + i} Main Street`,
        city: 'San Francisco',
        state: 'CA',
        latitude: lat + (Math.random() - 0.5) * 0.1,
        longitude: lng + (Math.random() - 0.5) * 0.1
      },
      dates: {
        start: {
          localDate: randomDate.toISOString().split('T')[0],
          localTime: `${19 + (i % 3)}:00:00`
        }
      },
      images: [{
        url: `https://picsum.photos/seed/${i}/400/300`,
        width: 400,
        height: 300
      }],
      priceRanges: [{
        min: 20 + (i * 5),
        max: 50 + (i * 10),
        currency: 'USD'
      }],
      url: `https://example.com/event/${i + 1}`,
      distance: (Math.random() * 10).toFixed(1),
      segment: {
        name: categories[i % categories.length]
      }
    });
  }
  
  return events;
}

// Export the Express app as a Cloud Function
export const api = functions.https.onRequest(app);

// Cloud Function Triggers using v1 API for compatibility
export const onEventCreated = functions.firestore
  .document('events/{eventId}')
  .onCreate(async (snap: any, context: any) => {
    const eventId = context.params.eventId;
    await handleEventCreated(eventId);
  });

export const onEventUpdated = functions.firestore
  .document('events/{eventId}')
  .onUpdate(async (change: any, context: any) => {
    const eventId = context.params.eventId;
    await handleEventUpdated(eventId);
  });

export const onEventDeleted = functions.firestore
  .document('events/{eventId}')
  .onDelete(async (snap: any, context: any) => {
    const eventId = context.params.eventId;
    await handleEventDeleted(eventId);
  });

export const onUserCreated = functions.auth
  .user()
  .onCreate(async (user: any) => {
    // Initialize user preferences and send welcome notification
    await initializeNewUser(user);
  });

// Scheduled function to send daily event recommendations
export const dailyRecommendations = functions.pubsub
  .schedule('0 9 * * *') // Daily at 9 AM
  .timeZone('America/Los_Angeles')
  .onRun(async (context: any) => {
    await sendDailyRecommendations();
  });

// Helper Functions
async function generateAIResponse(
  message: string,
  chatHistory: any[],
  chatType: string,
  context?: Record<string, any>
): Promise<any> {
  try {
    // Check if OpenAI API key is configured
    if (!config.OPENAI_API_KEY) {
      console.error('OpenAI API key is not configured');
      return {
        content: 'The AI service is currently unavailable. Please try again later.',
        type: 'text',
      };
    }

    const systemPrompt = getSystemPrompt(chatType, context);
    const messages = [
      { role: 'system' as const, content: systemPrompt },
      ...chatHistory.slice(-10).map(msg => ({ // Limit history to last 10 messages
        role: msg.role as 'user' | 'assistant',
        content: msg.content,
      })),
      { role: 'user' as const, content: message },
    ];

    // Use the new tools API instead of deprecated functions API
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // Updated to latest model
      messages: messages,
      max_tokens: 1000,
      temperature: 0.7,
      tools: getChatTools(chatType),
      tool_choice: 'auto',
    });

    const choice = completion.choices[0];
    const responseMessage = choice.message;

    if (responseMessage.tool_calls && responseMessage.tool_calls.length > 0) {
      return await processToolCall(responseMessage.tool_calls[0]);
    } else {
      return {
        content: responseMessage.content || 'I apologize, but I encountered an error processing your request.',
        type: 'text',
      };
    }
  } catch (error: any) {
    console.error('OpenAI API error');
    // Don't expose error details
    return {
      content: 'I\'m having trouble connecting right now. Please try again in a moment.',
      type: 'text',
    };
  }
}

function getSystemPrompt(chatType: string, context?: Record<string, any>): string {
  const basePrompt = `You are an AI assistant for SomethingToDo, an event discovery app. Be helpful, friendly, and focused on helping users discover and plan events.`;
  
  const contextStr = context ? `\nUser context: ${JSON.stringify(context)}` : '';
  
  switch (chatType) {
    case 'eventDiscovery':
      return `${basePrompt} You help users find events based on their preferences, location, and interests. You can search for events, provide recommendations, and answer questions about venues and event details.${contextStr}`;
    case 'eventPlanning':
      return `${basePrompt} You help users plan their event attendance by suggesting itineraries, nearby activities, transportation options, and coordination with friends.${contextStr}`;
    case 'generalSupport':
      return `${basePrompt} You provide general support for the app, helping users navigate features, troubleshoot issues, and understand how to use the platform effectively.${contextStr}`;
    default:
      return basePrompt + contextStr;
  }
}

// Updated to use tools API instead of deprecated functions API
function getChatTools(chatType: string): any[] {
  const baseTools: any[] = [
    {
      type: 'function',
      function: {
        name: 'search_events',
        description: 'Search for events based on criteria',
        parameters: {
          type: 'object',
          properties: {
            query: { type: 'string', description: 'Search query' },
            category: { type: 'string', description: 'Event category' },
            location: { type: 'string', description: 'Location filter' },
            dateRange: { type: 'string', description: 'Date range filter' },
            priceRange: { type: 'string', description: 'Price preference' },
          },
          required: []
        }
      }
    }
  ];

  if (chatType === 'eventDiscovery') {
    baseTools.push({
      type: 'function',
      function: {
        name: 'get_recommendations',
        description: 'Get personalized event recommendations',
        parameters: {
          type: 'object',
          properties: {
            interests: {
              type: 'array',
              items: { type: 'string' },
              description: 'User interests',
            },
            location: { type: 'string', description: 'User location' },
          },
          required: []
        }
      }
    });
  }

  return baseTools;
}

async function processToolCall(toolCall: any): Promise<any> {
  const functionName = toolCall.function.name;
  const args = JSON.parse(toolCall.function.arguments);

  switch (functionName) {
    case 'search_events':
      return await searchEvents(args);
    case 'get_recommendations':
      return await getRecommendations(args);
    default:
      return {
        content: 'I encountered an error processing your request.',
        type: 'text',
      };
  }
}

async function searchEvents(args: any): Promise<any> {
  // Implementation would query Firestore for events matching the criteria
  return {
    content: 'I found several events matching your criteria. Here are some great options for you!',
    type: 'event',
    actions: [
      {
        id: 'view_events',
        label: 'View Events',
        type: 'filterEvents',
        payload: args,
      },
    ],
  };
}

async function getRecommendations(args: any): Promise<any> {
  // Implementation would generate personalized recommendations
  return {
    content: 'Based on your interests, I have some personalized recommendations for you!',
    type: 'event',
    metadata: { recommendationType: 'personalized' },
  };
}

async function handleEventCreated(eventId: string): Promise<void> {
  console.log(`Event created: ${eventId}`);
  
  const eventDoc = await admin.firestore()
    .collection('events')
    .doc(eventId)
    .get();
    
  if (eventDoc.exists) {
    // Process new event...
  }
}

async function handleEventUpdated(eventId: string): Promise<void> {
  console.log(`Event updated: ${eventId}`);
  // Update search index
  // Notify users who favorited this event
}

async function handleEventDeleted(eventId: string): Promise<void> {
  console.log(`Event deleted: ${eventId}`);
  // Remove from search index
  // Clean up related data
}

async function initializeNewUser(user: any): Promise<void> {
  // Create user profile document
  await admin.firestore()
    .collection('users')
    .doc(user.uid)
    .set({
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      isPremium: false,
      interests: [],
      favoriteEventIds: [],
      preferences: {
        notificationsEnabled: true,
        locationEnabled: false,
        marketingEmails: true,
        theme: 'system',
        maxDistance: 50.0,
        preferredCategories: [],
        pricePreference: 'any',
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

async function sendDailyRecommendations(): Promise<void> {
  // Get all users who have notifications enabled
  const usersSnapshot = await admin.firestore()
    .collection('users')
    .where('preferences.notificationsEnabled', '==', true)
    .get();

  const users = usersSnapshot.docs.map(doc => doc.data());

  for (const user of users) {
    await generatePersonalizedRecommendations(user.id);
  }
}

async function generatePersonalizedRecommendations(userId: string): Promise<any[]> {
  // Get user preferences and interests
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
    
  if (!userDoc.exists) {
    return [];
  }
  
  // Query events based on user preferences
  // Generate recommendations using AI
  // Store recommendations in Firestore
  
  return [];
}