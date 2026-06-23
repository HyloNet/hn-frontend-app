import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:hyperlocal_news/config/app_config.dart';
import 'package:hyperlocal_news/models/ad.dart';
import 'package:hyperlocal_news/models/article_out.dart';
import 'package:hyperlocal_news/models/auth_models.dart';
import 'package:hyperlocal_news/models/health_models.dart';
import 'package:hyperlocal_news/models/location_models.dart';
import 'package:hyperlocal_news/models/news_out.dart';
import 'package:hyperlocal_news/services/api_result.dart';
import 'package:hyperlocal_news/services/api_service.dart';

class FakeClient implements http.Client {
  final Map<String, http.Response> _responses;

  FakeClient(this._responses);

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final key = 'GET:${url.toString()}';
    return _responses[key] ?? http.Response('Not Found', 404);
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers,
      dynamic body,
      Encoding? encoding}) async {
    final key = 'POST:${url.toString()}';
    return _responses[key] ?? http.Response('Not Found', 404);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  @override
  void close() {}
}

void main() {
  late FakeClient fakeClient;
  late ApiService apiService;

  setUp(() {
    fakeClient = FakeClient({});
    apiService = ApiService(client: fakeClient);
  });

  group('ApiService endpoint tests', () {
    test('fetchNewsTopRaw returns JSON on success', () async {
      final body = json.encode([
        {
          'id': 'gemini_1',
          'title': 'Test News',
          'description': 'Desc',
          'timeAgo': '1h ago',
          'url': 'https://example.com',
          'category': 'Local',
          'location': 'Kundli',
        }
      ]);
      final key = 'GET:${AppConfig.baseUrl}/news/top?location=Kundli&country=India&limit=5';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.fetchNewsTopRaw(
        location: 'Kundli',
        country: 'India',
        limit: 5,
      );

      expect(result, equals(body));
    });

    test('fetchAdsRaw returns JSON on success', () async {
      final body = json.encode([
        {
          'id': 'ad_1',
          'shop_name': 'Test Shop',
          'offer': 'Offer A',
          'phone': '+919999999999',
          'imageUrl': 'https://example.com/img.jpg',
          'area': 'Kundli',
        }
      ]);
      final key = 'GET:${AppConfig.baseUrl}/ads?area=Kundli';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.fetchAdsRaw(area: 'Kundli');

      expect(result, equals(body));
    });

    test('getTopNews returns Success with list of NewsOut', () async {
      final body = json.encode([
        {
          'id': 'gemini_2',
          'title': 'Top News',
          'description': 'Desc',
          'timeAgo': '2h ago',
          'url': 'https://example.com',
          'category': 'Traffic',
        }
      ]);
      final key = 'GET:${AppConfig.baseUrl}/news/top?location=Sonipat&country=India&limit=5';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.getTopNews(
        location: 'Sonipat',
        country: 'India',
        limit: 5,
      );

      expect(result, isA<Success<List<NewsOut>>>());
      final success = result as Success<List<NewsOut>>;
      expect(success.data.length, 1);
      expect(success.data.first.title, 'Top News');
    });

    test('getAds returns Success with list of Ad', () async {
      final body = json.encode([
        {
          'id': 'ad_2',
          'shop_name': 'Shop X',
          'offer': 'Buy 1 Get 1',
          'phone': '+919999999998',
          'imageUrl': 'https://example.com/img2.jpg',
        }
      ]);
      final key = 'GET:${AppConfig.baseUrl}/ads?area=Kundli';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.getAds(area: 'Kundli');

      expect(result, isA<Success<List<Ad>>>());
      final success = result as Success<List<Ad>>;
      expect(success.data.length, 1);
      expect(success.data.first.shopName, 'Shop X');
    });

    test('login returns Success with UserOut', () async {
      final body = json.encode({
        'status': 'success',
        'user': {
          'id': 1,
          'mobile_number': '1234567890',
          'country': 'India',
          'state': 'Haryana',
          'district': 'Sonipat',
          'city_village': 'Kundli',
          'created_at': '2026-06-23T10:00:00Z',
          'is_admin': false,
        }
      });
      final key = 'POST:${AppConfig.baseUrl}/auth/login';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.login(UserLogin(
        mobileNumber: '1234567890',
        password: 'password',
      ));

      expect(result, isA<Success<UserOut>>());
      final success = result as Success<UserOut>;
      expect(success.data.id, 1);
      expect(success.data.mobileNumber, '1234567890');
    });

    test('register returns Success with UserOut', () async {
      final body = json.encode({
        'status': 'success',
        'user': {
          'id': 2,
          'mobile_number': '9876543210',
          'created_at': '2026-06-23T10:00:00Z',
          'is_admin': false,
        }
      });
      final key = 'POST:${AppConfig.baseUrl}/auth/register';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.register(UserRegister(
        mobileNumber: '9876543210',
        password: 'password',
      ));

      expect(result, isA<Success<UserOut>>());
      final success = result as Success<UserOut>;
      expect(success.data.id, 2);
      expect(success.data.mobileNumber, '9876543210');
    });

    test('createLocation returns Success with LocationOut', () async {
      final body = json.encode({
        'id': 1,
        'name': 'Kundli, Sonipat',
        'slug': 'kundli-sonipat',
        'pincode': '131028',
        'country': 'India',
        'created_at': '2026-06-23T10:00:00Z',
      });
      final key = 'POST:${AppConfig.baseUrl}/locations';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.createLocation(LocationCreate(
        name: 'Kundli, Sonipat',
        pincode: '131028',
        country: 'India',
      ));

      expect(result, isA<Success<LocationOut>>());
      final success = result as Success<LocationOut>;
      expect(success.data.slug, 'kundli-sonipat');
    });

    test('getLocations returns Success with list of LocationOut', () async {
      final body = json.encode([
        {
          'id': 1,
          'name': 'Kundli',
          'slug': 'kundli',
          'pincode': '131028',
          'country': 'India',
          'created_at': '2026-06-23T10:00:00Z',
        }
      ]);
      final key = 'GET:${AppConfig.baseUrl}/locations';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.getLocations();

      expect(result, isA<Success<List<LocationOut>>>());
      final success = result as Success<List<LocationOut>>;
      expect(success.data.length, 1);
      expect(success.data.first.name, 'Kundli');
    });

    test('getAdById returns Success with Ad', () async {
      final body = json.encode({
        'id': 'ad_501',
        'shop_name': 'Aggarwal Sweets',
        'offer': 'Buy 1KG Paneer, Get 250g Free!',
        'phone': '+919876543210',
        'imageUrl': 'https://hylonet.com/ads/aggarwal.jpg',
        'area': 'KUNDLI',
      });
      final key = 'GET:${AppConfig.baseUrl}/ads/ad_501';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.getAdById('ad_501');

      expect(result, isA<Success<Ad>>());
      final success = result as Success<Ad>;
      expect(success.data.shopName, 'Aggarwal Sweets');
    });

    test('getNews returns Success with list of ArticleOut', () async {
      final body = json.encode([
        {
          'id': 1,
          'title': 'Traffic',
          'description': 'Heavy traffic',
          'url': 'https://hylonet.com',
          'source_site': 'local-news.com',
          'category': 'Traffic',
          'published_at': '2026-06-23T10:00:00Z',
          'fetched_at': '2026-06-23T12:00:00Z',
        }
      ]);
      final key = 'GET:${AppConfig.baseUrl}/news?location=Kundli';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.getNews(location: 'Kundli');

      expect(result, isA<Success<List<ArticleOut>>>());
      final success = result as Success<List<ArticleOut>>;
      expect(success.data.length, 1);
      expect(success.data.first.category, 'Traffic');
    });

    test('healthCheck returns Success with ApiHealth', () async {
      final body = json.encode({'status': 'healthy'});
      final key = 'GET:${AppConfig.baseUrl}/health';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.healthCheck();

      expect(result, isA<Success<ApiHealth>>());
      final success = result as Success<ApiHealth>;
      expect(success.data.status, 'healthy');
    });

    test('testGemini returns Success with GeminiTestResponse', () async {
      final body = json.encode({'status': 'success', 'message': 'OK'});
      final key = 'GET:${AppConfig.baseUrl}/test-gemini';
      fakeClient = FakeClient({key: http.Response(body, 200)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.testGemini();

      expect(result, isA<Success<GeminiTestResponse>>());
      final success = result as Success<GeminiTestResponse>;
      expect(success.data.status, 'success');
    });

    test('endpoints return Error on non-200 status', () async {
      final key = 'GET:${AppConfig.baseUrl}/health';
      fakeClient = FakeClient({key: http.Response('Server Error', 500)});
      apiService = ApiService(client: fakeClient);

      final result = await apiService.healthCheck();

      expect(result, isA<Error<ApiHealth>>());
      final error = result as Error<ApiHealth>;
      expect(error.message, contains('500'));
    });
  });
}
