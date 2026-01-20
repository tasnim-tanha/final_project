class Recipe {
  final int id;
  final String name;
  final String details;
  final String imageUrl;
  final String category;
  final String userId;

  Recipe({
    required this.id,
    required this.name,
    required this.details,
    required this.imageUrl,
    required this.category,
    required this.userId,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      details: json['details'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'General',
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': details,
      'image_url': imageUrl,
      'category': category,
      'user_id': userId,
    };
  }
}
