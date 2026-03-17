import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/items/my_material_item.dart';
import 'package:moamri_accounting/utils/result.dart';

/// Material Repository Interface
///
/// Defines the contract for material data operations.
/// This abstraction allows for easy testing and future changes
/// to the data source (e.g., switching from SQLite to a remote API).
abstract class MaterialRepository {
  /// Get a material by its barcode
  Future<Result<MyMaterial?>> getByBarcode(String barcode);

  /// Get a material by its ID
  Future<Result<MyMaterial?>> getById(int id);

  /// Get all materials with pagination
  Future<Result<List<MyMaterial>>> getMaterials({
    required int page,
    String? category,
    String? orderBy,
    String? dir,
  });

  /// Get materials count
  Future<Result<int>> getMaterialsCount({
    String? category,
    String? searchedText,
  });

  /// Search for materials
  Future<Result<List<MyMaterial>>> searchMaterials(
    String searchText, {
    int limit = 40,
    int? excludeId,
  });

  /// Get all categories
  Future<Result<List<String>>> getCategories();

  /// Get materials by category
  Future<Result<List<MyMaterial>>> getByCategory(String category);

  /// Insert a new material
  Future<Result<int>> insert(MyMaterial material, User actionBy);

  /// Update an existing material
  Future<Result<void>> update(
      MyMaterial material, MyMaterial oldMaterial, User actionBy);

  /// Delete a material
  Future<Result<void>> delete(MyMaterial material, User actionBy);

  /// Check if a material can be deleted
  Future<Result<bool>> isDeletable(int materialId);

  /// Generate a new barcode
  Future<Result<String>> generateBarcode();

  /// Get material item with larger/smaller relationships
  Future<Result<MyMaterialItem?>> getMaterialItem(MyMaterial material);

  /// Get available quantity considering larger materials
  Future<Result<double>> getAvailableQuantity(MyMaterial material);

  /// Supply material quantity from larger materials
  Future<Result<void>> supplyFromLargerMaterials(
      MyMaterial material, double requiredQuantity);

  /// Search for category suggestions
  Future<Result<List<String>>> searchCategories(String text);

  /// Search for unit suggestions
  Future<Result<List<String>>> searchUnits(String text);

  /// Get all materials grouped by category
  Future<Result<Map<String, List<MyMaterial>>>> getAllGroupedByCategory({
    String? category,
    String? orderBy,
    String? dir,
  });
}
