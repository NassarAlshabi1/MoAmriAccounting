import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/store.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/pages/home_page.dart';
import 'package:window_manager/window_manager.dart';

import '../database/currencies_database.dart';
import '../database/entities/currency.dart';

/// Check if running on desktop platform (Windows, Linux, macOS)
bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

class StoreSetupController extends GetxController {
  RxBool creating = false.obs;
  final formKey = GlobalKey<FormState>();

  // Store info controllers
  final storeNameController = TextEditingController();
  final storeBranchController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeCurrencyController = TextEditingController();

  // Admin user controllers
  final adminNameController = TextEditingController();
  final adminUsernameController = TextEditingController();
  final adminPasswordController = TextEditingController();

  @override
  void onClose() {
    storeNameController.dispose();
    storeBranchController.dispose();
    storeAddressController.dispose();
    storePhoneController.dispose();
    storeCurrencyController.dispose();
    adminNameController.dispose();
    adminUsernameController.dispose();
    adminPasswordController.dispose();
    super.onClose();
  }

  Future<void> createStore() async {
    // Validate all required fields
    if (storeNameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'اسم المتجر مطلوب',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (storeCurrencyController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'العملة الرئيسية مطلوبة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (adminNameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'اسم المشرف مطلوب',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (adminUsernameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'اسم المستخدم مطلوب',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (adminPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور مطلوبة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    creating.value = true;

    try {
      // Store data
      Store store = Store(
        name: storeNameController.text.trim(),
        branch: storeBranchController.text.trim(),
        address: storeAddressController.text.trim(),
        phone: storePhoneController.text.trim(),
        currency: storeCurrencyController.text.trim(),
        updatedDate: DateTime.now().millisecondsSinceEpoch,
      );

      // Admin user data
      User user = User(
        name: adminNameController.text.trim(),
        enabled: 1,
        username: adminUsernameController.text.trim(),
        password: adminPasswordController.text.trim(),
        role: "admin",
      );

      // Insert admin user
      user.id = await MyDatabase.insertUser(user, null);

      // Insert default currency
      await CurrenciesDatabase.insertCurrency(
        Currency(name: storeCurrencyController.text.trim(), exchangeRate: 1),
        user,
      );

      // Set store data
      await MyDatabase.setStoreData(store);

      // Update main controller
      final mainController = Get.put(MainController());
      mainController.storeData.value = store;
      mainController.currentUser.value = user;
      await mainController.getCurrencies();

      // Play success sound
      try {
        AudioPlayer()
            .play(AssetSource('sounds/scanner-beep.mp3'))
            .catchError((e) {
          debugPrint('Error playing sound: $e');
        });
      } catch (e) {
        debugPrint('Error with audio player: $e');
      }

      // Show success message
      Get.snackbar(
        'تم بنجاح',
        'تم إعداد متجرك بنجاح',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Configure window for desktop
      if (_isDesktop) {
        WindowOptions windowOptions = const WindowOptions(
          size: Size(1280, 800),
          minimumSize: Size(1024, 600),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.hidden,
        );
        await windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }

      // Navigate to home page
      Get.off(() => const HomePage());
    } catch (e) {
      log("Error creating store: $e");
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء المتجر: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      creating.value = false;
    }
  }
}
