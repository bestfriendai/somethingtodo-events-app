"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.dailyRecommendations = exports.onUserCreated = exports.onEventDeleted = exports.onEventUpdated = exports.onEventCreated = exports.api = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const openai_1 = require("openai");
const axios_1 = __importDefault(require("axios"));
// Load environment variables from .env file in development
if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config();
}
// Get configuration from Firebase Functions config in production or .env in development
const getConfig = () => {
    var _a, _b;
    // In production, use Firebase Functions config
    if (process.env.NODE_ENV === 'production' || process.env.FUNCTIONS_EMULATOR !== 'true') {
        const config = functions.config();
        return {
            OPENAI_API_KEY: ((_a = config.openai) === null || _a === void 0 ? void 0 : _a.api_key) || process.env.OPENAI_API_KEY,
            RAPIDAPI_KEY: ((_b = config.rapidapi) === null || _b === void 0 ? void 0 : _b.key) || process.env.RAPIDAPI_KEY,
        };
    }
    // In development, use environment variables from .env file
    return {
        OPENAI_API_KEY: process.env.OPENAI_API_KEY,
        RAPIDAPI_KEY: process.env.RAPIDAPI_KEY,
    };
};
// Load configuration
const config = getConfig();
// Validate required configuration at startup
const validateEnvironment = () => {
    const required = ['OPENAI_API_KEY', 'RAPIDAPI_KEY'];
    const missing = required.filter(key => !config[key]);
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
const app = (0, express_1.default)();
app.use((0, cors_1.default)({ origin: true }));
app.use(express_1.default.json());
// Initialize OpenAI with secure API key from config
const openai = new openai_1.OpenAI({
    apiKey: config.OPENAI_API_KEY,
});
// API Routes
app.post('/chat', async (req, res) => {
    try {
        const { sessionId, message, userId, chatType, context } = req.body;
        if (!sessionId || !message || !userId || !chatType) {
            return res.status(400).json({
                error: 'Missing required fields: sessionId, message, userId, chatType'
            });
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
    }
    catch (error) {
        console.error('Chat API error:', error);
        return res.status(500).json({
            error: 'Failed to process chat message',
            details: error instanceof Error ? error.message : 'Unknown error',
        });
    }
});
// Event sync endpoint
app.post('/events/sync', async (req, res) => {
    try {
        const { eventId, action } = req.body;
        if (!eventId || !action) {
            return res.status(400).json({
                error: 'Missing required fields: eventId, action'
            });
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
            default:
                return res.status(400).json({ error: 'Invalid action' });
        }
        return res.json({ success: true });
    }
    catch (error) {
        console.error('Event sync error:', error);
        return res.status(500).json({
            error: 'Failed to sync event',
            details: error instanceof Error ? error.message : 'Unknown error',
        });
    }
});
// Generate recommendations endpoint
app.post('/recommendations/generate', async (req, res) => {
    try {
        const { userId } = req.body;
        if (!userId) {
            return res.status(400).json({ error: 'Missing userId' });
        }
        const recommendations = await generatePersonalizedRecommendations(userId);
        return res.json({
            success: true,
            recommendations,
        });
    }
    catch (error) {
        console.error('Recommendations error:', error);
        return res.status(500).json({
            error: 'Failed to generate recommendations',
            details: error instanceof Error ? error.message : 'Unknown error',
        });
    }
});
// Export the Express app as a Cloud Function
exports.api = functions.https.onRequest(app);
// Cloud Function Triggers
exports.onEventCreated = functions.firestore
    .document('events/{eventId}')
    .onCreate(async (snap, context) => {
    const eventId = context.params.eventId;
    await handleEventCreated(eventId);
});
exports.onEventUpdated = functions.firestore
    .document('events/{eventId}')
    .onUpdate(async (change, context) => {
    const eventId = context.params.eventId;
    await handleEventUpdated(eventId);
});
exports.onEventDeleted = functions.firestore
    .document('events/{eventId}')
    .onDelete(async (snap, context) => {
    const eventId = context.params.eventId;
    await handleEventDeleted(eventId);
});
exports.onUserCreated = functions.auth
    .user()
    .onCreate(async (user) => {
    // Initialize user preferences and send welcome notification
    await initializeNewUser(user);
});
// Scheduled function to send daily event recommendations
exports.dailyRecommendations = functions.pubsub
    .schedule('0 9 * * *') // Daily at 9 AM
    .timeZone('America/Los_Angeles')
    .onRun(async (context) => {
    await sendDailyRecommendations();
});
// Helper Functions
async function generateAIResponse(message, chatHistory, chatType, context) {
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
            { role: 'system', content: systemPrompt },
            ...chatHistory.map(msg => ({
                role: msg.role,
                content: msg.content,
            })),
            { role: 'user', content: message },
        ];
        const completion = await openai.chat.completions.create({
            model: 'gpt-4-turbo-preview',
            messages: messages,
            max_tokens: 1000,
            temperature: 0.7,
            functions: getChatFunctions(chatType),
            function_call: 'auto',
        });
        const choice = completion.choices[0];
        const responseMessage = choice.message;
        if (responseMessage.function_call) {
            return await processFunctionCall(responseMessage.function_call);
        }
        else {
            return {
                content: responseMessage.content || 'I apologize, but I encountered an error processing your request.',
                type: 'text',
            };
        }
    }
    catch (error) {
        console.error('OpenAI API error:', error);
        return {
            content: 'I\'m having trouble connecting right now. Please try again in a moment.',
            type: 'text',
        };
    }
}
function getSystemPrompt(chatType, context) {
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
function getChatFunctions(chatType) {
    const baseFunctions = [
        {
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
            },
        },
    ];
    if (chatType === 'eventDiscovery') {
        baseFunctions.push({
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
            },
        });
    }
    return baseFunctions;
}
async function processFunctionCall(functionCall) {
    const functionName = functionCall.name;
    const args = JSON.parse(functionCall.arguments);
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
async function searchEvents(args) {
    // Implementation would query Firestore for events matching the criteria
    // For now, return a mock response
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
async function getRecommendations(args) {
    // Implementation would generate personalized recommendations
    return {
        content: 'Based on your interests, I have some personalized recommendations for you!',
        type: 'event',
        metadata: { recommendationType: 'personalized' },
    };
}
async function handleEventCreated(eventId) {
    console.log(`Event created: ${eventId}`);
    // Index the event for search
    // Send notifications to interested users
    // Update analytics
    const eventDoc = await admin.firestore()
        .collection('events')
        .doc(eventId)
        .get();
    if (eventDoc.exists) {
        // const eventData = eventDoc.data();
        // Process new event...
    }
}
async function handleEventUpdated(eventId) {
    console.log(`Event updated: ${eventId}`);
    // Update search index
    // Notify users who favorited this event
}
async function handleEventDeleted(eventId) {
    console.log(`Event deleted: ${eventId}`);
    // Remove from search index
    // Clean up related data
}
async function initializeNewUser(user) {
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
    // Send welcome notification
    // Subscribe to general topic for push notifications
}
async function sendDailyRecommendations() {
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
async function generatePersonalizedRecommendations(userId) {
    // Get user preferences and interests
    const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();
    if (!userDoc.exists) {
        return [];
    }
    // const userData = userDoc.data();
    // Query events based on user preferences
    // Generate recommendations using AI
    // Store recommendations in Firestore
    return [];
}
// Secure RapidAPI config from configuration
const RAPIDAPI_KEY = config.RAPIDAPI_KEY;
const RAPIDAPI_BASE = 'https://real-time-events-search.p.rapidapi.com';
const RAPIDAPI_HOST = 'real-time-events-search.p.rapidapi.com';
function rapidApiHeaders() {
    if (!RAPIDAPI_KEY) {
        throw new Error('RapidAPI key is not configured. Please set RAPIDAPI_KEY environment variable.');
    }
    return {
        'x-rapidapi-key': RAPIDAPI_KEY,
        'x-rapidapi-host': RAPIDAPI_HOST,
    };
}
app.get('/events/search', async (req, res) => {
    var _a, _b, _c;
    try {
        const { query, location, start, end, limit } = req.query;
        console.log('Search events request:', { query, location, start, end, limit });
        const response = await axios_1.default.get(`${RAPIDAPI_BASE}/search-events`, {
            params: Object.assign(Object.assign(Object.assign(Object.assign(Object.assign({}, (query ? { query } : {})), (location ? { location } : {})), (start ? { start } : {})), (end ? { end } : {})), (limit ? { limit } : {})),
            headers: rapidApiHeaders(),
            timeout: 15000, // Increased timeout
        });
        console.log('Search events response:', response.data);
        res.status(200).json(response.data);
    }
    catch (error) {
        console.error('RapidAPI /events/search error:', ((_a = error === null || error === void 0 ? void 0 : error.response) === null || _a === void 0 ? void 0 : _a.data) || error.message);
        res.status(((_b = error === null || error === void 0 ? void 0 : error.response) === null || _b === void 0 ? void 0 : _b.status) || 500).json({
            error: 'Failed to search events',
            details: ((_c = error === null || error === void 0 ? void 0 : error.response) === null || _c === void 0 ? void 0 : _c.data) || error.message,
        });
    }
});
app.get('/events/trending', async (req, res) => {
    var _a, _b, _c;
    try {
        const { location, limit } = req.query;
        console.log('Trending events request:', { location, limit });
        const response = await axios_1.default.get(`${RAPIDAPI_BASE}/search-events`, {
            params: Object.assign(Object.assign({ query: 'events trending music concert sports' }, (location ? { location } : {})), (limit ? { limit } : { limit: '20' })),
            headers: rapidApiHeaders(),
            timeout: 15000, // Increased timeout
        });
        console.log('Trending events response:', response.data);
        res.status(200).json(response.data);
    }
    catch (error) {
        console.error('RapidAPI /events/trending error:', ((_a = error === null || error === void 0 ? void 0 : error.response) === null || _a === void 0 ? void 0 : _a.data) || error.message);
        res.status(((_b = error === null || error === void 0 ? void 0 : error.response) === null || _b === void 0 ? void 0 : _b.status) || 500).json({
            error: 'Failed to get trending events',
            details: ((_c = error === null || error === void 0 ? void 0 : error.response) === null || _c === void 0 ? void 0 : _c.data) || error.message,
        });
    }
});
app.get('/events/nearby', async (req, res) => {
    var _a, _b, _c;
    try {
        const { lat, lng, radius, limit } = req.query;
        console.log('Nearby events request:', { lat, lng, radius, limit });
        // Use search-events with location-based query
        const response = await axios_1.default.get(`${RAPIDAPI_BASE}/search-events`, {
            params: Object.assign(Object.assign({ query: 'events', location: `${lat},${lng}` }, (radius ? { radius: Math.min(radius, 50) } : {})), (limit ? { limit } : { limit: '20' })),
            headers: rapidApiHeaders(),
            timeout: 15000, // Increased timeout
        });
        console.log('Nearby events response:', response.data);
        res.status(200).json(response.data);
    }
    catch (error) {
        console.error('RapidAPI /events/nearby error:', ((_a = error === null || error === void 0 ? void 0 : error.response) === null || _a === void 0 ? void 0 : _a.data) || error.message);
        res.status(((_b = error === null || error === void 0 ? void 0 : error.response) === null || _b === void 0 ? void 0 : _b.status) || 500).json({
            error: 'Failed to get nearby events',
            details: ((_c = error === null || error === void 0 ? void 0 : error.response) === null || _c === void 0 ? void 0 : _c.data) || error.message,
        });
    }
});
app.get('/events/details', async (req, res) => {
    var _a, _b, _c;
    try {
        const { event_id } = req.query;
        const response = await axios_1.default.get(`${RAPIDAPI_BASE}/event-details`, {
            params: Object.assign({}, (event_id ? { event_id } : {})),
            headers: rapidApiHeaders(),
            timeout: 10000,
        });
        res.status(200).json(response.data);
    }
    catch (error) {
        console.error('RapidAPI /events/details error:', ((_a = error === null || error === void 0 ? void 0 : error.response) === null || _a === void 0 ? void 0 : _a.data) || error.message);
        res.status(((_b = error === null || error === void 0 ? void 0 : error.response) === null || _b === void 0 ? void 0 : _b.status) || 500).json({
            error: 'Failed to get event details',
            details: ((_c = error === null || error === void 0 ? void 0 : error.response) === null || _c === void 0 ? void 0 : _c.data) || error.message,
        });
    }
});
app.get('/events/category', async (req, res) => {
    var _a, _b, _c;
    try {
        const { category, location, limit } = req.query;
        const response = await axios_1.default.get(`${RAPIDAPI_BASE}/events-by-category`, {
            params: Object.assign(Object.assign(Object.assign({}, (category ? { category } : {})), (location ? { location } : {})), (limit ? { limit } : {})),
            headers: rapidApiHeaders(),
            timeout: 10000,
        });
        res.status(200).json(response.data);
    }
    catch (error) {
        console.error('RapidAPI /events/category error:', ((_a = error === null || error === void 0 ? void 0 : error.response) === null || _a === void 0 ? void 0 : _a.data) || error.message);
        res.status(((_b = error === null || error === void 0 ? void 0 : error.response) === null || _b === void 0 ? void 0 : _b.status) || 500).json({
            error: 'Failed to get events by category',
            details: ((_c = error === null || error === void 0 ? void 0 : error.response) === null || _c === void 0 ? void 0 : _c.data) || error.message,
        });
    }
});
//# sourceMappingURL=index.js.map