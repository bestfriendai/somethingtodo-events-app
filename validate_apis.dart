import 'dart:io';
import 'package:dio/dio.dart';

/// API Validation Script
/// 
/// This script validates that all required API keys and endpoints are working correctly.
/// It should be run before deployment to ensure all external services are accessible.
/// 
/// Usage: dart validate_apis.dart
/// 
/// Environment Variables Required:
/// - RAPIDAPI_KEY: RapidAPI key for events service
/// - OPENAI_API_KEY: OpenAI API key for chat functionality
/// - MAPBOX_ACCESS_TOKEN: Mapbox token for map services
/// - SUPABASE_URL: Supabase project URL
/// - SUPABASE_ANON_KEY: Supabase anonymous key

void main() async {
  print('🔍 Starting API Validation...\n');

  final results = <String, bool>{};

  // Validate all APIs
  results['RapidAPI Events'] = await validateRapidAPI();
  results['OpenAI'] = await validateOpenAI();
  results['Mapbox'] = await validateMapbox();
  results['Supabase'] = await validateSupabase();

  // Print summary
  print('\n📊 Validation Summary:');
  print('=' * 50);
  
  int passed = 0;
  int total = results.length;
  
  results.forEach((service, isValid) {
    final status = isValid ? '✅ PASS' : '❌ FAIL';
    print('$service: $status');
    if (isValid) passed++;
  });
  
  print('=' * 50);
  print('Total: $passed/$total services validated');
  
  if (passed == total) {
    print('🎉 All APIs are working correctly!');
    exit(0);
  } else {
    print('⚠️  Some APIs failed validation. Please check configuration.');
    exit(1);
  }
}

/// Test RapidAPI Events Service
Future<bool> validateRapidAPI() async {
  print('🎪 Testing RapidAPI Events...');
  
  const apiKey = String.fromEnvironment('RAPIDAPI_KEY');
  
  if (apiKey.isEmpty) {
    print('   ❌ RapidAPI key not found in environment variables');
    return false;
  }

  try {
    final dio = Dio();
    dio.options.headers = {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': 'real-time-events-search.p.rapidapi.com',
    };

    final response = await dio.get(
      'https://real-time-events-search.p.rapidapi.com/search-events',
      queryParameters: {
        'query': 'music',
        'start': 0,
        'date_period': 'today',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final events = data['data'] as List;
        print('   ✅ RapidAPI: Working! Found ${events.length} events');
        return true;
      } else {
        print('   ⚠️  RapidAPI: Connected but unexpected response format');
        return false;
      }
    } else {
      print('   ❌ RapidAPI: HTTP ${response.statusCode}');
      return false;
    }
  } catch (e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        print('   ❌ RapidAPI: Invalid API key');
      } else if (e.response?.statusCode == 429) {
        print('   ⚠️  RapidAPI: Rate limited (but key is valid)');
        return true; // Rate limit means the key works
      } else if (e.response?.statusCode == 403) {
        print('   ❌ RapidAPI: Access forbidden - check subscription');
      } else {
        print('   ❌ RapidAPI: HTTP ${e.response?.statusCode} - ${e.message}');
      }
    } else {
      print('   ❌ RapidAPI: Network error - $e');
    }
    return false;
  }
}

/// Test OpenAI API
Future<bool> validateOpenAI() async {
  print('🤖 Testing OpenAI API...');

  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  
  if (apiKey.isEmpty) {
    print('   ❌ OpenAI API key not found in environment variables');
    return false;
  }

  try {
    final dio = Dio();
    dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final response = await dio.get('https://api.openai.com/v1/models');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final models = data['data'] as List;
        print('   ✅ OpenAI: Working! Found ${models.length} models available');
        return true;
      } else {
        print('   ⚠️  OpenAI: Connected but unexpected response format');
        return false;
      }
    } else {
      print('   ❌ OpenAI: HTTP ${response.statusCode}');
      return false;
    }
  } catch (e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        print('   ❌ OpenAI: Invalid API key');
      } else if (e.response?.statusCode == 429) {
        print('   ⚠️  OpenAI: Rate limited (but key is valid)');
        return true;
      } else if (e.response?.statusCode == 403) {
        print('   ❌ OpenAI: Access forbidden - check billing');
      } else {
        print('   ❌ OpenAI: HTTP ${e.response?.statusCode} - ${e.message}');
      }
    } else {
      print('   ❌ OpenAI: Network error - $e');
    }
    return false;
  }
}

/// Test Mapbox API
Future<bool> validateMapbox() async {
  print('🗺️  Testing Mapbox API...');
  
  const accessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
  
  if (accessToken.isEmpty) {
    print('   ❌ Mapbox access token not found in environment variables');
    return false;
  }

  try {
    final dio = Dio();
    final response = await dio.get(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/New York.json',
      queryParameters: {
        'access_token': accessToken,
        'limit': 1,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data.containsKey('features')) {
        final features = data['features'] as List;
        print('   ✅ Mapbox: Working! Found ${features.length} geocoding results');
        return true;
      } else {
        print('   ⚠️  Mapbox: Connected but unexpected response format');
        return false;
      }
    } else {
      print('   ❌ Mapbox: HTTP ${response.statusCode}');
      return false;
    }
  } catch (e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        print('   ❌ Mapbox: Invalid access token');
      } else if (e.response?.statusCode == 429) {
        print('   ⚠️  Mapbox: Rate limited (but token is valid)');
        return true;
      } else {
        print('   ❌ Mapbox: HTTP ${e.response?.statusCode} - ${e.message}');
      }
    } else {
      print('   ❌ Mapbox: Network error - $e');
    }
    return false;
  }
}

/// Test Supabase API
Future<bool> validateSupabase() async {
  print('🗄️  Testing Supabase API...');
  
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('   ❌ Supabase configuration not found in environment variables');
    return false;
  }

  try {
    final dio = Dio();
    dio.options.headers = {
      'apikey': supabaseKey,
      'Authorization': 'Bearer $supabaseKey',
      'Content-Type': 'application/json',
    };

    final response = await dio.get('$supabaseUrl/rest/v1/');

    if (response.statusCode == 200) {
      print('   ✅ Supabase: Working! API is accessible');
      return true;
    } else {
      print('   ❌ Supabase: HTTP ${response.statusCode}');
      return false;
    }
  } catch (e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        print('   ❌ Supabase: Invalid API key');
      } else if (e.response?.statusCode == 404) {
        print('   ❌ Supabase: Invalid URL or project not found');
      } else {
        print('   ❌ Supabase: HTTP ${e.response?.statusCode} - ${e.message}');
      }
    } else {
      print('   ❌ Supabase: Network error - $e');
    }
    return false;
  }
}
