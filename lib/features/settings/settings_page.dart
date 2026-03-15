import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/services/backup_service.dart';

/// Settings Controller
///
/// Manages application settings including company data, printer settings, and backup.
class SettingsController extends GetxController {
  // Company Data
  RxString companyName = 'محل تجريبي'.obs;
  RxString companyBranch = 'الفرع الرئيسي'.obs;
  RxString taxNumber = ''.obs;
  RxString companyPhone = ''.obs;
  RxString companyAddress = ''.obs;
  RxnString companyLogoPath = RxnString();
  
  // Printer Settings
  RxString selectedPrinterType = 'thermal'.obs; // thermal, normal
  RxString paperSize = '80mm'.obs; // 58mm, 80mm
  RxBool autoPrint = true.obs;
  RxBool printLogo = true.obs;
  RxBool printTaxNumber = true.obs;
  RxInt printCopies = 1.obs;
  
  // Backup Settings
  RxBool autoBackup = true.obs;
  RxString backupFrequency = 'daily'.obs; // daily, weekly, monthly
  RxString backupLocation = 'local'.obs; // local, google_drive
  Rx<DateTime?> lastBackupDate = Rx(null);
  RxInt backupCount = 0.obs;
  RxString totalBackupSize = '0 MB'.obs;
  
  // UI State
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxList<BackupInfo> backups = <BackupInfo>[].obs;
  
  final BackupService _backupService = BackupService();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadBackupInfo();
  }

  /// Load saved settings
  Future<void> _loadSettings() async {
    isLoading.value = true;
    // In production, load from SharedPreferences or database
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  /// Load backup information
  Future<void> _loadBackupInfo() async {
    try {
      final backupList = await _backupService.getBackupList();
      backups.value = backupList;
      backupCount.value = backupList.length;
      totalBackupSize.value = await _backupService.getTotalBackupSize();
      if (backupList.isNotEmpty) {
        lastBackupDate.value = backupList.first.createdAt;
      }
    } catch (e) {
      debugPrint('Error loading backup info: $e');
    }
  }

  /// Save company data
  Future<void> saveCompanyData() async {
    isSaving.value = true;
    // In production, save to SharedPreferences or database
    await Future.delayed(const Duration(milliseconds: 500));
    isSaving.value = false;
    Get.snackbar(
      'تم الحفظ',
      'تم حفظ بيانات المؤسسة بنجاح',
      backgroundColor: AppPalette.incomeContainer,
      colorText: AppPalette.income,
    );
  }

  /// Save printer settings
  Future<void> savePrinterSettings() async {
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isSaving.value = false;
    Get.snackbar(
      'تم الحفظ',
      'تم حفظ إعدادات الطابعة بنجاح',
      backgroundColor: AppPalette.incomeContainer,
      colorText: AppPalette.income,
    );
  }

  /// Pick company logo
  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
    );
    
    if (pickedFile != null) {
      companyLogoPath.value = pickedFile.path;
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.expense,
            ),
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
            'تم استعادة النسخة الاحتياطية بنجاح. يرجى إعادة تشغيل التطبيق.',
            backgroundColor: AppPalette.incomeContainer,
            colorText: AppPalette.income,
            duration: const Duration(seconds: 5),
          );
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.expense,
            ),
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

  /// Export backup
  Future<void> exportBackup(String backupPath) async {
    try {
      await _backupService.exportBackup(backupPath);
      Get.snackbar(
        'تم',
        'تم تصدير النسخة الاحتياطية',
        backgroundColor: AppPalette.incomeContainer,
        colorText: AppPalette.income,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تصدير النسخة الاحتياطية',
        backgroundColor: AppPalette.expenseContainer,
        colorText: AppPalette.expense,
      );
    }
  }

  /// Save backup settings
  Future<void> saveBackupSettings() async {
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isSaving.value = false;
    Get.snackbar(
      'تم الحفظ',
      'تم حفظ إعدادات النسخ الاحتياطي',
      backgroundColor: AppPalette.incomeContainer,
      colorText: AppPalette.income,
    );
  }
}

