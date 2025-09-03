#!/bin/bash

# API Keys Validation Script for SomethingToDo
echo "🔍 Checking API Keys Configuration"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    echo "Run: cp .env.example .env"
    echo "Then edit .env with your API keys"
    exit 1
fi

print_success ".env file found"

# Load environment variables
source .env

# Check each API key
echo ""
echo "🔑 Checking API Keys:"
echo "===================="

# RapidAPI Key
if [ -z "$RAPIDAPI_KEY" ] || [ "$RAPIDAPI_KEY" = "your_rapidapi_key_here" ]; then
    print_error "RapidAPI Key not configured"
    echo "   Get it from: https://rapidapi.com/real-time-events-search/api/real-time-events-search"
else
    print_success "RapidAPI Key configured"
fi

# Mapbox Token
if [ -z "$MAPBOX_ACCESS_TOKEN" ] || [ "$MAPBOX_ACCESS_TOKEN" = "your_mapbox_token_here" ]; then
    print_error "Mapbox Access Token not configured"
    echo "   Get it from: https://account.mapbox.com/access-tokens/"
else
    print_success "Mapbox Access Token configured"
fi

# OpenAI API Key
if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "your_openai_api_key_here" ]; then
    print_error "OpenAI API Key not configured"
    echo "   Get it from: https://platform.openai.com/api-keys"
else
    print_success "OpenAI API Key configured"
fi

# Google Maps API Key (Optional - using Mapbox instead)
if [ -z "$GOOGLE_MAPS_API_KEY" ] || [ "$GOOGLE_MAPS_API_KEY" = "your_google_maps_api_key_here" ] || [ "$GOOGLE_MAPS_API_KEY" = "disabled" ]; then
    print_info "Google Maps API Key not configured (using Mapbox instead)"
else
    print_success "Google Maps API Key configured"
fi

# Stripe (Optional)
if [ -z "$STRIPE_PUBLISHABLE_KEY" ] || [ "$STRIPE_PUBLISHABLE_KEY" = "your_stripe_publishable_key_here" ]; then
    print_warning "Stripe Key not configured (optional for premium features)"
else
    print_success "Stripe Key configured"
fi

echo ""
echo "📋 Summary:"
echo "==========="

# Count configured keys
configured=0
total=3

if [ -n "$RAPIDAPI_KEY" ] && [ "$RAPIDAPI_KEY" != "your_rapidapi_key_here" ]; then
    ((configured++))
fi

if [ -n "$MAPBOX_ACCESS_TOKEN" ] && [ "$MAPBOX_ACCESS_TOKEN" != "your_mapbox_token_here" ]; then
    ((configured++))
fi

if [ -n "$OPENAI_API_KEY" ] && [ "$OPENAI_API_KEY" != "your_openai_api_key_here" ]; then
    ((configured++))
fi

echo "Configured: $configured/$total required API keys"

if [ $configured -eq $total ]; then
    print_success "All required API keys are configured! 🎉"
    echo ""
    echo "You can now run the app:"
    echo "./launch.sh web"
else
    print_warning "Some API keys are missing. The app may not work fully."
    echo ""
    echo "See API_KEYS_SETUP_GUIDE.md for detailed instructions."
fi
