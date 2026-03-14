import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/utils/result.dart';
import 'package:moamri_accounting/domain/services/material_service.dart';

/// Inventory Controller
///
/// Manages inventory state and database operations
class InventoryController extends GetxController {
  // State
  RxList<MyMaterial> materials = <MyMaterial>[].obs;
  RxList<String> categories = <String>['الكل'].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxString errorMessage = ''.obs;
  RxString searchQuery = ''.obs;
  RxString selectedCategory = 'الكل'.obs;
  RxInt currentPage = 0.obs;
  RxInt totalMaterials = 0.obs;
  RxBool hasMore = true.obs;

  // View mode
  RxBool isGridView = true.obs;

  // User reference
  User? currentUser;

  @override
  void onInit() {
    super.onInit();
    // Get current user from main controller
    try {
      final mainController = Get.find<dynamic>();
      currentUser = mainController.currentUser?.value;
    } catch (_) {}
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Load categories
      final cats = await MaterialService.getCategories();
      if (cats.isSuccess) {
        categories.value = ['الكل', ...cats.data!];
      }

      // Load materials count
      final count = await MyMaterialsDatabase.getMaterialsCount();
      totalMaterials.value = count;

      // Load first page
      await loadMaterialsPage(0);

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل البيانات: $e';
      isLoading.value = false;
    }
  }

  /// Load materials page
  Future<void> loadMaterialsPage(int page) async {
    try {
      final newMaterials = await MyMaterialsDatabase.getMaterials(
        page,
        category: selectedCategory.value == 'الكل' ? null : selectedCategory.value,
      );

      if (page == 0) {
        materials.value = newMaterials;
      } else {
        materials.addAll(newMaterials);
      }

      currentPage.value = page;
      hasMore.value = newMaterials.isNotEmpty &&
          materials.length < totalMaterials.value;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل المواد: $e';
    }
  }

  /// Load more materials (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    await loadMaterialsPage(currentPage.value + 1);
    isLoadingMore.value = false;
  }

  /// Search materials
  Future<void> searchMaterials(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      await loadMaterialsPage(0);
      return;
    }

    isLoading.value = true;
    try {
      final results = await MyMaterialsDatabase.getSearchedMaterials(0, query);
      materials.value = results;
      hasMore.value = false;
    } catch (e) {
      errorMessage.value = 'فشل في البحث: $e';
    }
    isLoading.value = false;
  }

  /// Filter by category
  Future<void> filterByCategory(String category) async {
    selectedCategory.value = category;
    currentPage.value = 0;
    await loadMaterialsPage(0);
  }

  /// Add new material
  Future<Result<int>> addMaterial(MyMaterial material) async {
    if (currentUser == null) {
      return Result.failure('المستخدم غير مسجل الدخول');
    }

    final result = await MaterialService.addMaterial(material, currentUser!);
    if (result.isSuccess) {
      await loadInitialData();
    }
    return result;
  }

  /// Update material
  Future<Result<void>> updateMaterial(MyMaterial material, MyMaterial oldMaterial) async {
    if (currentUser == null) {
      return Result.failure('المستخدم غير مسجل الدخول');
    }

    final result = await MaterialService.updateMaterial(material, oldMaterial, currentUser!);
    if (result.isSuccess) {
      await loadInitialData();
    }
    return result;
  }

  /// Delete material
  Future<Result<void>> deleteMaterial(MyMaterial material) async {
    if (currentUser == null) {
      return Result.failure('المستخدم غير مسجل الدخول');
    }

    final result = await MaterialService.deleteMaterial(material, currentUser!);
    if (result.isSuccess) {
      materials.remove(material);
    }
    return result;
  }

  /// Get low stock materials
  List<MyMaterial> getLowStockMaterials({int threshold = 10}) {
    return materials.where((m) => m.quantity > 0 && m.quantity <= threshold).toList();
  }

  /// Get out of stock materials
  List<MyMaterial> getOutOfStockMaterials() {
    return materials.where((m) => m.quantity <= 0).toList();
  }

  /// Calculate total inventory value
  double getTotalInventoryValue() {
    return materials.fold<double>(0, (sum, m) => sum + (m.costPrice * m.quantity));
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadInitialData();
  }

  /// Toggle view mode
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }
}
