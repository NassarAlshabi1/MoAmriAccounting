import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'database/my_database.dart';
import 'database/currencies_database.dart';
import 'database/entities/currency.dart';
import 'database/entities/store.dart';
import 'database/entities/user.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/store_setup_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeController());
  runApp(const MoAmriAccountingApp());
}

class MoAmriAccountingApp extends StatelessWidget {
  const MoAmriAccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const InitScreen(),
      ),
    );
  }
}

/// Initialization screen - handles database setup and navigation
class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  bool _isLoading = true;
  String? _error;
  Store? _storeData;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Open database
      debugPrint('Opening database...');
      await MyDatabase.open();
      debugPrint('Database opened successfully');

      // Load store data
      debugPrint('Loading store data...');
      _storeData = await MyDatabase.getStoreData();
      debugPrint('Store data loaded: ${_storeData?.name ?? "No store"}');

      // Load currencies
      debugPrint('Loading currencies...');
      await CurrenciesDatabase.getCurrencies();
      debugPrint('Currencies loaded');

      setState(() {
        _isLoading = false;
      });

      // Navigate after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_storeData == null) {
          Get.off(() => const StoreSetupPage());
        } else {
          Get.off(() => const LoginPage());
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error initializing app: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: _buildBody(colorScheme),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.calculate_rounded,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'محاسبي',
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'نظام المحاسبة المتكامل',
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'حدث خطأ',
                style: TextStyle(
                  fontFamily: 'ReadexPro',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'ReadexPro',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Main Controller for app state
class MainController extends GetxController {
  RxBool loading = false.obs;
  RxString error = ''.obs;

  /// Store information
  Rx<Store?> storeData = Rx(null);

  /// Current logged in user
  Rx<User?> currentUser = Rx(null);

  /// Local storage
  final getStorage = GetStorage();

  /// Currencies loading state and data
  RxBool loadingCurrencies = false.obs;
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

  /// Navigate to home page after login
  void navigateToHome(User user) {
    currentUser.value = user;
    Get.off(() => const HomePage());
  }

  /// Logout user
  void logout() {
    currentUser.value = null;
    Get.off(() => const LoginPage());
  }
}
