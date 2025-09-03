# 🔑 API Keys Setup Guide

This guide will help you get all the required API keys to make the SomethingToDo app fully functional.

## 🚨 CRITICAL: Required API Keys

### 1. 🚀 RapidAPI Key (Events Service)
**Status: REQUIRED - App won't show events without this**

1. Go to [RapidAPI Real-Time Events Search](https://rapidapi.com/real-time-events-search/api/real-time-events-search)
2. Click "Subscribe to Test" 
3. Choose a plan (Basic plan is often free with limited requests)
4. Copy your API key from the dashboard
5. Replace `your_rapidapi_key_here` in `.env` file

### 2. 🗺️ Mapbox Access Token (Maps)
**Status: REQUIRED - Maps won't work without this**

1. Go to [Mapbox Account](https://account.mapbox.com/access-tokens/)
2. Sign up for a free account
3. Create a new access token or use the default one
4. Copy the access token
5. Replace `your_mapbox_token_here` in `.env` file

### 3. 🤖 OpenAI API Key (AI Chat)
**Status: REQUIRED - Chat feature won't work without this**

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign up and add billing information (required for API access)
3. Create a new API key
4. Copy the key (starts with sk-)
5. Replace `your_openai_api_key_here` in `.env` file

### 4. 🗺️ Google Maps API Key (Location Services)
**Status: REQUIRED - Location features won't work without this**

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps JavaScript API
   - Places API
   - Geocoding API
4. Create credentials (API Key)
5. Copy the API key
6. Replace `your_google_maps_api_key_here` in `.env` file

## 💳 Optional API Keys

### 5. 💰 Stripe Keys (Premium Features)
**Status: OPTIONAL - Only needed for premium subscriptions**

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/apikeys)
2. Copy your publishable key (starts with pk_)
3. Replace `your_stripe_publishable_key_here` in `.env` file

## 🚀 Quick Start

1. **Copy the environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the .env file with your API keys:**
   ```bash
   nano .env
   # or use any text editor
   ```

3. **Run the app:**
   ```bash
   ./launch.sh web
   ```

## 💰 Cost Estimates

- **RapidAPI**: Free tier available (limited requests)
- **Mapbox**: Free tier with 50,000 map loads/month
- **OpenAI**: Pay-per-use (~$0.002 per 1K tokens)
- **Google Maps**: $200 free credit monthly
- **Stripe**: Free (only charges when processing payments)

## 🔒 Security Notes

- Never commit the `.env` file to version control
- Keep your API keys secure and don't share them
- Use environment variables in production
- Regularly rotate your API keys

## ❓ Troubleshooting

If you get API errors:
1. Check that all required keys are set in `.env`
2. Verify the keys are valid and have proper permissions
3. Check API quotas and billing status
4. Restart the app after changing `.env`
