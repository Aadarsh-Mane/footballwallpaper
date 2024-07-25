class Ad {
  final String imageUrl;
  final String title;

  Ad({required this.imageUrl, required this.title});

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      imageUrl: json['urlimage'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
