import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/api_result.dart';
import '../models/news_out.dart';
import '../models/article_out.dart';
import '../models/ad.dart';
import '../models/location_models.dart';
import '../models/auth_models.dart';
import '../models/health_models.dart';

class ApiService {
  String get _baseUrl => AppConfig.baseUrl;

  Future<Resource<T>> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = json.decode(response.body);
        return Success(fromJson(data));
      } catch (e) {
        return Error('Failed to parse response: $e');
      }
    }
    return Error('Request failed with status ${response.statusCode}: ${response.body}');
  }

  Future<Resource<List<T>>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body) as List<dynamic>;
        return Success(data.map((e) => fromJson(e)).toList());
      } catch (e) {
        return Error('Failed to parse list response: $e');
      }
    }
    return Error('Request failed with status ${response.statusCode}: ${response.body}');
  }

  Future<Resource<ApiHealth>> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health')).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleResponse(response, ApiHealth.fromJson);
    } catch (e) {
      return Error('Health check failed: $e');
    }
  }

  Future<Resource<GeminiTestResponse>> testGemini() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/test-gemini')).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleResponse(response, GeminiTestResponse.fromJson);
    } catch (e) {
      return Error('Gemini test failed: $e');
    }
  }

  Future<Resource<List<ArticleOut>>> getNews({String? location}) async {
    try {
      final uri = Uri.parse('$_baseUrl/news').replace(queryParameters: {
        if (location != null && location.isNotEmpty) 'location': location,
      });
      final response = await http.get(uri).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleListResponse(response, ArticleOut.fromJson);
    } catch (e) {
      return Error('Failed to fetch news: $e');
    }
  }

  Future<Resource<List<NewsOut>>> getTopNews({
    required String location,
    String? pincode,
    String? country,
    int limit = 5,
    String? lang,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/news/top').replace(queryParameters: {
        'location': location,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
        if (country != null && country.isNotEmpty) 'country': country,
        'limit': limit.toString(),
        if (lang != null && lang.isNotEmpty) 'lang': lang,
      });
      final response = await http.get(uri).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleListResponse(response, NewsOut.fromJson);
    } catch (e) {
      return Error('Failed to fetch top news: $e');
    }
  }

  Future<String?> fetchNewsTopRaw({
    required String location,
    String? pincode,
    String? country,
    int limit = 5,
    String? lang,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/news/top').replace(queryParameters: {
        'location': location,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
        if (country != null && country.isNotEmpty) 'country': country,
        'limit': limit.toString(),
        if (lang != null && lang.isNotEmpty) 'lang': lang,
      });
      final response = await http.get(uri).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching top news raw: $e');
      return null;
    }
  }

  Future<Resource<List<Ad>>> getAds({String? area}) async {
    try {
      final uri = Uri.parse('$_baseUrl/ads').replace(queryParameters: {
        if (area != null && area.isNotEmpty) 'area': area,
      });
      final response = await http.get(uri).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleListResponse(response, Ad.fromJson);
    } catch (e) {
      return Error('Failed to fetch ads: $e');
    }
  }

  Future<String?> fetchAdsRaw({String? area}) async {
    try {
      final uri = Uri.parse('$_baseUrl/ads').replace(queryParameters: {
        if (area != null && area.isNotEmpty) 'area': area,
      });
      final response = await http.get(uri).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching ads raw: $e');
      return null;
    }
  }

  Future<Resource<Ad>> getAdById(String adId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/ads/$adId')).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleResponse(response, Ad.fromJson);
    } catch (e) {
      return Error('Failed to fetch ad: $e');
    }
  }

  Future<Resource<List<LocationOut>>> getLocations() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/locations')).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleListResponse(response, LocationOut.fromJson);
    } catch (e) {
      return Error('Failed to fetch locations: $e');
    }
  }

  Future<Resource<LocationOut>> createLocation(LocationCreate location) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/locations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(location.toJson()),
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleResponse(response, LocationOut.fromJson);
    } catch (e) {
      return Error('Failed to create location: $e');
    }
  }

  Future<Resource<LocationOut>> getLocationBySlug(String slug) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/locations/$slug')).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleResponse(response, LocationOut.fromJson);
    } catch (e) {
      return Error('Failed to fetch location: $e');
    }
  }

  Future<Resource<UserOut>> register(UserRegister user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleResponse(response, UserOut.fromJson);
    } catch (e) {
      return Error('Registration failed: $e');
    }
  }

  Future<Resource<UserOut>> login(UserLogin credentials) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(credentials.toJson()),
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
      );
      return _handleResponse(response, UserOut.fromJson);
    } catch (e) {
      return Error('Login failed: $e');
    }
  }
}
