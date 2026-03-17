import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';

/// Backup Controller
class BackupController extends GetxController {
  final backups = <BackupInfo>[].obs;
  final isLoading = false.obs;
  final isCreating = false.obs;
  final totalSize = '0 MB'.obs;

  @override
  void onInit() {
    super.onInit();
    loadBackups();
  }

  Future<void> loadBackups() async {
    isLoading.value = true;
    // Simulate loading backups
    await Future.delayed(const Duration(milliseconds: 500));
    // In production, load from BackupService
    backups.value = [];
    totalSize.value = '0 MB';
    isLoading.value = false;
  }

  Future<void> createBackup() async {
    isCreating.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isCreating.value = false;
    Get.snackbar(
      'تم',
      'تم إنشاء النسخة الاحتياطية بنجاح',
      backgroundColor: AppPalette.income,
      colorText: Colors.white,
    );
    loadBackups();
  }
}

/// Backup Info Model
class BackupInfo {
  final String fileName;
  final DateTime createdAt;
  final int fileSize;
  final String path;

  BackupInfo({
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
    required this.path,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

/// Backup Page
class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BackupController());

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text(
          'النسخ الاحتياطي',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppPalette.surface,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.infoContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppPalette.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'النسخ الاحتياطي يحفظ جميع بياناتك. يُنصح بإنشاء نسخة احتياطية بشكل منتظم.',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppPalette.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.backup_rounded,
                          label: 'عدد النسخ',
                          value: '${controller.backups.length}',
                          color: AppPalette.primary,
                        ),
                        _buildStatItem(
                          icon: Icons.storage_rounded,
                          label: 'الحجم الكلي',
                          value: controller.totalSize.value,
                          color: AppPalette.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Text(
                'الإجراءات',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              AppPrimaryButton(
                text: 'إنشاء نسخة احتياطية جديدة',
                icon: Icons.add_circle_rounded,
                isLoading: controller.isCreating.value,
                isFullWidth: true,
                onPressed: controller.createBackup,
              ),
              const SizedBox(height: 12),
              
              AppSecondaryButton(
                text: 'استيراد نسخة من ملف',
                icon: Icons.file_upload_rounded,
                isFullWidth: true,
                onPressed: () {
                  Get.snackbar(
                    'ملاحظة',
                    'سيتم إضافة هذه الميزة قريباً',
                    backgroundColor: AppPalette.warningContainer,
                    colorText: AppPalette.warning,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Backups List
              Text(
                'النسخ الاحتياطية المحفوظة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              if (controller.backups.isEmpty)
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.backup_outlined,
                        size: 64,
                        color: AppPalette.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد نسخ احتياطية',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط على "إنشاء نسخة احتياطية" للبدء',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppPalette.textHint,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.backups.length,
                  itemBuilder: (context, index) {
                    final backup = controller.backups[index];
                    return _buildBackupCard(backup);
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: AppPalette.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupCard(BackupInfo backup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Icons.storage_rounded,
              color: AppPalette.primary,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${backup.formattedDate} ${backup.formattedTime}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      backup.formattedSize,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
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
                  Get.snackbar(
                    'استعادة',
                    'سيتم استعادة هذه النسخة',
                    backgroundColor: AppPalette.infoContainer,
                    colorText: AppPalette.info,
                  );
                  break;
                case 'export':
                  Get.snackbar(
                    'تصدير',
                    'سيتم تصدير هذه النسخة',
                    backgroundColor: AppPalette.incomeContainer,
                    colorText: AppPalette.income,
                  );
                  break;
                case 'delete':
                  Get.snackbar(
                    'حذف',
                    'سيتم حذف هذه النسخة',
                    backgroundColor: AppPalette.expenseContainer,
                    colorText: AppPalette.expense,
                  );
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
}
