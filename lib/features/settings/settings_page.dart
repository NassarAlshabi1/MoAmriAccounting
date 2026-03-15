import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/services/backup_service.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/database/entities/store.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';

/// Settings Controller
class SettingsController extends GetxController {
  // Store Data
  RxString storeName = ''.obs;
  RxString storeBranch = ''.obs;
  RxString storeAddress = ''.obs;
  RxString storePhone = ''.obs;
  RxString storeCurrency = 'ر.س'.obs;
  RxnString storeLogoPath = RxnString();

  // Default Currency Settings
  RxString defaultCurrency = 'ر.س'.obs;
  RxList<AppCurrency> availableCurrencies = <AppCurrency>[].obs;
  RxList<AppCurrency> selectedCurrencies = <AppCurrency>[].obs;

  // Printer Settings
  RxString selectedPrinterType = 'thermal'.obs;
  RxString paperSize = '80mm'.obs;
  RxBool autoPrint = true.obs;
  RxBool printLogo = true.obs;
  RxInt printCopies = 1.obs;

  // Backup Settings
  RxBool autoBackup = true.obs;
  RxString backupFrequency = 'daily'.obs;
  Rx<DateTime?> lastBackupDate = Rx(null);
  RxInt backupCount = 0.obs;

  // UI State
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxList<BackupInfo> backups = <BackupInfo>[].obs;
  RxInt currentTabIndex = 0.obs;

  final BackupService _backupService = BackupService();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadAvailableCurrencies();
    _loadBackupInfo();
  }

  Future<void> _loadSettings() async {
    isLoading.value = true;
    try {
      final mainController = Get.find<MainController>();
      if (mainController.storeData.value != null) {
        final store = mainController.storeData.value!;
        storeName.value = store.name;
        storeBranch.value = store.branch ?? '';
        storeAddress.value = store.address ?? '';
        storePhone.value = store.phone ?? '';
        storeCurrency.value = store.currency ?? 'ر.س';
        defaultCurrency.value = store.currency ?? 'ر.س';
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    isLoading.value = false;
  }

  void _loadAvailableCurrencies() {
    availableCurrencies.value = AppCurrency.available;
    // Default selected currencies (most common)
    selectedCurrencies.value = AppCurrency.available.take(4).toList();
  }

  Future<void> _loadBackupInfo() async {
    try {
      final backupList = await _backupService.getBackupList();
      backups.value = backupList;
      backupCount.value = backupList.length;
      if (backupList.isNotEmpty) {
        lastBackupDate.value = backupList.first.createdAt;
      }
    } catch (e) {
      debugPrint('Error loading backup info: $e');
    }
  }

  /// Save store data
  Future<void> saveStoreData() async {
    isSaving.value = true;
    try {
      final store = Store(
        name: storeName.value,
        branch: storeBranch.value,
        address: storeAddress.value,
        phone: storePhone.value,
        currency: storeCurrency.value,
        updatedDate: DateTime.now().millisecondsSinceEpoch,
      );

      await MyDatabase.setStoreData(store);

      final mainController = Get.find<MainController>();
      mainController.storeData.value = store;

      Get.snackbar(
        'تم الحفظ',
        'تم حفظ بيانات المتجر بنجاح',
        backgroundColor: AppPalette.incomeContainer,
        colorText: AppPalette.income,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ البيانات: $e',
        backgroundColor: AppPalette.expenseContainer,
        colorText: AppPalette.expense,
      );
    }
    isSaving.value = false;
  }

  /// Pick store logo
  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (pickedFile != null) {
      storeLogoPath.value = pickedFile.path;
    }
  }

  /// Add custom currency
  Future<void> addCustomCurrency() async {
    final nameController = TextEditingController();
    final symbolController = TextEditingController();
    final codeController = TextEditingController();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('إضافة عملة جديدة', style: GoogleFonts.cairo()),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                hintText: 'اسم العملة بالعربية',
                prefixIconData: Icons.text_fields_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: symbolController,
                hintText: 'رمز العملة (مثال: $)',
                prefixIconData: Icons.attach_money_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: codeController,
                hintText: 'رمز ISO (مثال: USD)',
                prefixIconData: Icons.code_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  symbolController.text.isNotEmpty) {
                Get.back(result: true);
              }
            },
            child: Text('إضافة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty && symbolController.text.isNotEmpty) {
      final newCurrency = AppCurrency(
        code: codeController.text.toUpperCase(),
        symbol: symbolController.text,
        nameAr: nameController.text,
        nameEn: nameController.text,
      );
      availableCurrencies.add(newCurrency);
      Get.snackbar(
        'تم',
        'تمت إضافة العملة "${nameController.text}"',
        backgroundColor: AppPalette.incomeContainer,
        colorText: AppPalette.income,
      );
    }
  }

  /// Create backup
  Future<void> createBackup() async {
    isSaving.value = true;
    try {
      final result = await _backupService.createBackup();
      if (result.success) {
        Get.snackbar(
          'تم',
          result.message,
          backgroundColor: AppPalette.incomeContainer,
          colorText: AppPalette.income,
        );
        await _loadBackupInfo();
      } else {
        Get.snackbar(
          'خطأ',
          result.message,
          backgroundColor: AppPalette.expenseContainer,
          colorText: AppPalette.expense,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إنشاء النسخة الاحتياطية',
        backgroundColor: AppPalette.expenseContainer,
        colorText: AppPalette.expense,
      );
    }
    isSaving.value = false;
  }

  /// Restore backup
  Future<void> restoreBackup(String backupPath) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الاستعادة', style: GoogleFonts.cairo()),
        content: Text(
          'سيتم استبدال جميع البيانات الحالية. هل أنت متأكد؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.expense),
            child: Text('استعادة', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      isSaving.value = true;
      try {
        final result = await _backupService.restoreBackup(backupPath);
        if (result.success) {
          Get.snackbar(
            'تم',
            'تم استعادة النسخة الاحتياطية بنجاح',
            backgroundColor: AppPalette.incomeContainer,
            colorText: AppPalette.income,
          );
        }
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'فشل في استعادة النسخة الاحتياطية',
          backgroundColor: AppPalette.expenseContainer,
          colorText: AppPalette.expense,
        );
      }
      isSaving.value = false;
    }
  }

  /// Delete backup
  Future<void> deleteBackup(String backupPath) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الحذف', style: GoogleFonts.cairo()),
        content: Text(
          'هل أنت متأكد من حذف هذه النسخة الاحتياطية؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.expense),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _backupService.deleteBackup(backupPath);
      await _loadBackupInfo();
      Get.snackbar(
        'تم',
        'تم حذف النسخة الاحتياطية',
        backgroundColor: AppPalette.incomeContainer,
        colorText: AppPalette.income,
      );
    }
  }
}

