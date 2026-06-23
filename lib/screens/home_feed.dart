import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../models/news_post.dart';
import '../../models/news_out.dart';

class HomeFeedScreen extends StatefulWidget {
  final String area;
  final String language;
  final String pincode;
  final String state;

  const HomeFeedScreen({
    super.key,
    required this.area,
    required this.language,
    required this.pincode,
    required this.state,
  });

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  List<dynamic> ads = [];
  List<NewsPost> news = [];
  bool isLoadingNews = true;
  bool isLoadingAds = true;

  final String baseUrl = "http://192.168.1.42:8000";

  @override
  void initState() {
    super.initState();
    _loadCachedDataOrFetch();
  }

  @override
  void didUpdateWidget(HomeFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.area != widget.area ||
        oldWidget.language != widget.language ||
        oldWidget.pincode != widget.pincode ||
        oldWidget.state != widget.state) {
      _loadCachedDataOrFetch();
    }
  }

  // --- CACHING LOGIC ---

  Future<void> _loadCachedDataOrFetch() async {
    setState(() {
      isLoadingNews = true;
      isLoadingAds = true;
    });

    final prefs = await SharedPreferences.getInstance();
    
    final cacheId = "${widget.area}_${widget.pincode}_${widget.language}";
    final newsKey = 'cached_news_$cacheId';
    final adsKey = 'cached_ads_$cacheId';
    final timeKey = 'cache_time_$cacheId';

    final cachedTimeStr = prefs.getString(timeKey);
    
    if (cachedTimeStr != null) {
      final cachedTime = DateTime.parse(cachedTimeStr);
      final difference = DateTime.now().difference(cachedTime).inHours;

      if (difference < 12) {
        final cachedNewsJson = prefs.getString(newsKey);
        final cachedAdsJson = prefs.getString(adsKey);

        if (cachedNewsJson != null && cachedAdsJson != null) {
          debugPrint("--- LOADING FROM CACHE (${widget.language}) ---");
          setState(() {
            _processNewsResponse(cachedNewsJson);
            ads = json.decode(cachedAdsJson);
            isLoadingNews = false;
            isLoadingAds = false;
          });
          return;
        }
      }
    }

    _fetchData();
  }

  Future<void> _saveToCache(String newsJson, String adsJson) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheId = "${widget.area}_${widget.pincode}_${widget.language}";
    await prefs.setString('cached_news_$cacheId', newsJson);
    await prefs.setString('cached_ads_$cacheId', adsJson);
    await prefs.setString('cache_time_$cacheId', DateTime.now().toIso8601String());
    debugPrint("--- DATA SAVED TO CACHE (12H) ---");
  }

  // --- API LOGIC ---

  Future<void> _fetchData() async {
    final newsBody = await _fetchNewsRaw();
    final adsBody = await _fetchAdsRaw();

    if (newsBody != null && adsBody != null) {
      _saveToCache(newsBody, adsBody);
    }
  }

  Future<String?> _fetchNewsRaw() async {
    try {
      final newsBody = await ApiService().fetchNewsTopRaw(
        location: widget.area,
        pincode: widget.pincode.isEmpty ? null : widget.pincode,
        country: 'India',
        limit: 5,
        lang: widget.language,
      );
      if (newsBody != null) {
        setState(() => _processNewsResponse(newsBody));
        return newsBody;
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
    }
    setState(() => isLoadingNews = false);
    return null;
  }

  Future<String?> _fetchAdsRaw() async {
    try {
      final adsBody = await ApiService().fetchAdsRaw(
        area: widget.area,
      );
      if (adsBody != null) {
        setState(() {
          ads = json.decode(adsBody);
          isLoadingAds = false;
        });
        return adsBody;
      }
    } catch (e) {
      debugPrint("Error fetching ads: $e");
    }
    setState(() => isLoadingAds = false);
    return null;
  }

  void _processNewsResponse(String body) {
    try {
      final List<dynamic> data = json.decode(body);
      news = data.map((item) {
        final newsOut = NewsOut.fromJson(item);
        return NewsPost(
          id: newsOut.id,
          title: newsOut.title,
          description: newsOut.description,
          timeAgo: newsOut.timeAgo,
          url: newsOut.url,
          category: newsOut.category,
          location: newsOut.location ?? widget.area,
          distance: "",
        );
      }).toList();
    } catch (e) {
      debugPrint("Error processing news response: $e");
      news = [];
    }
    isLoadingNews = false;
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalHeight = constraints.maxHeight;
        final double adHeight = totalHeight * 0.32;
        
        return Column(
          children: [
            Expanded(
              child: isLoadingNews 
                ? const Center(child: CircularProgressIndicator())
                : news.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.newspaper, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text("No news for ${widget.area} yet.", style: const TextStyle(color: Colors.grey)),
                          TextButton(onPressed: _fetchData, child: const Text("Retry Now"))
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: news.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          return _buildNewsItem(context, news[index]);
                        },
                      ),
                    ),
            ),
            
            Container(
              height: adHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: isLoadingAds 
                ? const Center(child: CircularProgressIndicator())
                : ads.isEmpty
                  ? const Center(child: Text("Support local shops", style: TextStyle(fontSize: 10)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 6, 16, 2),
                          child: Text(
                            'Featured Local Business',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey),
                          ),
                        ),
                        Expanded(
                          child: _AutoScrollingAds(ads: ads),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsPost post) {
    return InkWell(
      onTap: () => _launchURL(post.url),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            post.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(post.timeAgo, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              const Spacer(),
              const Icon(Icons.share_outlined, size: 14, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutoScrollingAds extends StatefulWidget {
  final List<dynamic> ads;
  const _AutoScrollingAds({required this.ads});

  @override
  State<_AutoScrollingAds> createState() => _AutoScrollingAdsState();
}

class _AutoScrollingAdsState extends State<_AutoScrollingAds> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.ads.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (!mounted) return;
        if (_currentPage < widget.ads.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.ads.length,
      controller: _pageController,
      onPageChanged: (int page) => setState(() => _currentPage = page),
      itemBuilder: (context, index) {
        final ad = widget.ads[index];
        return _buildFeaturedAdCard(ad);
      },
    );
  }

  Widget _buildFeaturedAdCard(dynamic ad) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
              ),
              child: ad['imageUrl'] != null && ad['imageUrl'].toString().startsWith('http')
                ? Image.network(
                    ad['imageUrl'], 
                    fit: BoxFit.cover, 
                    errorBuilder: (c, e, s) => const Icon(Icons.storefront, size: 24, color: Colors.blue),
                  )
                : const Icon(Icons.storefront, size: 24, color: Colors.blue),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ad['shop_name'] ?? 'Shop',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Icon(Icons.call, color: Colors.green, size: 14),
                    ],
                  ),
                  Text(
                    ad['offer'] ?? 'Exclusive Local Offer!',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {
                        if (ad['phone'] != null) {
                          launchUrl(Uri.parse('tel:${ad['phone']}'));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Visit', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
