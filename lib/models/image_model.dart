class ImageModel {
  final String id;
  final String name;
  ImageModel({required this.id, required this.name});
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
