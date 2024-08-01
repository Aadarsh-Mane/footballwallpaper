class Ad {
  final String id;
  final String imageUrl;
  final String title;
  final String description;

  Ad({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}
