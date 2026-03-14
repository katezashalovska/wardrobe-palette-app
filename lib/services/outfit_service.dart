import '../models/clothing_item.dart';

class OutfitSuggestion {
  final List<ClothingItem> items;
  final String description;

  OutfitSuggestion({required this.items, required this.description});
}

class OutfitService {
  static OutfitSuggestion? suggestOutfit(List<ClothingItem> wardrobe) {
    if (wardrobe.isEmpty) return null;

    final tops = wardrobe.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = wardrobe.where((i) => i.category == ClothingCategory.bottoms).toList();

    if (tops.isEmpty || bottoms.isEmpty) return null;

    // Simple matching: pick the first of each for now
    // In a real app, this would use color theory (complementary/analogous)
    return OutfitSuggestion(
      items: [tops.first, bottoms.first],
      description: "A classic look combining your favorite ${tops.first.category.name} and ${bottoms.first.category.name}.",
    );
  }
}
