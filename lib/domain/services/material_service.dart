import 'package:moamri_accounting/core/errors/app_error.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/items/my_material_item.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/utils/result.dart';

/// Material Service
///
/// Contains business logic for material operations.
/// This service acts as a mediator between the presentation layer
/// and the data layer (repositories).
class MaterialService {
  /// Calculate available quantity including larger materials
  ///
  /// This method recursively calculates the total available quantity
  /// by considering quantities from larger unit materials.
  static Future<Result<double>> calculateAvailableQuantity(
    MyMaterial material,
  ) async {
    try {
      // Get the current material with updated quantity
      final currentMaterial = await MyMaterialsDatabase.getMaterialByID(material.id!, null);
      
      // Build the material item tree
      final materialItem = await MyMaterialsDatabase.getMyMaterialItem(currentMaterial);
      
      if (materialItem == null) {
        return Result.success(0.0);
      }

      double availableQuantity = materialItem.material.quantity;

      // Traverse larger materials to calculate additional available quantity
      var currentItem = materialItem;
      while (currentItem?.largerMaterial != null) {
        final largerMaterial = currentItem!.largerMaterial!.material;
        var largerQuantity = largerMaterial.quantity;

        // Calculate the equivalent quantity
        var equivalentQuantity =
            largerQuantity * currentItem.material.quantitySupplied!;

        // Traverse smaller units until reaching the original unit
        var smallerItem = currentItem.smallerMaterial;
        while (smallerItem != null) {
          equivalentQuantity *=
              smallerItem.material.quantitySupplied!;
          smallerItem = smallerItem.smallerMaterial;
        }

        availableQuantity += equivalentQuantity;

        // Move to the next larger material
        currentItem.largerMaterial?.smallerMaterial = currentItem;
        currentItem = currentItem.largerMaterial!;
      }

      return Result.success(availableQuantity);
    } catch (e) {
      return Result.failure(
        'فشل في حساب الكمية المتوفرة',
        exception: e,
      );
    }
  }

  /// Check if material has sufficient stock for the requested quantity
  static Future<Result<bool>> hasSufficientStock(
    MyMaterial material,
    double requestedQuantity,
  ) async {
    try {
      final availableResult = await calculateAvailableQuantity(material);
      
      return availableResult.map((available) => available >= requestedQuantity);
    } catch (e) {
      return Result.failure(
        'فشل في التحقق من الكمية المتوفرة',
        exception: e,
      );
    }
  }

  /// Validate material before insertion
  static Result<bool> validateForInsert(MyMaterial material) {
    // Check required fields
    if (material.name.isEmpty) {
      return Result.failure('اسم المادة مطلوب');
    }
    if (material.barcode.isEmpty) {
      return Result.failure('باركود المادة مطلوب');
    }
    if (material.unit.isEmpty) {
      return Result.failure('وحدة المادة مطلوب');
    }
    if (material.costPrice < 0) {
      return Result.failure('سعر الشراء لا يمكن أن يكون سالباً');
    }
    if (material.salePrice < 0) {
      return Result.failure('سعر البيع لا يمكن أن يكون سالباً');
    }

    // Validate larger material relationship
    if (material.largerMaterialID != null && material.quantitySupplied == null) {
      return Result.failure('يجب تحديد الكمية المزودة من المادة الأكبر');
    }
    if (material.quantitySupplied != null && material.quantitySupplied! <= 0) {
      return Result.failure('الكمية المزودة يجب أن تكون أكبر من صفر');
    }

    return Result.success(true);
  }

  /// Validate material before update
  static Result<bool> validateForUpdate(
    MyMaterial material,
    MyMaterial oldMaterial,
  ) {
    // First do insert validation
    final insertValidation = validateForInsert(material);
    if (insertValidation.isFailure) {
      return insertValidation;
    }

    // Check if ID is set
    if (material.id == null) {
      return Result.failure('معرف المادة مطلوب للتحديث');
    }

    return Result.success(true);
  }

  /// Check if material can be deleted
  ///
  /// A material cannot be deleted if:
  /// - It has smaller materials referencing it
  /// - It has been used in invoices
  static Future<Result<bool>> canDelete(int materialId) async {
    try {
      final isDeletable = await MyMaterialsDatabase.isMaterialDeletable(materialId);
      return Result.success(isDeletable);
    } catch (e) {
      return Result.failure(
        'فشل في التحقق من إمكانية الحذف',
        exception: e,
      );
    }
  }

