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
    final controller = TextEditingController();
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('إضافة عملة جديدة', style: GoogleFonts.cairo()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'رمز العملة (مثال: €)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('إضافة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      // Add to available currencies
      Get.snackbar(
        'تم',
        'تمت إضافة العملة',
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

/// Settings Page
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppPalette.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_rounded, color: AppPalette.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإعدادات',
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'إدارة إعدادات المتجر والنظام',
                style: GoogleFonts.cairo(fontSize: 13, color: AppPalette.textSecondary),
              ),
            ],
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store_rounded, color: AppPalette.primary),
              const SizedBox(width: 8),
              Text(
                'بيانات المتجر',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Store Name
          AppTextField(
            hintText: 'اسم المتجر *',
            prefixIconData: Icons.store_rounded,
            onChanged: (value) => controller.storeName.value = value,
          ),
          Obx(() => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              controller.storeName.value.isNotEmpty
                  ? controller.storeName.value
                  : 'الاسم الحالي',
              style: GoogleFonts.cairo(fontSize: 11, color: AppPalette.textHint),
            ),
          )),
          const SizedBox(height: 12),

          // Branch
          AppTextField(
            hintText: 'اسم الفرع',
            prefixIconData: Icons.storefront_rounded,
            onChanged: (value) => controller.storeBranch.value = value,
          ),
          Obx(() => controller.storeBranch.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'الحالي: ${controller.storeBranch.value}',
                    style: GoogleFonts.cairo(fontSize: 11, color: AppPalette.textHint),
                  ),
                )
              : const SizedBox()),
          const SizedBox(height: 12),

          // Phone
          AppTextField(
            hintText: 'رقم الهاتف',
            prefixIconData: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            onChanged: (value) => controller.storePhone.value = value,
          ),
          const SizedBox(height: 12),

          // Address
          AppTextField(
            hintText: 'العنوان',
            prefixIconData: Icons.location_on_rounded,
            onChanged: (value) => controller.storeAddress.value = value,
          ),
          const SizedBox(height: 12),

          // Default Currency
          Text(
            'العملة الافتراضية',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppCurrency.available.map((currency) {
              final isSelected = controller.storeCurrency.value == currency.symbol ||
                  controller.storeCurrency.value == currency.code;
              return ChoiceChip(
                label: Text('${currency.symbol} ${currency.nameAr}'),
                selected: isSelected,
                onSelected: (_) {
                  controller.storeCurrency.value = currency.symbol;
                },
                selectedColor: AppPalette.primaryContainer,
                labelStyle: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
                ),
              );
            }).toList(),
          )),
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

  Widget _buildCurrencySection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_money_rounded, color: AppPalette.primary),
                  const SizedBox(width: 8),
                  Text(
                    'العملات',
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: controller.addCustomCurrency,
                icon: const Icon(Icons.add_rounded),
                label: Text('إضافة عملة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPalette.infoContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppPalette.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يمكنك تعيين عملة مفضلة لكل عميل على حدة عند إضافته',
                    style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'العملات المتاحة',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
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
                      width: 40,
                      height: 40,
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
                    Text(
                      currency.code,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppPalette.textSecondary,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.print_rounded, color: AppPalette.primary),
              const SizedBox(width: 8),
              Text(
                'إعدادات الطباعة',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Printer Type
          Text('نوع الطابعة', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),

          // Paper Size
          Text('حجم الورق', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),

          // Auto Print
          Obx(() => _buildToggleOption(
            'طباعة تلقائية بعد البيع',
            controller.autoPrint.value,
            (value) => controller.autoPrint.value = value,
          )),
          const SizedBox(height: 12),

          // Print Logo
          Obx(() => _buildToggleOption(
            'طباعة الشعار في الفاتورة',
            controller.printLogo.value,
            (value) => controller.printLogo.value = value,
          )),
          const SizedBox(height: 16),

          // Print Copies
          Row(
            children: [
              Text('عدد نسخ الطباعة:', style: GoogleFonts.cairo(fontSize: 14)),
              const SizedBox(width: 16),
              Obx(() => Row(
                children: [
                  IconButton(
                    onPressed: controller.printCopies.value > 1
                        ? () => controller.printCopies.value--
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '${controller.printCopies.value}',
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.printCopies.value < 5
                        ? () => controller.printCopies.value++
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              )),
            ],
          ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.backup_rounded, color: AppPalette.primary),
              const SizedBox(width: 8),
              Text(
                'النسخ الاحتياطي',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
            text: 'إنشاء نسخة احتياطية',
            icon: Icons.add_circle_rounded,
            isLoading: controller.isSaving.value,
            isFullWidth: true,
            onPressed: controller.createBackup,
          )),
          const SizedBox(height: 16),

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
                  child: Text(
                    'لا توجد نسخ احتياطية',
                    style: GoogleFonts.cairo(color: AppPalette.textSecondary),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.primaryContainer : AppPalette.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppPalette.primary : AppPalette.outline.withValues(alpha: 0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppPalette.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
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
            width: 40,
            height: 40,
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
