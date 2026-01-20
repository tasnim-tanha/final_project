import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

final recipesProvider =
    StateNotifierProvider<RecipesNotifier, AsyncValue<List<Recipe>>>((ref) {
      return RecipesNotifier();
    });

class RecipesNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  RecipesNotifier() : super(const AsyncValue.loading()) {
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    state = const AsyncValue.loading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final response = await Supabase.instance.client
          .from('recipe')
          .select()
          .eq('user_id', user!.id);
      final recipes = response.map((json) => Recipe.fromJson(json)).toList();
      state = AsyncValue.data(recipes);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    await Supabase.instance.client.from('recipe').insert(recipe.toJson());
    fetchRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await Supabase.instance.client
          .from('recipe')
          .update({
            'name': recipe.name,
            'details': recipe.details,
            'category': recipe.category,
            'image_url': recipe.imageUrl,
          })
          .eq('id', recipe.id);
      fetchRecipes();
    } catch (e) {
      print("Update error: $e");
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      await Supabase.instance.client.from('recipe').delete().eq('id', id);
      fetchRecipes();
    } catch (e) {
      print("Delete error: $e");
    }
  }
}
