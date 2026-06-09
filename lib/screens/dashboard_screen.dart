import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _platform =
      MethodChannel('com.example.flutter_application_1/paths');

  final ApiService _api = ApiService();

  // Posts state
  List<PostModel> _posts = [];
  bool _postsLoading = false;
  String? _postsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPosts());
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
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            isAr ? 'لوحة التحكم' : 'Dashboard',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: _LangToggle(provider: lang),
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
            Expanded(
              child: _buildBody(
                isAr: isAr,
                posts: visiblePosts,
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
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(Icons.person, color: Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'مرحباً، ${auth.user?.firstName ?? ''}'
                      : 'Welcome, ${auth.user?.firstName ?? ''}',
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
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userAge.toUpperCase().replaceAll('_', ' '),
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

  Widget _buildBody({
    required bool isAr,
    required List<PostModel> posts,
  }) {
    if (_postsLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1565C0)),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
            ],
          ),
        ),
      );
    }

    final color =
        isAr ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);
    final sectionLabel =
        isAr ? 'الكتب العربية' : 'English Books';

    return ListView(
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

  const _PdfViewerScreen({
    required this.post,
    required this.getCacheDir,
    required this.api,
  });

  @override
  State<_PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<_PdfViewerScreen> {
  String? _pdfPath;
  bool _loading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Uint8List bytes =
          await widget.api.fetchPdfBytes(widget.post.pdfUrl);

      // Validate PDF magic bytes
      if (bytes.length < 4 ||
          bytes[0] != 0x25 ||
          bytes[1] != 0x50 ||
          bytes[2] != 0x44 ||
          bytes[3] != 0x46) {
        throw 'invalidPdf';
      }

      final cacheDir = await widget.getCacheDir();
      final file =
          File('$cacheDir/post_${widget.post.id}.pdf');
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      setState(() {
        _pdfPath = file.path;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr =
        context.watch<LanguageProvider>().isArabic;
    final isArabicDoc =
        widget.post.languages.toLowerCase() == 'arabic';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.post.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_totalPages > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  isAr
                      ? '${_currentPage + 1} / $_totalPages'
                      : '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
        body: _buildBody(isAr, isArabicDoc),
      ),
    );
  }

  Widget _buildBody(bool isAr, bool isArabicDoc) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1565C0)),
            const SizedBox(height: 16),
            Text(
              isAr ? 'جارٍ تحميل الملف...' : 'Loading PDF...',
              style: TextStyle(color: Colors.grey.shade600),
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
                  size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                isAr ? 'فشل تحميل الملف' : 'Failed to Load PDF',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
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

    if (_pdfPath == null) return const SizedBox.shrink();

    return PDFView(
      filePath: _pdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      fitPolicy: FitPolicy.BOTH,
      // Arabic PDFs are typically RTL — render from last page first
      defaultPage: isArabicDoc ? (_totalPages > 0 ? _totalPages - 1 : 0) : 0,
      onRender: (pages) {
        if (mounted) setState(() => _totalPages = pages ?? 0);
      },
      onPageChanged: (page, total) {
        if (mounted) {
          setState(() {
            _currentPage = page ?? 0;
            _totalPages = total ?? 0;
          });
        }
      },
      onError: (error) {
        if (mounted) setState(() => _error = 'pdfRenderError: $error');
      },
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
                ? const Color(0xFF1565C0)
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
