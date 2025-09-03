#!/bin/bash

# SomethingToDo Environment Setup Script
echo "🔧 Setting up SomethingToDo Environment"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if .env file exists
if [ -f ".env" ]; then
    print_warning ".env file already exists. Backing up to .env.backup"
    cp .env .env.backup
fi

# Copy example file
print_status "Creating .env file from template..."
cp .env.example .env

print_success ".env file created!"

echo ""
echo "🔑 API Keys Setup Required"
echo "========================="
echo ""
echo "You need to obtain and configure the following API keys:"
echo ""

echo "1. 🚀 RapidAPI Key (for Events)"
echo "   - Visit: https://rapidapi.com/real-time-events-search/api/real-time-events-search"
echo "   - Sign up and get your API key"
echo "   - Replace 'your_rapidapi_key_here' in .env file"
echo ""

echo "2. 🗺️  Mapbox Access Token (for Maps)"
echo "   - Visit: https://account.mapbox.com/access-tokens/"
echo "   - Create a new token or use existing one"
echo "   - Replace 'your_mapbox_token_here' in .env file"
echo ""

echo "3. 🤖 OpenAI API Key (for AI Chat) - Optional"
echo "   - Visit: https://platform.openai.com/api-keys"
echo "   - Create a new API key"
echo "   - Add OPENAI_API_KEY=your_key to .env file"
echo ""

echo "4. 🗺️  Google Maps API Key (for Location Services) - Optional"
echo "   - Visit: https://console.cloud.google.com/apis/credentials"
echo "   - Create a new API key"
echo "   - Add GOOGLE_MAPS_API_KEY=your_key to .env file"
echo ""

echo "📝 Next Steps:"
echo "=============="
echo "1. Edit the .env file with your actual API keys"
echo "2. Run: flutter run --dart-define-from-file=.env -d chrome"
echo "3. Or use: ./launch.sh web"
echo ""

print_warning "Remember: NEVER commit the .env file to version control!"
print_success "Setup complete! Edit .env with your API keys and run the app."