  /// Add material with validation
  static Future<Result<int>> addMaterial(
    MyMaterial material,
    User actionBy,
  ) async {
    // Validate
    final validation = validateForInsert(material);
    if (validation.isFailure) {
      return Result.failure(validation.message!);
    }

    try {
      final id = await MyMaterialsDatabase.insertMaterial(material, actionBy);
      return Result.success(id);
    } catch (e) {
      return Result.failure(
        'فشل في إضافة المادة',
        exception: e,
      );
    }
  }

  /// Update material with validation
  static Future<Result<void>> updateMaterial(
    MyMaterial material,
    MyMaterial oldMaterial,
    User actionBy,
  ) async {
    // Validate
    final validation = validateForUpdate(material, oldMaterial);
    if (validation.isFailure) {
      return Result.failure(validation.message!);
    }

    try {
      await MyMaterialsDatabase.updateMaterial(material, oldMaterial, actionBy);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        'فشل في تحديث المادة',
        exception: e,
      );
    }
  }

  /// Delete material with checks
  static Future<Result<void>> deleteMaterial(
    MyMaterial material,
    User actionBy,
  ) async {
    if (material.id == null) {
      return Result.failure('معرف المادة مطلوب للحذف');
    }

    // Check if can delete
    final canDeleteResult = await canDelete(material.id!);
    if (canDeleteResult.isFailure) {
      return canDeleteResult.map((_) => null);
    }

    if (!canDeleteResult.data) {
      return Result.failure(
        BusinessError.materialNotDeletable(material.name).message,
      );
    }

    try {
      await MyMaterialsDatabase.deleteMaterial(material, actionBy);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        'فشل في حذف المادة',
        exception: e,
      );
    }
  }

  /// Get material by barcode
  static Future<Result<MyMaterial?>> getByBarcode(String barcode) async {
    if (barcode.isEmpty) {
      return Result.success(null);
    }

    try {
      final material = await MyMaterialsDatabase.getMaterialByBarcode(barcode);
      return Result.success(material);
    } catch (e) {
      return Result.failure(
        'فشل في البحث عن المادة',
        exception: e,
      );
    }
  }

  /// Get material by ID
  static Future<Result<MyMaterial?>> getById(int id) async {
    try {
      final material = await MyMaterialsDatabase.getMaterialByID(id, null);
      return Result.success(material);
    } catch (e) {
      return Result.failure(
        'فشل في الحصول على المادة',
        exception: e,
      );
    }
  }

  /// Search materials
  static Future<Result<List<MyMaterial>>> search(
    String searchText, {
    int? excludeId,
    int limit = 10,
  }) async {
    if (searchText.trim().isEmpty) {
      return Result.success([]);
    }

    try {
      final materials = await MyMaterialsDatabase.getMaterialsSuggestions(
        searchText,
        excludeId,
      );
      return Result.success(materials);
    } catch (e) {
      return Result.failure(
        'فشل في البحث عن المواد',
        exception: e,
      );
    }
  }

  /// Get all categories
  static Future<Result<List<String>>> getCategories() async {
    try {
      final categories = await MyMaterialsDatabase.getMaterialsCategories();
      return Result.success(categories);
    } catch (e) {
      return Result.failure(
        'فشل في الحصول على التصنيفات',
        exception: e,
      );
    }
  }

  /// Generate new barcode
  static Future<Result<String>> generateBarcode() async {
    try {
      final barcode = await MyMaterialsDatabase.generateMaterialBarcode();
      return Result.success(barcode);
    } catch (e) {
      return Result.failure(
        'فشل في توليد الباركود',
        exception: e,
      );
    }
  }

  /// Get material item with relationships
  static Future<Result<MyMaterialItem?>> getMaterialItem(
    MyMaterial material,
  ) async {
    try {
      final item = await MyMaterialsDatabase.getMyMaterialItem(material);
      return Result.success(item);
    } catch (e) {
      return Result.failure(
        'فشل في الحصول على تفاصيل المادة',
        exception: e,
      );
    }
  }

  /// Check if one material is larger unit of another
  static Future<Result<bool>> isLargerUnitOf(
    MyMaterial material,
    int? otherMaterialId,
  ) async {
    if (otherMaterialId == null) {
      return Result.success(false);
    }

    try {
      final result = await MyMaterialsDatabase.isMaterialLargerToMaterialId(
        material,
        otherMaterialId,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        'فشل في التحقق من علاقة المواد',
        exception: e,
      );
    }
  }
}
