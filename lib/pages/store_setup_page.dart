import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import '../controllers/store_setup_controller.dart';

/// Check if running on desktop platform (Windows, Linux, macOS)
bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

/// Store Setup Page - Modern Material 3 Design
///
/// First-time setup wizard for:
/// - Store information (name, branch, address, phone, currency)
/// - Admin user creation
/// - Restore from backup option
class StoreSetupPage extends StatefulWidget {
  const StoreSetupPage({super.key});

  @override
  State<StoreSetupPage> createState() => _StoreSetupPageState();
}

class _StoreSetupPageState extends State<StoreSetupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StoreSetupController controller = Get.put(StoreSetupController());
  final _currentPage = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _configureWindow();
  }

  void _configureWindow() {
    if (!_isDesktop) return;

    try {
      WindowOptions windowOptions = const WindowOptions(
        size: Size(900, 700),
        maximumSize: Size(900, 700),
        minimumSize: Size(900, 700),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
        debugPrint('Window manager not available: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppPalette.background,
        body: Obx(() => Stepper(
          type: StepperType.horizontal,
          currentStep: _currentPage.value,
          onStepContinue: () {
            if (_currentPage.value < 2) {
              _currentPage.value++;
            }
          },
          onStepCancel: () {
            if (_currentPage.value > 0) {
              _currentPage.value--;
            }
          },
          onStepTapped: (step) => _currentPage.value = step,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentPage.value > 0)
                    Expanded(
                      child: AppSecondaryButton(
                        text: 'السابق',
                        icon: Icons.arrow_back_rounded,
                        onPressed: details.onStepCancel!,
                      ),
                    ),
                  if (_currentPage.value > 0) const SizedBox(width: 16),
                  Expanded(
                    child: _currentPage.value < 2
                        ? AppPrimaryButton(
                            text: 'التالي',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: details.onStepContinue!,
                          )
                        : Obx(() => controller.creating.value
                            ? const Center(child: CircularProgressIndicator())
                            : AppPrimaryButton(
                                text: 'إتمام الإعداد',
                                icon: Icons.check_rounded,
                                onPressed: () async {
                                  controller.creating.value = true;
                                  await controller.createStore();
                                  controller.creating.value = false;
                                },
                              )),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Welcome
            Step(
              title: Text('مرحباً', style: GoogleFonts.cairo()),
              content: _buildWelcomeStep(),
              isActive: _currentPage.value == 0,
            ),
            // Step 2: Store Info
            Step(
              title: Text('معلومات المتجر', style: GoogleFonts.cairo()),
              content: _buildStoreInfoStep(),
              isActive: _currentPage.value == 1,
            ),
            // Step 3: Admin User
            Step(
              title: Text('المستخدم المشرف', style: GoogleFonts.cairo()),
              content: _buildAdminUserStep(),
              isActive: _currentPage.value == 2,
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppPalette.primaryContainer,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.store_rounded,
              size: 60,
              color: AppPalette.primary,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'مرحباً بك في محاسبي',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            'نظام المحاسبة المتكامل لإدارة متجرك بسهولة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: AppPalette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _buildFeatureItem(Icons.inventory_rounded, 'إدارة المخزون والمنتجات'),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.people_rounded, 'إدارة العملاء والموردين'),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.receipt_long_rounded, 'الفواتير والفواتير الآجلة'),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.assessment_rounded, 'التقارير والإحصائيات'),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.backup_rounded, 'النسخ الاحتياطي والاستعادة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppPalette.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppPalette.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfoStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'أدخل معلومات متجرك',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هذه المعلومات ستظهر في الفواتير والتقارير',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Store Name - Required
            AppTextField(
              controller: controller.storeNameController,
              label: 'اسم المتجر *',
              hintText: 'مثال: متجر الأمل',
              prefixIconData: Icons.store_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'اسم المتجر مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Branch - Optional
            AppTextField(
              controller: controller.storeBranchController,
              label: 'الفرع',
              hintText: 'مثال: الفرع الرئيسي',
              prefixIconData: Icons.storefront_rounded,
            ),
            const SizedBox(height: 20),

            // Address - Optional
            AppTextField(
              controller: controller.storeAddressController,
              label: 'العنوان',
              hintText: 'مثال: الرياض، حي النخيل',
              prefixIconData: Icons.location_on_rounded,
            ),
            const SizedBox(height: 20),

            // Phone - Optional
            AppTextField(
              controller: controller.storePhoneController,
              label: 'رقم الهاتف',
              hintText: 'مثال: 0501234567',
              prefixIconData: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Currency - Required
            AppTextField(
              controller: controller.storeCurrencyController,
              label: 'العملة الرئيسية *',
              hintText: 'مثال: ريال سعودي',
              prefixIconData: Icons.attach_money_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'العملة مطلوبة';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminUserStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'إنشاء حساب المشرف',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هذا الحساب سيكون له صلاحيات كاملة في النظام',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Admin Name
          AppTextField(
            controller: controller.adminNameController,
            label: 'اسم المشرف *',
            hintText: 'مثال: أحمد محمد',
            prefixIconData: Icons.person_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'اسم المشرف مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Username
          AppTextField(
            controller: controller.adminUsernameController,
            label: 'اسم المستخدم *',
            hintText: 'مثال: admin',
            prefixIconData: Icons.account_circle_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'اسم المستخدم مطلوب';
              }
              if (value.length < 3) {
                return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password
          AppTextField(
            controller: controller.adminPasswordController,
            label: 'كلمة المرور *',
            hintText: 'أدخل كلمة مرور قوية',
            prefixIconData: Icons.lock_rounded,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'كلمة المرور مطلوبة';
              }
              if (value.length < 4) {
                return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.infoContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPalette.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppPalette.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يمكنك إضافة مستخدمين آخرين لاحقاً من الإعدادات',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppPalette.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
