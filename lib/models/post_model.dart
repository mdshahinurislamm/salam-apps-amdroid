class PostModel {
  final int id;
  final String title;
  final String slug;
  final String languages; // "english" or "arabic"
  final String image;     // relative path e.g. "posts/abc.pdf"
  final String type;      // "group_a", "group_b", etc.
  final bool isPublished;

  PostModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.languages,
    required this.image,
    required this.type,
    required this.isPublished,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      languages: json['languages']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isPublished: json['is_published'] == true || json['is_published'] == 1,
    );
  }

  /// Full URL to download the PDF.
  /// The Laravel storage URL convention: /storage/<image>
  String get pdfUrl =>
      'https://larapress.org/salam/storage/${image}';
}