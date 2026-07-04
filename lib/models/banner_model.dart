class BannerModel {
  final int id;
  final String name;
  final String image; // relative path e.g. "banners/abc.jpg"

  BannerModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  /// Full URL to the banner image.
  /// Laravel storage URL convention: /storage/<image>
  String get imageUrl => 'https://larapress.org/salam/storage/$image';
}
