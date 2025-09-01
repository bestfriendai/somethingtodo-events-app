# Firebase Functions for SomethingToDo

## Setup

### Environment Variables

This project requires API keys for OpenAI and RapidAPI services. These keys are stored securely and never committed to version control.

#### Local Development

1. Create a `.env` file in the `functions` directory (already created for you)
2. The `.env` file contains:
   ```
   OPENAI_API_KEY=your_openai_api_key
   RAPIDAPI_KEY=your_rapidapi_key
   ```

#### Production Deployment

For production, API keys are stored in Firebase Functions configuration:

1. Run the configuration script:
   ```bash
   ./set-config.sh
   ```

2. Verify the configuration:
   ```bash
   firebase functions:config:get
   ```

3. Deploy the functions:
   ```bash
   npm run deploy
   ```

### Important Security Notes

- **NEVER** commit `.env` files to version control
- The `.env` file is already added to `.gitignore`
- API keys are loaded from Firebase Functions config in production
- API keys are loaded from `.env` file in development
- Always rotate API keys if they are accidentally exposed

## Available Scripts

- `npm run build` - Compile TypeScript to JavaScript
- `npm run serve` - Run functions locally with emulator
- `npm run deploy` - Deploy functions to Firebase
- `npm run logs` - View function logs

## API Endpoints

### Chat API
- `POST /chat` - Process chat messages with AI

### Events API
- `GET /events/search` - Search for events
- `GET /events/trending` - Get trending events
- `GET /events/nearby` - Get nearby events
- `GET /events/details` - Get event details
- `GET /events/category` - Get events by category
- `POST /events/sync` - Sync event data

### Recommendations API
- `POST /recommendations/generate` - Generate personalized recommendations

## Error Handling

The functions include comprehensive error handling:
- Missing API keys are detected at startup
- API errors return appropriate error messages
- Detailed logging for debugging

## Testing

Test the functions locally:
```bash
npm run serve
```

Then make requests to:
```
http://localhost:5001/YOUR_PROJECT_ID/us-central1/api
```