/// Settings Page
///
/// Main settings page with tabs for company, printer, and backup settings.
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
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Company Data Section
              _buildCompanySection(controller),
              const SizedBox(height: 24),

              // Printer Settings Section
              _buildPrinterSection(controller),
              const SizedBox(height: 24),

              // Backup Section
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
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
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
            child: const Icon(
              Icons.settings_rounded,
              color: AppPalette.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإعدادات والتهيئة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'تخصيص التطبيق حسب هويتك التجارية',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business_rounded, color: AppPalette.primary),
              const SizedBox(width: 8),
              Text(
                'بيانات المؤسسة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Logo Selection
          Center(
            child: Column(
              children: [
                Obx(() => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppPalette.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
                    image: controller.companyLogoPath.value != null
                        ? DecorationImage(
                            image: FileImage(File(controller.companyLogoPath.value!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.companyLogoPath.value == null
                      ? Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: AppPalette.textHint,
                        )
                      : null,
                )),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: controller.pickLogo,
                  icon: const Icon(Icons.edit_rounded),
                  label: Text('تغيير الشعار', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Company Name
          AppTextField(
            initialValue: controller.companyName.value,
            hintText: 'اسم المحل/المؤسسة',
            prefixIconData: Icons.store_rounded,
            onChanged: (value) => controller.companyName.value = value,
          ),
          const SizedBox(height: 12),

          // Branch Name
          AppTextField(
            initialValue: controller.companyBranch.value,
            hintText: 'اسم الفرع',
            prefixIconData: Icons.storefront_rounded,
            onChanged: (value) => controller.companyBranch.value = value,
          ),
          const SizedBox(height: 12),

          // Tax Number
          AppTextField(
            initialValue: controller.taxNumber.value,
            hintText: 'الرقم الضريبي',
            prefixIconData: Icons.receipt_long_rounded,
            keyboardType: TextInputType.number,
            onChanged: (value) => controller.taxNumber.value = value,
          ),
          const SizedBox(height: 12),

          // Phone
          AppTextField(
            initialValue: controller.companyPhone.value,
            hintText: 'رقم الهاتف',
            prefixIconData: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            onChanged: (value) => controller.companyPhone.value = value,
          ),
          const SizedBox(height: 12),

          // Address
          AppTextField(
            initialValue: controller.companyAddress.value,
            hintText: 'العنوان',
            prefixIconData: Icons.location_on_rounded,
            onChanged: (value) => controller.companyAddress.value = value,
          ),
          const SizedBox(height: 20),

          // Save Button
          Obx(() => AppPrimaryButton(
            text: 'حفظ البيانات',
            icon: Icons.save_rounded,
            isLoading: controller.isSaving.value,
            isFullWidth: true,
            onPressed: controller.saveCompanyData,
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
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.print_rounded, color: AppPalette.primary),
              const SizedBox(width: 8),
              Text(
                'إعدادات الطابعة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Printer Type
          Text(
            'نوع الطابعة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          Text(
            'حجم الورق',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          const SizedBox(height: 12),
          Obx(() => _buildToggleOption(
            'طباعة الرقم الضريبي',
            controller.printTaxNumber.value,
            (value) => controller.printTaxNumber.value = value,
          )),
          const SizedBox(height: 16),

          // Print Copies
          Row(
            children: [
              Text(
                'عدد نسخ الطباعة:',
                style: GoogleFonts.cairo(fontSize: 14),
              ),
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
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
          const SizedBox(height: 20),

          // Save Button
          Obx(() => AppPrimaryButton(
            text: 'حفظ الإعدادات',
            icon: Icons.save_rounded,
            isLoading: controller.isSaving.value,
            isFullWidth: true,
            onPressed: controller.savePrinterSettings,
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
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
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
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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
              const SizedBox(width: 12),
              Expanded(
                child: _buildBackupStat(
                  'الحجم الكلي',
                  controller.totalBackupSize.value,
                  Icons.storage_rounded,
                ),
              ),
            ],
          )),
          const SizedBox(height: 20),

          // Auto Backup Toggle
          Obx(() => _buildToggleOption(
            'نسخ احتياطي تلقائي',
            controller.autoBackup.value,
            (value) => controller.autoBackup.value = value,
          )),
          const SizedBox(height: 16),

          // Backup Frequency
          Obx(() => controller.autoBackup.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تكرار النسخ الاحتياطي',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRadioOption(
                            'يومي',
                            'daily',
                            controller.backupFrequency.value,
                            (value) => controller.backupFrequency.value = value,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRadioOption(
                            'أسبوعي',
                            'weekly',
                            controller.backupFrequency.value,
                            (value) => controller.backupFrequency.value = value,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRadioOption(
                            'شهري',
                            'monthly',
                            controller.backupFrequency.value,
                            (value) => controller.backupFrequency.value = value,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox.shrink()),

          // Backup Location
          Text(
            'مكان الحفظ',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  'على الجهاز',
                  'local',
                  controller.backupLocation.value,
                  (value) => controller.backupLocation.value = value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  'Google Drive',
                  'google_drive',
                  controller.backupLocation.value,
                  (value) => controller.backupLocation.value = value,
                ),
              ),
            ],
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
          const SizedBox(height: 24),

          // Backup List
          Text(
            'النسخ الاحتياطية المحفوظة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
                        Icons.backup_outlined,
                        size: 48,
                        color: AppPalette.textHint,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد نسخ احتياطية',
                        style: GoogleFonts.cairo(
                          color: AppPalette.textSecondary,
                        ),
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

  Widget _buildRadioOption(
    String label,
    String value,
    String groupValue,
    Function(String) onChanged,
  ) {
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
            color: isSelected ? AppPalette.primary : AppPalette.outline.withOpacity(0.5),
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

  Widget _buildToggleOption(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
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
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: AppPalette.textSecondary,
            ),
          ),
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
            child: const Icon(
              Icons.storage_rounded,
              color: AppPalette.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.fileName,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      backup.formattedDate,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppPalette.textHint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      backup.formattedSize,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppPalette.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'restore':
                  controller.restoreBackup(backup.path);
                  break;
                case 'export':
                  controller.exportBackup(backup.path);
                  break;
                case 'delete':
                  controller.deleteBackup(backup.path);
                  break;
              }
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
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.share_rounded),
                    const SizedBox(width: 8),
                    Text('تصدير', style: GoogleFonts.cairo()),
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
