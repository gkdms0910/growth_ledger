import 'package:flutter/material.dart';
import 'package:growth_ledger/services/storage_service.dart'; // Assuming StorageService can handle categories

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final StorageService _storageService = StorageService();
  List<String> _categories = [];
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Assuming StorageService has a method to read categories
    // For now, let's use a placeholder or default categories
    // In a real app, this would read from persistent storage
    final storedCategories = await _storageService.readCategories(); // This method needs to be implemented
    setState(() {
      _categories = storedCategories.isEmpty ? ['General', 'Health', 'Finance', 'Learning', 'Personal Growth'] : storedCategories;
    });
  }

  void _addCategory() {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      setState(() {
        _categories.add(newCategory);
        _newCategoryController.clear();
      });
      _storageService.writeCategories(_categories); // This method needs to be implemented
    }
  }

  void _deleteCategory(String category) {
    setState(() {
      _categories.remove(category);
    });
    _storageService.writeCategories(_categories); // This method needs to be implemented
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: const InputDecoration(
                      labelText: '새 카테고리 추가',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteCategory(category),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
