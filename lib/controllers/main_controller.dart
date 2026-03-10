import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:moamri_accounting/database/my_database.dart';

import '../database/currencies_database.dart';
import '../database/entities/currency.dart';
import '../database/entities/store.dart';
import '../database/entities/user.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/store_setup_page.dart';

class MainController extends GetxController {
  RxBool loading = true.obs;
  RxString error = ''.obs;

  /// Store information
  Rx<Store?> storeData = Rx(null);

  /// Current logged in user
  Rx<User?> currentUser = Rx(null);

  /// Local storage
  final getStorage = GetStorage();

  /// Currencies loading state and data
  RxBool loadingCurrencies = true.obs;
  RxList<Currency> currencies = <Currency>[].obs;

  /// Load currencies from database
  Future<void> getCurrencies() async {
    loadingCurrencies.value = true;
    try {
      final currencyList = await CurrenciesDatabase.getCurrencies();
      currencies.value = currencyList;
    } catch (e) {
      debugPrint('Error loading currencies: $e');
    } finally {
      loadingCurrencies.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Initialize the application
  Future<void> _initializeApp() async {
    try {
      loading.value = true;
      error.value = '';

      // Open database
      debugPrint('Opening database...');
      await MyDatabase.open();
      debugPrint('Database opened successfully');

      // Load store data
      debugPrint('Loading store data...');
      storeData.value = await MyDatabase.getStoreData();
      debugPrint('Store data loaded: ${storeData.value?.name ?? "No store"}');

      // Load currencies
      debugPrint('Loading currencies...');
      await getCurrencies();
      debugPrint('Currencies loaded: ${currencies.length}');

      // Mark loading as complete
      loading.value = false;

      // Navigate based on store state
      if (storeData.value == null) {
        debugPrint('No store found, navigating to StoreSetupPage');
        Get.off(() => const StoreSetupPage());
      } else {
        debugPrint('Store found, showing login dialog');
        // Use addPostFrameCallback to ensure UI is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLoginDialog();
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing app: $e');
      debugPrint('Stack trace: $stackTrace');
      error.value = 'فشل في تهيئة التطبيق: $e';
      loading.value = false;
    }
  }

  /// Show login dialog
  void _showLoginDialog() {
    try {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const LoginPage(),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing login dialog: $e');
      // Fallback: navigate directly to login page
      Get.off(() => const LoginPage());
    }
  }

  /// Navigate to home page after login
  void navigateToHome(User user) {
    currentUser.value = user;
    Get.off(() => const HomePage());
  }

  /// Logout user
  void logout() {
    currentUser.value = null;
    _showLoginDialog();
  }
}
