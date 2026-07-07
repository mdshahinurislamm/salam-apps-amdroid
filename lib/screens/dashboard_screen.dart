import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_flip/page_flip.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../models/banner_model.dart';
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../services/pdf_cache_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _platform =
      MethodChannel('com.example.flutter_application_1/paths');

  final ApiService _api = ApiService();
  late final PdfCacheService _pdfCache =
      PdfCacheService(getCacheDir: _getCacheDir, api: _api);

  // Posts state
  List<PostModel> _posts = [];
  bool _postsLoading = false;
  String? _postsError;

  // Banner slider state
  List<BannerModel> _banners = [];
  bool _bannersLoading = false;
  String? _bannersError;
  final PageController _bannerController =
      PageController(viewportFraction: 1.0);
  Timer? _bannerTimer;
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPosts());
    _loadBanners();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    if (!mounted) return;
    setState(() {
      _bannersLoading = true;
      _bannersError = null;
    });
    try {
      final banners = await _api.fetchBanners();
      if (!mounted) return;
      setState(() {
        _banners = banners;
        _bannersLoading = false;
      });
      debugPrint('Banners loaded: ${banners.length}');
      _startBannerAutoSlide();
    } catch (e) {
      debugPrint('Banner load failed: $e');
      if (!mounted) return;
      setState(() {
        _bannersError = e.toString();
        _bannersLoading = false;
      });
    }
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    if (_banners.length <= 1) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_currentBanner + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<String> _getCacheDir() async {
    return await _platform.invokeMethod('getCacheDir');
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    setState(() {
      _postsLoading = true;
      _postsError = null;
    });
    try {
      final posts = await _api.fetchPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _postsLoading = false;
      });
      // Warm the cache in the background for any PDF never downloaded
      // before, so tapping into it later opens instantly instead of
      // waiting on the network. Cheap to call repeatedly — already-cached
      // posts are skipped.
      _pdfCache.prefetchMissing(posts);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _postsError = e.toString();
        _postsLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final isAr = context.read<LanguageProvider>().isArabic;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'تسجيل الخروج' : 'Logout'),
        content: Text(
            isAr ? 'هل تريد تسجيل الخروج؟' : 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isAr ? 'خروج' : 'Logout',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  /// Opens the PDF viewer screen for a given post.
  Future<void> _openPdf(PostModel post) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PdfViewerScreen(
          post: post,
          getCacheDir: _getCacheDir,
          api: _api,
          pdfCache: _pdfCache,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final isAr = lang.isArabic;
    final userAge = auth.user?.age ?? '';

    // Filter posts: type matches user.age, published only,
    // AND language matches the current app language toggle.
    final activeLang = isAr ? 'arabic' : 'english';
    final visiblePosts = _posts
        .where((p) =>
            p.isPublished &&
            p.type == userAge &&
            p.languages.toLowerCase() == activeLang)
        .toList();

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: const Color(0xFF9A9B78),
          foregroundColor: Colors.white,
          elevation: 0,
          // title: Text(
          //   isAr ? 'لوحة التحكم' : 'Dashboard',
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: _LangToggle(provider: lang),
            ),
            IconButton(
              icon: const Icon(Icons.person_outlined),
              tooltip: isAr ? 'الملف الشخصي' : 'Profile',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: isAr ? 'تسجيل الخروج' : 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildUserBanner(auth, isAr, userAge),
            _buildBannerSlider(),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF9A9B78),
                onRefresh: _loadPosts,
                child: _buildBody(
                  isAr: isAr,
                  posts: visiblePosts,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBanner(AuthProvider auth, bool isAr, String userAge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF9A9B78).withOpacity(0.1),
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(Icons.person, color: Color(0xFF9A9B78)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // isAr
                  //     ? 'مرحباً، ${auth.user?.firstName ?? ''}'
                  //     : 'Welcome, ${auth.user?.firstName ?? ''}',
                  isAr
                      ? '${auth.user?.firstName ?? ''} ${auth.user?.lastName ?? ''}'
                      : '${auth.user?.firstName ?? ''} ${auth.user?.lastName ?? ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  auth.user?.email ?? '',
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          if (userAge.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF9A9B78),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                // userAge.toUpperCase().replaceAll('_', ' '),
                auth.user?.age == 'group_a' ? 'Ages 4–8': 'Ages 12–16',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    if (_bannersLoading) {
      return Container(
        height: 160,
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF9A9B78),
            ),
          ),
        ),
      );
    }

    if (_bannersError != null) {
      return Container(
        height: 90,
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.red.shade300, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Banners failed to load: $_bannersError',
                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: Colors.red.shade300,
              onPressed: _loadBanners,
            ),
          ],
        ),
      );
    }

    if (_banners.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: PageView.builder(
                controller: _bannerController,
                itemCount: _banners.length,
                onPageChanged: (index) {
                  if (mounted) setState(() => _currentBanner = index);
                },
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  return Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF9A9B78),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.grey.shade400, size: 32),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if (_banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (index) {
                final isActive = index == _currentBanner;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF9A9B78)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody({
    required bool isAr,
    required List<PostModel> posts,
  }) {
    if (_postsLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF9A9B78)),
            const SizedBox(height: 16),
            Text(
              isAr ? 'جارٍ التحميل...' : 'Loading...',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_postsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                isAr ? 'فشل تحميل المحتوى' : 'Failed to Load Content',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPosts,
                icon: const Icon(Icons.refresh),
                label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا توجد ملفات متاحة' : 'No files available',
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'اسحب للأسفل للتحديث' : 'Pull down to refresh',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final color =
        isAr ? const Color(0xFF9A9B78) : const Color(0xFF9A9B78);
    final sectionLabel =
        isAr ? 'الكتب العربية' : 'English Books';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _sectionHeader(
          icon: Icons.menu_book_rounded,
          label: sectionLabel,
          color: color,
        ),
        const SizedBox(height: 12),
        ...posts.map((post) => _pdfButton(
              post: post,
              isAr: isAr,
              color: color,
              langLabel: isAr ? 'عربي' : 'English',
              flagEmoji: isAr ? '🇸🇦' : '🇬🇧',
            )),
      ],
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _pdfButton({
    required PostModel post,
    required bool isAr,
    required Color color,
    required String langLabel,
    required String flagEmoji,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        shadowColor: color.withOpacity(0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openPdf(post),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded,
                      color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$flagEmoji  $langLabel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PDF Viewer Screen ────────────────────────────────────────────────────────

class _PdfViewerScreen extends StatefulWidget {
  final PostModel post;
  final Future<String> Function() getCacheDir;
  final ApiService api;
  final PdfCacheService pdfCache;

  const _PdfViewerScreen({
    required this.post,
    required this.getCacheDir,
    required this.api,
    required this.pdfCache,
  });

  @override
  State<_PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<_PdfViewerScreen> {
  Uint8List? _pdfBytes;
  bool _loading = true; // fetching the file
  bool _rendering = false; // still rasterizing some pages in the background
  String? _error;

  // Nullable placeholders: filled in as each page finishes rendering, so the
  // reader can start on page 1 without waiting for the whole document.
  List<Uint8List?> _pageImages = [];
  int _currentPage = 1; // 1-based
  int _totalPages = 0;

  final GlobalKey<PageFlipWidgetState> _flipKey = GlobalKey();

  // Search (page-level: finds which pages contain the text, then flips there)
  bool _showSearchBar = false;
  bool _searching = false;
  final TextEditingController _searchTextController = TextEditingController();
  List<int> _searchMatches = []; // 1-based page numbers
  int _searchMatchIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 1) Try the on-disk cache first. If a background prefetch (or an
      // earlier visit) already downloaded this PDF, we skip the network
      // entirely and open straight from disk — this is what makes the
      // viewer feel instant.
      final cached = await widget.pdfCache.readCachedBytes(widget.post.id);

      if (cached != null && PdfCacheService.looksLikePdf(cached)) {
        if (!mounted) return;
        setState(() {
          _pdfBytes = cached;
          _loading = false;
        });
        unawaited(_renderPages(cached));

        // 2) Quietly re-download in the background. If the server has a
        // newer version, swap it in and re-render — without ever blocking
        // the reader, who's already looking at the cached copy.
        unawaited(_refreshInBackground());
        return;
      }

      // No cache yet (first time opening this PDF) — fetch it live.
      final Uint8List bytes =
          await widget.api.fetchPdfBytes(widget.post.pdfUrl);

      if (!PdfCacheService.looksLikePdf(bytes)) {
        throw 'invalidPdf';
      }

      await widget.pdfCache.cacheBytes(widget.post.id, bytes);

      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _loading = false;
      });
      await _renderPages(bytes);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Re-downloads this PDF silently after it's already open and showing the
  /// cached copy. Only swaps content in (and re-rasterizes) if the fresh
  /// download actually differs from what was cached — otherwise it's a
  /// no-op and the reader never notices anything happened.
  Future<void> _refreshInBackground() async {
    try {
      final fresh = await widget.pdfCache.refreshInBackground(widget.post);
      if (fresh == null || !mounted) return; // unchanged, or failed — keep current view

      setState(() {
        _pdfBytes = fresh;
        _pageImages = [];
        _totalPages = 0;
        _currentPage = 1;
      });
      await _renderPages(fresh);
    } catch (_) {
      // Silent — the reader keeps looking at the still-valid cached copy.
    }
  }

  Future<void> _renderPages(Uint8List bytes) async {
    setState(() {
      _rendering = true;
    });
    try {
      // 1) Get the page count instantly — this only parses PDF structure,
      // it does not rasterize anything, so it's near-instant even for big
      // files. This lets the page counter and Move-to-page show up right
      // away instead of waiting for every page to render.
      final metaDoc = PdfDocument(inputBytes: bytes);
      final totalPages = metaDoc.pages.count;
      metaDoc.dispose();

      if (!mounted) return;
      setState(() {
        _totalPages = totalPages;
        _pageImages = List<Uint8List?>.filled(totalPages, null);
        _currentPage = 1;
      });

      // 2) Disk cache: if this exact PDF was already rendered before, load
      // the pages straight from disk instead of rasterizing again.
      final cacheDir = await widget.getCacheDir();
      final pagesDir =
          Directory('$cacheDir/pdf_pages_${widget.post.id}');
      final manifestFile = File('${pagesDir.path}/manifest.txt');

      if (await manifestFile.exists()) {
        final cachedCount =
            int.tryParse((await manifestFile.readAsString()).trim()) ?? -1;
        if (cachedCount == totalPages) {
          var cacheIntact = true;
          for (var i = 0; i < totalPages; i++) {
            final file = File('${pagesDir.path}/page_$i.png');
            if (!await file.exists()) {
              cacheIntact = false;
              break;
            }
            final png = await file.readAsBytes();
            if (!mounted) return;
            setState(() => _pageImages[i] = png);
          }
          if (cacheIntact) {
            if (!mounted) return;
            setState(() => _rendering = false);
            return;
          }
          // Cache was incomplete/corrupted — clear partial results and
          // fall through to a fresh render below.
          if (!mounted) return;
          setState(() {
            _pageImages = List<Uint8List?>.filled(totalPages, null);
          });
        }
      }

      // 3) No usable cache — rasterize page by page, showing each as soon
      // as it's ready, and writing it to disk for next time.
      await pagesDir.create(recursive: true);
      var index = 0;
      await for (final page in Printing.raster(bytes, dpi: 100)) {
        final png = await page.toPng();
        if (!mounted) return;
        setState(() => _pageImages[index] = png);
        // Fire-and-forget disk write so it doesn't block rendering the next page.
        unawaited(
            File('${pagesDir.path}/page_$index.png').writeAsBytes(png));
        index++;
      }
      await manifestFile.writeAsString(index.toString(), flush: true);

      if (!mounted) return;
      setState(() => _rendering = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'pdfRenderError: $e';
        _rendering = false;
      });
    }
  }

  void _goToPage(int oneBasedPage) {
    final target = oneBasedPage.clamp(1, _totalPages);
    _flipKey.currentState?.goToPage(target - 1);
    setState(() => _currentPage = target);
  }

  void _flipNext() {
    if (_currentPage >= _totalPages) return;
    _goToPage(_currentPage + 1);
  }

  void _flipPrevious() {
    if (_currentPage <= 1) return;
    _goToPage(_currentPage - 1);
  }

  Future<void> _startSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _pdfBytes == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _searchMatches = [];
      _searchMatchIndex = -1;
    });

    try {
      final matches = <int>[];
      final document = PdfDocument(inputBytes: _pdfBytes!);
      final extractor = PdfTextExtractor(document);
      final needle = trimmed.toLowerCase();
      for (var i = 0; i < document.pages.count; i++) {
        final text = extractor.extractText(startPageIndex: i, endPageIndex: i);
        if (text.toLowerCase().contains(needle)) {
          matches.add(i + 1);
        }
      }
      document.dispose();

      if (!mounted) return;
      setState(() {
        _searchMatches = matches;
        _searchMatchIndex = matches.isEmpty ? -1 : 0;
        _searching = false;
      });

      if (matches.isNotEmpty) {
        _goToPage(matches.first);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searchMatches = [];
        _searchMatchIndex = -1;
      });
    }
  }

  void _goToNextMatch() {
    if (_searchMatches.isEmpty) return;
    setState(() {
      _searchMatchIndex = (_searchMatchIndex + 1) % _searchMatches.length;
    });
    _goToPage(_searchMatches[_searchMatchIndex]);
  }

  void _goToPreviousMatch() {
    if (_searchMatches.isEmpty) return;
    setState(() {
      _searchMatchIndex =
          (_searchMatchIndex - 1 + _searchMatches.length) % _searchMatches.length;
    });
    _goToPage(_searchMatches[_searchMatchIndex]);
  }

  void _closeSearch() {
    setState(() {
      _showSearchBar = false;
      _searchMatches = [];
      _searchMatchIndex = -1;
      _searchTextController.clear();
    });
  }

  Future<void> _showMoveToPageDialog(bool isAr) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isAr ? 'الانتقال إلى صفحة' : 'Move to Page'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: isAr
                  ? 'رقم الصفحة (1 - $_totalPages)'
                  : 'Page number (1 - $_totalPages)',
            ),
            onSubmitted: (value) {
              final page = int.tryParse(value);
              Navigator.of(dialogContext).pop(page);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(controller.text);
                Navigator.of(dialogContext).pop(page);
              },
              child: Text(isAr ? 'الانتقال' : 'Go'),
            ),
          ],
        );
      },
    );

    if (result != null && result >= 1 && result <= _totalPages) {
      _goToPage(result);
    } else if (result != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'رقم صفحة غير صالح' : 'Invalid page number'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageProvider>().isArabic;
    final isArabicDoc = widget.post.languages.toLowerCase() == 'arabic';
    final ready = !_loading &&
        _error == null &&
        _pageImages.isNotEmpty &&
        _pageImages[0] != null;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade800,
        appBar: AppBar(
          backgroundColor: const Color(0xFF9A9B78),
          foregroundColor: Colors.white,
          elevation: 0,
          title: _showSearchBar
              ? TextField(
                  controller: _searchTextController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: isAr ? 'ابحث في المستند...' : 'Search document...',
                    hintStyle: const TextStyle(color: Colors.black),
                  ),
                  onSubmitted: _startSearch,
                )
              : Text(
                  widget.post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
          actions: [
            if (_showSearchBar) ...[
              if (_searching)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                )
              else if (_searchMatches.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: Text(
                      isAr
                          ? '${_searchMatchIndex + 1}/${_searchMatches.length} (صفحة ${_searchMatches[_searchMatchIndex]})'
                          : '${_searchMatchIndex + 1}/${_searchMatches.length} (pg ${_searchMatches[_searchMatchIndex]})',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                )
              else if (_searchTextController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      isAr ? 'لا نتائج' : 'No matches',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: isAr ? 'السابق' : 'Previous match',
                onPressed: _searchMatches.isEmpty ? null : _goToPreviousMatch,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: isAr ? 'التالي' : 'Next match',
                onPressed: _searchMatches.isEmpty ? null : _goToNextMatch,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: isAr ? 'إغلاق البحث' : 'Close search',
                onPressed: _closeSearch,
              ),
            ] else ...[
              if (_rendering)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white70),
                    ),
                  ),
                ),
              if (_totalPages > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Center(
                    child: Text(
                      '$_currentPage / $_totalPages',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
          ],
        ),
        body: _buildBody(isAr, isArabicDoc),
        bottomNavigationBar: ready ? _buildBottomBar(isAr) : null,
      ),
    );
  }

  Widget _buildBottomBar(bool isAr) {
    return BottomAppBar(
      color: const Color(0xFF9A9B78),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              tooltip: isAr ? 'الصفحة السابقة' : 'Previous page',
              onPressed: _currentPage > 1 ? _flipPrevious : null,
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: isAr ? 'بحث' : 'Search',
              onPressed: () {
                setState(() => _showSearchBar = true);
              },
            ),
            IconButton(
              icon: const Icon(Icons.find_in_page_outlined, color: Colors.white),
              tooltip: isAr ? 'الانتقال إلى صفحة' : 'Move to page',
              onPressed: () => _showMoveToPageDialog(isAr),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              tooltip: isAr ? 'الصفحة التالية' : 'Next page',
              onPressed: _currentPage < _totalPages ? _flipNext : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageWidget(Uint8List? imageBytes) {
    if (imageBytes == null) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Color(0xFF9A9B78)),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: Image.memory(imageBytes, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildBody(bool isAr, bool isArabicDoc) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF9A9B78)),
            const SizedBox(height: 16),
            Text(
              isAr ? 'جارٍ تحميل الملف...' : 'Loading PDF...',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red.shade200),
              const SizedBox(height: 16),
              Text(
                isAr ? 'فشل تحميل الملف' : 'Failed to Load PDF',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Only block on a full-screen spinner until page 1 specifically is
    // ready — the rest can keep rendering in the background while the
    // reader is already looking at page 1.
    final firstPageReady =
        _pageImages.isNotEmpty && _pageImages[0] != null;

    if (!firstPageReady) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF9A9B78)),
            const SizedBox(height: 16),
            Text(
              isAr ? 'جارٍ تجهيز الصفحات...' : 'Preparing pages...',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return PageFlipWidget(
      key: _flipKey,
      backgroundColor: Colors.grey.shade800,
      isRightSwipe: isArabicDoc,
      lastPage: Container(
        color: Colors.white,
        child: Center(
          child: Text(
            isAr ? 'نهاية المستند' : 'End of document',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
      ),
      children: [
        for (final imageBytes in _pageImages) _buildPageWidget(imageBytes),
      ],
    );
  }
}

// ─── Language Toggle ──────────────────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final LanguageProvider provider;
  const _LangToggle({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(
              label: 'EN',
              selected: !provider.isArabic,
              onTap: provider.setEnglish),
          _Chip(
              label: 'AR',
              selected: provider.isArabic,
              onTap: provider.setArabic),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected
                ? const Color(0xFF9A9B78)
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
