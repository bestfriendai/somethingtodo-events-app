import 'dart:convert';
import 'package:dio/dio.dart';

/// Debug script to understand RapidAPI response format
void main() async {
  print('🔍 Debugging RapidAPI Response Format...\n');
  
  const apiKey = '92bc1b4fc7mshacea9f118bf7a3fp1b5a6cjsnd2287a72fcb9';
  const host = 'real-time-events-search.p.rapidapi.com';
  
  final dio = Dio();
  dio.options.headers = {
    'X-RapidAPI-Key': apiKey,
    'X-RapidAPI-Host': host,
    'Content-Type': 'application/json',
  };
  
  try {
    print('Making request to RapidAPI...');
    final response = await dio.get(
      'https://$host/search-events',
      queryParameters: {
        'query': 'music',
        'location': 'San Francisco, CA',
        'limit': '3',
      },
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('\nResponse Body:');
    print(const JsonEncoder.withIndent('  ').convert(response.data));
    
  } catch (e) {
    if (e is DioException) {
      print('Error Status: ${e.response?.statusCode}');
      print('Error Response: ${e.response?.data}');
    }
    print('Error: $e');
  }
}
