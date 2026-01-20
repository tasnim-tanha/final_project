import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import '../providers/recipes_provider.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _detailsController;
  String _category = 'General';
  String _imageUrl = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.recipe?.name ?? '');
    _detailsController = TextEditingController(
      text: widget.recipe?.details ?? '',
    );
    _category = widget.recipe?.category ?? 'General';
    _imageUrl = widget.recipe?.imageUrl ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final fileBytes = await pickedFile.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        await Supabase.instance.client.storage
            .from('recipe-images')
            .uploadBinary(fileName, fileBytes);

        setState(() {
          _imageUrl = Supabase.instance.client.storage
              .from('recipe-images')
              .getPublicUrl(fileName);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _save(WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final recipe = Recipe(
        id: widget.recipe?.id ?? 0,
        name: _nameController.text.trim(),
        details: _detailsController.text.trim(),
        imageUrl: _imageUrl,
        category: _category,
        userId: user.id,
      );

      final notifier = ref.read(recipesProvider.notifier);

      if (widget.recipe == null) {
        notifier.addRecipe(recipe);
      } else {
        notifier.updateRecipe(recipe);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              widget.recipe == null ? 'Add New Masterpiece' : 'Refine Recipe',
            ),
            backgroundColor: const Color(0xFF1E5631),
            foregroundColor: Colors.white,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Recipe Title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _detailsController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Cooking Instructions',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter instructions' : null,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: ['General', 'Breakfast', 'Lunch', 'Dinner']
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 25),

                GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : _imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(_imageUrl, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text("Add a Delicious Photo"),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _save(ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      widget.recipe == null ? 'Save Recipe' : 'Update Changes',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
