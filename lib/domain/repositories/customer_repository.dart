import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/items/customer_debt_item.dart';
import 'package:moamri_accounting/utils/result.dart';

/// Customer Repository Interface
///
/// Defines the contract for customer data operations.
abstract class CustomerRepository {
  /// Get a customer by ID
  Future<Result<Customer?>> getById(int? id);

  /// Get customers with pagination
  Future<Result<List<CustomerDebtItem>>> getCustomersWithDebts({
    required int page,
    String? orderBy,
    String? dir,
  });

  /// Search customers
  Future<Result<List<CustomerDebtItem>>> searchCustomers(
    String searchText, {
    required int page,
  });

  /// Get customers count
  Future<Result<int>> getCount({String? searchedText});

  /// Get customer suggestions for autocomplete
  Future<Result<List<Customer>>> getSuggestions(String text);

  /// Insert a new customer
  Future<Result<int>> insert(Customer customer, User actionBy);

  /// Update an existing customer
  Future<Result<void>> update(
      Customer customer, Customer oldCustomer, User actionBy);

  /// Delete a customer
  Future<Result<void>> delete(Customer customer, User actionBy);

  /// Check if a customer can be deleted
  Future<Result<bool>> isDeletable(int customerId);

  /// Get customer's debt
  Future<Result<double>> getDebt(Customer customer);
}
