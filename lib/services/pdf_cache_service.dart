import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../models/post_model.dart';
import 'api_service.dart';

/// Handles disk caching of raw PDF bytes so the viewer can open instantly
/// from a previous download instead of waiting on the network every time.
///
/// Responsibilities:
///  - `prefetchMissing`: called when the post list loads. Downloads any PDF
///    that has never been cached before, in the background, with a small
///    concurrency limit so it doesn't flood the network or the UI thread.
///  - `readCachedBytes`: instant local read used by the viewer to open a
///    PDF immediately from whatever is already on disk.
///  - `refreshInBackground`: re-downloads a single PDF (used right after the
///    viewer opens from cache) and, only if the content actually changed,
///    overwrites the cache and wipes the stale rendered-page cache so the
///    next open re-rasterizes the new content.
class PdfCacheService {
  final Future<String> Function() getCacheDir;
  final ApiService api;

  PdfCacheService({required this.getCacheDir, required this.api});

  static const int _maxConcurrent = 2;
  int _activeDownloads = 0;
  final List<Future<void> Function()> _queue = [];
  final Set<int> _inFlight = {};

  Future<Directory> _rawDir(String cacheDir) async {
    final dir = Directory('$cacheDir/pdf_raw');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _rawFile(int postId) async {
    final cacheDir = await getCacheDir();
    final dir = await _rawDir(cacheDir);
    return File('${dir.path}/pdf_$postId.pdf');
  }

  /// Directory where rasterized page PNGs for [postId] live. Exposed so the
  /// viewer (which already owns that rendering logic) can wipe it when the
  /// underlying PDF changes.
  Future<Directory> pageCacheDir(int postId) async {
    final cacheDir = await getCacheDir();
    return Directory('$cacheDir/pdf_pages_$postId');
  }

  Future<Uint8List?> readCachedBytes(int postId) async {
    final file = await _rawFile(postId);
    if (await file.exists()) {
      try {
        return await file.readAsBytes();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> cacheBytes(int postId, Uint8List bytes) async {
    final file = await _rawFile(postId);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> clearPageCache(int postId) async {
    final dir = await pageCacheDir(postId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static bool looksLikePdf(Uint8List bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  static bool bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Warms the cache for any post that has never been downloaded before.
  /// Safe to call every time the post list loads — already-cached posts are
  /// skipped instantly, so repeat calls are cheap. Best-effort: failures are
  /// swallowed since the viewer will just fall back to a live fetch.
  void prefetchMissing(List<PostModel> posts) {
    for (final post in posts) {
      if (_inFlight.contains(post.id)) continue;
      _enqueue(post.id, () async {
        final cached = await readCachedBytes(post.id);
        if (cached != null) return; // already warm
        try {
          final bytes = await api.fetchPdfBytes(post.pdfUrl);
          if (looksLikePdf(bytes)) {
            await cacheBytes(post.id, bytes);
          }
        } catch (_) {
          // Best-effort warmup only.
        }
      });
    }
  }

  /// Re-downloads a single post's PDF and, only if it differs from what's
  /// cached, overwrites the cache and clears the stale rendered pages.
  /// Returns the fresh bytes if the content changed, otherwise null.
  Future<Uint8List?> refreshInBackground(PostModel post) async {
    if (_inFlight.contains(post.id)) return null;
    _inFlight.add(post.id);
    try {
      final fresh = await api.fetchPdfBytes(post.pdfUrl);
      if (!looksLikePdf(fresh)) return null;
      final old = await readCachedBytes(post.id);
      final changed = old == null || !bytesEqual(old, fresh);
      await cacheBytes(post.id, fresh);
      if (changed) {
        await clearPageCache(post.id);
        return fresh;
      }
      return null;
    } catch (_) {
      return null; // keep serving the last known-good cache
    } finally {
      _inFlight.remove(post.id);
    }
  }

  void _enqueue(int postId, Future<void> Function() task) {
    _inFlight.add(postId);
    _queue.add(() async {
      try {
        await task();
      } finally {
        _inFlight.remove(postId);
      }
    });
    _pump();
  }

  void _pump() {
    while (_activeDownloads < _maxConcurrent && _queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      _activeDownloads++;
      // ignore: unawaited_futures
      task().whenComplete(() {
        _activeDownloads--;
        _pump();
      });
    }
  }
}
