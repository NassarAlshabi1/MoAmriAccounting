/// App Constants
/// Centralized configuration for the application

class AppConstants {
  AppConstants._();

  // ============== App Info ==============
  static const String appName = 'محاسبي';
  static const String appVersion = '1.0.0';
  static const String appFullName = 'نظام المحاسبة المتكامل';

  // ============== Database ==============
  static const String databaseName = 'moamri_accounting.db';
  static const int databaseVersion = 1;

  // ============== Session ==============
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  // ============== Pagination ==============
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============== Form Validation ==============
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 100;
  static const int maxNameLength = 100;
  static const int maxPhoneLength = 20;
  static const int maxAddressLength = 500;
  static const int maxNoteLength = 1000;

  // ============== Currency ==============
  static const String defaultCurrency = 'دينار';
  static const int maxDecimalPlaces = 2;

  // ============== Date Formats ==============
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // ============== File Paths ==============
  static const String soundsPath = 'assets/sounds/';
  static const String imagesPath = 'assets/images/';
  static const String fontsPath = 'assets/fonts/';

  // ============== Sound Files ==============
  static const String scannerBeepSound = 'scanner-beep.mp3';
  static const String cashRegisterSound = 'cash-register.mp3';

  // ============== Animation Durations ==============
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // ============== Debounce ==============
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration saveDebounce = Duration(milliseconds: 1000);

  // ============== Error Messages ==============
  static const String genericError = 'حدث خطأ غير متوقع';
  static const String networkError = 'خطأ في الاتصال بالشبكة';
  static const String databaseError = 'خطأ في قاعدة البيانات';
  static const String sessionExpired = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
}

/// App Routes
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String storeSetup = '/store-setup';

  // Inventory
  static const String inventory = '/inventory';
  static const String addMaterial = '/inventory/add';
  static const String editMaterial = '/inventory/edit';

  // Customers
  static const String customers = '/customers';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/edit';

  // Sales
  static const String sale = '/sale';

  // Returns
  static const String returns = '/returns';

  // Debts
  static const String debts = '/debts';
  static const String debtsReport = '/debts/report';

  // Suppliers
  static const String suppliers = '/suppliers';

  // Invoices
  static const String salesInvoices = '/invoices/sales';
  static const String purchaseInvoices = '/invoices/purchases';

  // Expenses
  static const String expenses = '/expenses';

  // Reports
  static const String reports = '/reports';

  // Alerts
  static const String alerts = '/alerts';

  // Users
  static const String users = '/users';

  // Settings
  static const String settings = '/settings';
}

/// User Roles
class UserRole {
  UserRole._();

  static const String admin = 'admin';
  static const String cashier = 'cashier';

  static List<String> get all => [admin, cashier];

  static String getDisplayName(String role) {
    switch (role) {
      case admin:
        return 'مدير';
      case cashier:
        return 'كاشير';
      default:
        return role;
    }
  }
}

/// Invoice Types
class InvoiceType {
  InvoiceType._();

  static const String sale = 'sale';
  static const String return_ = 'return';
  static const String purchase = 'purchase';
  static const String purchaseReturn = 'purchase_return';

  static String getDisplayName(String type) {
    switch (type) {
      case sale:
        return 'فاتورة بيع';
      case return_:
        return 'فاتورة مرتجع';
      case purchase:
        return 'فاتورة شراء';
      case purchaseReturn:
        return 'فاتورة مرتجع شراء';
      default:
        return type;
    }
  }
}

/// Material Categories
class MaterialCategory {
  MaterialCategory._();

  static const String all = 'الكل';
  static const String electronics = 'إلكترونيات';
  static const String food = 'مواد غذائية';
  static const String clothes = 'ملابس';
  static const String other = 'أخرى';

  static List<String> get allCategories => [
        all,
        electronics,
        food,
        clothes,
        other,
      ];
}

/// Payment Methods
class PaymentMethod {
  PaymentMethod._();

  static const String cash = 'cash';
  static const String card = 'card';
  static const String credit = 'credit';
  static const String check = 'check';

  static String getDisplayName(String method) {
    switch (method) {
      case cash:
        return 'نقدي';
      case card:
        return 'بطاقة';
      case credit:
        return 'آجل';
      case check:
        return 'شيك';
      default:
        return method;
    }
  }
}

/// Sort Options
class SortOption {
  SortOption._();

  static const int ascending = 0;
  static const int descending = 1;
}
