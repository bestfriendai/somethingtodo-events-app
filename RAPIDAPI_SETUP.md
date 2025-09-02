# 🔧 How to Connect RapidAPI for Real Events

## Current Status
The app is running successfully but showing **demo events** because RapidAPI is not configured. Here's how to get real events:

---

## Option 1: Continue with Demo Mode (Current)
✅ **Already Working** - The app shows sample events for testing
- No API key needed
- Perfect for UI/UX testing
- All features work except real-time data

---

## Option 2: Connect to RapidAPI (5 minutes)

### Step 1: Get a RapidAPI Key
1. Go to [RapidAPI.com](https://rapidapi.com/)
2. Sign up for a free account
3. Subscribe to one of these APIs:
   - **Real-time Events Search API** (Recommended)
   - **SerpApi Events**  
   - **Eventbrite API**
   - **Ticketmaster Discovery API**

### Step 2: Add Your API Key
1. Open the file: `somethingtodo/.env`
2. Replace `your_rapidapi_key_here` with your actual API key
3. Update the `RAPIDAPI_HOST` with the correct host from your chosen API

### Step 3: Update the Service (if needed)
For direct API calls (bypassing Firebase), modify `lib/services/rapidapi_events_service.dart`:

```dart
// Around line 33-40, change from Firebase Functions URL to direct API:
_dio.options.baseUrl = 'https://real-time-events-search.p.rapidapi.com';
_dio.options.headers = {
  'X-RapidAPI-Key': 'YOUR_API_KEY_HERE', // Add your key
  'X-RapidAPI-Host': 'real-time-events-search.p.rapidapi.com'
};
```

### Step 4: Restart the App
Press `R` in the terminal to hot restart the app

---

## Option 3: Use Firebase Functions (Production Ready)

### Prerequisites
- Firebase project setup
- Firebase CLI installed
- Cloud Functions enabled

### Steps:
1. Deploy the Firebase Functions:
```bash
cd somethingtodo/functions
npm install
firebase deploy --only functions
```

2. The functions will securely store your API key
3. The app will automatically use the deployed functions

---

## 🎯 Quick Solution for Testing

Since you want to test the app now, you can:

1. **Keep using demo mode** - It's already working!
2. **The app is fully functional** with sample events
3. All features work:
   - ✅ Event browsing
   - ✅ Search
   - ✅ Map view
   - ✅ Favorites
   - ✅ Profile
   - ✅ Theme switching

---

## 📝 Notes

- **CORS Issues**: Web apps can't directly call some APIs due to browser security. That's why Firebase Functions proxy is recommended.
- **API Limits**: Free RapidAPI accounts have request limits (usually 500-1000/month)
- **Security**: Never put API keys directly in client code for production

The app is **working perfectly** in demo mode right now! You can test all functionality without needing real API data.