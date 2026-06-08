import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
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

  String? _pdfPath;
  bool _loading = false;
  String? _error;
  String? _loadedForLang;

  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPdf());
  }

  /// Returns the app's cache directory without using path_provider.
  Future<String> _getCacheDir() async {
    final String path =
        await _platform.invokeMethod('getCacheDir');
    return path;
  }

  Future<void> _loadPdf() async {
    if (!mounted) return;
    final lang = context.read<LanguageProvider>().pdfLang;

    if (_loadedForLang == lang && _pdfPath != null) return;

    setState(() {
      _loading = true;
      _error = null;
      _pdfPath = null;
      _currentPage = 0;
      _totalPages = 0;
    });

    try {
      // 1. Download bytes
      final Uint8List bytes = await _api.fetchPdf(lang);

      // 2. Validate it's a real PDF (%PDF magic bytes)
      if (bytes.length < 4 ||
          bytes[0] != 0x25 || // %
          bytes[1] != 0x50 || // P
          bytes[2] != 0x44 || // D
          bytes[3] != 0x46) { // F
        throw 'invalidPdf';
      }

      // 3. Write to cache (no path_provider needed)
      final cacheDir = await _getCacheDir();
      final file = File('$cacheDir/doc_$lang.pdf');
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      setState(() {
        _pdfPath = file.path;
        _loadedForLang = lang;
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
            child: Text(isAr ? 'خروج' : 'Logout'),
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

  String _friendlyError(String? err, bool isAr) {
    if (err == null) return isAr ? 'خطأ غير معروف' : 'Unknown error';
    if (err.contains('serverError:500')) {
      return isAr
          ? 'خطأ في الخادم (500). ملف اللغة الإنجليزية غير موجود على الخادم.'
          : 'Server error (500). The English PDF may be missing on the server.';
    }
    if (err.contains('serverError:404')) {
      return isAr ? 'الملف غير موجود على الخادم.' : 'PDF not found on server.';
    }
    if (err == 'invalidPdf') {
      return isAr
          ? 'الملف المستلم ليس PDF صالح.'
          : 'Received file is not a valid PDF.';
    }
    if (err == 'emptyResponse') {
      return isAr ? 'الخادم أرسل ملفاً فارغاً.' : 'Server returned an empty file.';
    }
    if (err == 'timeoutError') {
      return isAr ? 'انتهت مهلة الاتصال. حاول مرة أخرى.' : 'Connection timed out. Try again.';
    }
    if (err.contains('network') || err.contains('Network') || err.contains('socket')) {
      return isAr
          ? 'تعذّر الاتصال بالإنترنت. تحقق من اتصالك.'
          : 'No internet connection. Check your network.';
    }
    return isAr ? 'فشل تحميل الملف' : 'Failed to load PDF';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final isAr = lang.isArabic;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _loadedForLang != lang.pdfLang) _loadPdf();
    });

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
            _buildUserBanner(auth, isAr, lang.pdfLang),
            Expanded(child: _buildPdfArea(isAr)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBanner(AuthProvider auth, bool isAr, String lang) {
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  auth.user?.email ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  lang.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfArea(bool isAr) {
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
              Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                isAr ? 'فشل تحميل الملف' : 'Failed to Load PDF',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _friendlyError(_error, isAr),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, height: 1.5),
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

    return Column(
      children: [
        if (_totalPages > 0)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: Center(
              child: Text(
                isAr
                    ? 'الصفحة ${_currentPage + 1} من $_totalPages'
                    : 'Page ${_currentPage + 1} of $_totalPages',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        Expanded(
          child: PDFView(
            filePath: _pdfPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            fitPolicy: FitPolicy.BOTH,
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
          ),
        ),
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
          _Chip(label: 'EN', selected: !provider.isArabic, onTap: provider.setEnglish),
          _Chip(label: 'AR', selected: provider.isArabic, onTap: provider.setArabic),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? const Color(0xFF1565C0) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
