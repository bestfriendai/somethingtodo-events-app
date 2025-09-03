#!/bin/bash

# API Testing Script for SomethingToDo
echo "🧪 Testing API Configurations"
echo "============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Load environment variables
if [ -f ".env" ]; then
    source .env
    print_success ".env file loaded"
else
    print_error ".env file not found"
    exit 1
fi

echo ""
echo "🔍 Testing API Endpoints:"
echo "========================"

# Test RapidAPI
echo ""
print_info "Testing RapidAPI Events Service..."
if [ -n "$RAPIDAPI_KEY" ] && [ "$RAPIDAPI_KEY" != "your_rapidapi_key_here" ]; then
    response=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "X-RapidAPI-Key: $RAPIDAPI_KEY" \
        -H "X-RapidAPI-Host: real-time-events-search.p.rapidapi.com" \
        "https://real-time-events-search.p.rapidapi.com/search-events?query=music&location=San%20Francisco")
    
    if [ "$response" = "200" ]; then
        print_success "RapidAPI Events Service - Working"
    elif [ "$response" = "401" ]; then
        print_error "RapidAPI Events Service - Invalid API Key"
    elif [ "$response" = "429" ]; then
        print_warning "RapidAPI Events Service - Rate Limited (but key is valid)"
    else
        print_warning "RapidAPI Events Service - HTTP $response (check quota/billing)"
    fi
else
    print_error "RapidAPI key not configured"
fi

# Test Mapbox
echo ""
print_info "Testing Mapbox API..."
if [ -n "$MAPBOX_ACCESS_TOKEN" ] && [ "$MAPBOX_ACCESS_TOKEN" != "your_mapbox_token_here" ]; then
    response=$(curl -s -w "%{http_code}" -o /dev/null \
        "https://api.mapbox.com/styles/v1/mapbox/streets-v12?access_token=$MAPBOX_ACCESS_TOKEN")
    
    if [ "$response" = "200" ]; then
        print_success "Mapbox API - Working"
    elif [ "$response" = "401" ]; then
        print_error "Mapbox API - Invalid Access Token"
    else
        print_warning "Mapbox API - HTTP $response"
    fi
else
    print_error "Mapbox access token not configured"
fi

# Test OpenAI
echo ""
print_info "Testing OpenAI API..."
if [ -n "$OPENAI_API_KEY" ] && [ "$OPENAI_API_KEY" != "your_openai_api_key_here" ]; then
    response=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        "https://api.openai.com/v1/models")
    
    if [ "$response" = "200" ]; then
        print_success "OpenAI API - Working"
    elif [ "$response" = "401" ]; then
        print_error "OpenAI API - Invalid API Key"
    elif [ "$response" = "429" ]; then
        print_warning "OpenAI API - Rate Limited (but key is valid)"
    else
        print_warning "OpenAI API - HTTP $response (check billing/quota)"
    fi
else
    print_error "OpenAI API key not configured"
fi

echo ""
echo "📋 Test Summary:"
echo "==============="
print_info "App is running at: http://localhost:58731"
print_info "DevTools available at: http://127.0.0.1:9102"
echo ""
print_success "All configured APIs have been tested!"
echo ""
echo "🎯 Next Steps:"
echo "============="
echo "1. Open the app in your browser"
echo "2. Test the Events tab (should load real events)"
echo "3. Test the Map tab (should show Mapbox map)"
echo "4. Test the Chat tab (should respond with AI)"
echo "5. Check browser console for any errors"