/// Settings Page - Modern Material 3 Design
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStoreSection(controller),
              const SizedBox(height: 24),
              _buildCurrencySection(controller),
              const SizedBox(height: 24),
              _buildPrinterSection(controller),
              const SizedBox(height: 24),
              _buildBackupSection(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.primary, AppPalette.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإعدادات',
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'إدارة إعدادات المتجر والنظام',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'الإصدار 1.0.0',
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store_rounded, color: AppPalette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'بيانات المتجر',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Store Name
          _buildFieldLabel('اسم المتجر *'),
          const SizedBox(height: 8),
          AppTextField(
            hintText: 'اسم المتجر',
            prefixIconData: Icons.store_rounded,
            initialValue: controller.storeName.value,
            onChanged: (value) => controller.storeName.value = value,
          ),
          const SizedBox(height: 16),

          // Branch
          _buildFieldLabel('اسم الفرع'),
          const SizedBox(height: 8),
          AppTextField(
            hintText: 'اسم الفرع (اختياري)',
            prefixIconData: Icons.storefront_rounded,
            initialValue: controller.storeBranch.value,
            onChanged: (value) => controller.storeBranch.value = value,
          ),
          const SizedBox(height: 16),

          // Phone
          _buildFieldLabel('رقم الهاتف'),
          const SizedBox(height: 8),
          AppTextField(
            hintText: 'رقم الهاتف',
            prefixIconData: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            initialValue: controller.storePhone.value,
            onChanged: (value) => controller.storePhone.value = value,
          ),
          const SizedBox(height: 16),

          // Address
          _buildFieldLabel('العنوان'),
          const SizedBox(height: 8),
          AppTextField(
            hintText: 'العنوان',
            prefixIconData: Icons.location_on_rounded,
            initialValue: controller.storeAddress.value,
            onChanged: (value) => controller.storeAddress.value = value,
          ),
          const SizedBox(height: 20),

          // Save Button
          Obx(() => AppPrimaryButton(
            text: 'حفظ بيانات المتجر',
            icon: Icons.save_rounded,
            isLoading: controller.isSaving.value,
            isFullWidth: true,
            onPressed: controller.saveStoreData,
          )),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppPalette.textSecondary,
      ),
    );
  }

  Widget _buildCurrencySection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppPalette.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.attach_money_rounded, color: AppPalette.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'إدارة العملات',
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: controller.addCustomCurrency,
                icon: const Icon(Icons.add_rounded),
                label: Text('إضافة عملة', style: GoogleFonts.cairo()),
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Default Currency
          _buildFieldLabel('العملة الافتراضية للمتجر'),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.availableCurrencies.map((currency) {
              final isSelected = controller.storeCurrency.value == currency.symbol;
              return InkWell(
                onTap: () => controller.storeCurrency.value = currency.symbol,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppPalette.primaryContainer : AppPalette.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppPalette.primary : AppPalette.outline.withValues(alpha: 0.5),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            currency.symbol,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.nameAr,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppPalette.primary : AppPalette.textPrimary,
                            ),
                          ),
                          Text(
                            currency.code,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: AppPalette.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 20),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.infoContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppPalette.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يمكنك تعيين عملة مفضلة لكل عميل ومورد على حدة عند إضافته. العملة الافتراضية تُستخدم للعمليات الجديدة.',
                    style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Available Currencies List
          Text(
            'العملات المتاحة في النظام',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
            children: controller.availableCurrencies.map((currency) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppPalette.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          currency.symbol,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.nameAr,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            currency.nameEn,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppPalette.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        currency.code,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildPrinterSection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.print_rounded, color: AppPalette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'إعدادات الطباعة',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Printer Type
          _buildFieldLabel('نوع الطابعة'),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  'حرارية',
                  'thermal',
                  controller.selectedPrinterType.value,
                  (value) => controller.selectedPrinterType.value = value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  'عادية',
                  'normal',
                  controller.selectedPrinterType.value,
                  (value) => controller.selectedPrinterType.value = value,
                ),
              ),
            ],
          )),
          const SizedBox(height: 20),

          // Paper Size
          _buildFieldLabel('حجم الورق'),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  '58 مم',
                  '58mm',
                  controller.paperSize.value,
                  (value) => controller.paperSize.value = value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  '80 مم',
                  '80mm',
                  controller.paperSize.value,
                  (value) => controller.paperSize.value = value,
                ),
              ),
            ],
          )),
          const SizedBox(height: 20),

          // Toggle Options
          Obx(() => _buildToggleOption(
            'طباعة تلقائية بعد البيع',
            controller.autoPrint.value,
            (value) => controller.autoPrint.value = value,
          )),
          const SizedBox(height: 12),
          Obx(() => _buildToggleOption(
            'طباعة الشعار في الفاتورة',
            controller.printLogo.value,
            (value) => controller.printLogo.value = value,
          )),
          const SizedBox(height: 20),

          // Print Copies
          _buildFieldLabel('عدد نسخ الطباعة'),
          const SizedBox(height: 12),
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: controller.printCopies.value > 1
                      ? () => controller.printCopies.value--
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppPalette.primary,
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '${controller.printCopies.value}',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.printCopies.value < 5
                      ? () => controller.printCopies.value++
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppPalette.primary,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBackupSection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.backup_rounded, color: AppPalette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'النسخ الاحتياطي',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Backup Stats
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildBackupStat(
                  'آخر نسخة',
                  controller.lastBackupDate.value != null
                      ? _formatDate(controller.lastBackupDate.value!)
                      : 'لا توجد',
                  Icons.history_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBackupStat(
                  'عدد النسخ',
                  '${controller.backupCount.value}',
                  Icons.folder_rounded,
                ),
              ),
            ],
          )),
          const SizedBox(height: 20),

          // Auto Backup
          Obx(() => _buildToggleOption(
            'نسخ احتياطي تلقائي',
            controller.autoBackup.value,
            (value) => controller.autoBackup.value = value,
          )),
          const SizedBox(height: 20),

          // Create Backup Button
          Obx(() => AppPrimaryButton(
            text: 'إنشاء نسخة احتياطية الآن',
            icon: Icons.add_circle_rounded,
            isLoading: controller.isSaving.value,
            isFullWidth: true,
            onPressed: controller.createBackup,
          )),
          const SizedBox(height: 20),

          // Backup List
          Text(
            'النسخ المحفوظة',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.backups.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppPalette.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: AppPalette.textHint.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد نسخ احتياطية',
                        style: GoogleFonts.cairo(color: AppPalette.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: controller.backups.take(5).map((backup) {
                return _buildBackupItem(controller, backup);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, String value, String groupValue, Function(String) onChanged) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.primaryContainer : AppPalette.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppPalette.primary : AppPalette.outline.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 14)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppPalette.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppPalette.primary, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, color: AppPalette.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBackupItem(SettingsController controller, BackupInfo backup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppPalette.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storage_rounded, color: AppPalette.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(backup.fileName, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Text(backup.formattedDate, style: GoogleFonts.cairo(fontSize: 11, color: AppPalette.textHint)),
                    const SizedBox(width: 8),
                    Text(backup.formattedSize, style: GoogleFonts.cairo(fontSize: 11, color: AppPalette.textHint)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'restore') controller.restoreBackup(backup.path);
              if (value == 'delete') controller.deleteBackup(backup.path);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    const Icon(Icons.restore_rounded),
                    const SizedBox(width: 8),
                    Text('استعادة', style: GoogleFonts.cairo()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded, color: AppPalette.expense),
                    const SizedBox(width: 8),
                    Text('حذف', style: GoogleFonts.cairo(color: AppPalette.expense)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
