import 'package:moamri_accounting/core/errors/app_error.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/items/customer_debt_item.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/utils/result.dart';

/// Customer Service
///
/// Contains business logic for customer operations.
class CustomerService {
  /// Validate customer before insertion
  static Result<bool> validateForInsert(Customer customer) {
    // Check required fields
    if (customer.name.isEmpty) {
      return Result.failure('اسم العميل مطلوب');
    }

    // Validate phone format if provided
    if (customer.phone.isNotEmpty) {
      // Basic phone validation - can be enhanced
      final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
      if (!phoneRegex.hasMatch(customer.phone)) {
        return Result.failure('صيغة رقم الهاتف غير صحيحة');
      }
    }

    return Result.success(true);
  }

  /// Validate customer before update
  static Result<bool> validateForUpdate(
    Customer customer,
    Customer oldCustomer,
  ) {
    // First do insert validation
    final insertValidation = validateForInsert(customer);
    if (insertValidation.isFailure) {
      return insertValidation;
    }

    // Check if ID is set
    if (customer.id == null) {
      return Result.failure('معرف العميل مطلوب للتحديث');
    }

    return Result.success(true);
  }

  /// Check if customer can be deleted
  ///
  /// A customer cannot be deleted if they have debts
  static Future<Result<bool>> canDelete(int customerId) async {
    try {
      final isDeletable = await CustomersDatabase.isCustomerDeletable(customerId);
      return Result.success(isDeletable);
    } catch (e) {
      return Result.failure(
        'فشل في التحقق من إمكانية الحذف',
        exception: e,
      );
    }
  }

  /// Add customer with validation
  static Future<Result<int>> addCustomer(
    Customer customer,
    User actionBy,
  ) async {
    // Validate
    final validation = validateForInsert(customer);
    if (validation.isFailure) {
      return Result.failure(validation.message!);
    }

    try {
      final id = await CustomersDatabase.insertCustomer(customer, actionBy);
      return Result.success(id);
    } catch (e) {
      return Result.failure(
        'فشل في إضافة العميل',
        exception: e,
      );
    }
  }

  /// Update customer with validation
  static Future<Result<void>> updateCustomer(
    Customer customer,
    Customer oldCustomer,
    User actionBy,
  ) async {
    // Validate
    final validation = validateForUpdate(customer, oldCustomer);
    if (validation.isFailure) {
      return Result.failure(validation.message!);
    }

    try {
      await CustomersDatabase.updateCustomer(customer, oldCustomer, actionBy);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        'فشل في تحديث العميل',
        exception: e,
      );
    }
  }

  /// Delete customer with checks
  static Future<Result<void>> deleteCustomer(
    Customer customer,
    User actionBy,
  ) async {
    if (customer.id == null) {
      return Result.failure('معرف العميل مطلوب للحذف');
    }

    // Check if can delete
    final canDeleteResult = await canDelete(customer.id!);
    if (canDeleteResult.isFailure) {
      return canDeleteResult.map((_) => null);
    }

    if (!canDeleteResult.data) {
      return Result.failure(
        BusinessError.customerNotDeletable(customer.name).message,
      );
    }

    try {
      await CustomersDatabase.deleteCustomer(customer, actionBy);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        'فشل في حذف العميل',
        exception: e,
      );
    }
  }

  /// Get customer by ID
  static Future<Result<Customer?>> getById(int? id) async {
    if (id == null) {
      return Result.success(null);
    }

    try {
      final customer = await CustomersDatabase.getCustomerByID(id);
      return Result.success(customer);
    } catch (e) {
      return Result.failure(
        'فشل في الحصول على العميل',
        exception: e,
      );
    }
  }

  /// Search customers
  static Future<Result<List<Customer>>> search(String searchText) async {
    if (searchText.trim().isEmpty) {
      return Result.success([]);
    }

    try {
      final customers = await CustomersDatabase.getCustomersSuggestions(searchText);
      return Result.success(customers);
    } catch (e) {
      return Result.failure(
        'فشل في البحث عن العملاء',
        exception: e,
      );
    }
  }

  /// Get customers with debts
  static Future<Result<List<CustomerDebtItem>>> getCustomersWithDebts({
    required int page,
    String? orderBy,
    String? dir,
  }) async {
    try {
      final customers = await CustomersDatabase.getCustomersWithDebts(
        // mainController would be passed in real implementation
        null as dynamic,
        page,
        orderBy: orderBy,
        dir: dir,
      );
      return Result.success(customers);
    } catch (e) {
      return Result.failure(
        'فشل في الحصول على قائمة العملاء',
        exception: e,
      );
    }
  }

  /// Get customer count
  static Future<Result<int>> getCount({String? searchedText}) async {
    try {
      final count = await CustomersDatabase.getCustomersCount(
        searchedText: searchedText,
      );
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        'فشل في الحصول على عدد العملاء',
        exception: e,
      );
    }
  }

  /// Check if customer has debts
  static Future<Result<bool>> hasDebts(int customerId) async {
    try {
      final isDeletable = await CustomersDatabase.isCustomerDeletable(customerId);
      // If not deletable, means has debts
      return Result.success(!isDeletable);
    } catch (e) {
      return Result.failure(
        'فشل في التحقق من الديون',
        exception: e,
      );
    }
  }
}
