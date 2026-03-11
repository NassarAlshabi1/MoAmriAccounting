import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../theme/app_colors.dart';
import '../theme/custom_widgets_theme.dart';
import '../theme/app_theme.dart';

// Conditional import for window_manager (desktop only)
import '../window_manager_stub.dart'
    if (dart.library.io) '../window_manager_impl.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Container(
          width: 480,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: CustomWidgetsTheme.elevatedCardDecoration(
            borderRadius: 20,
            elevation: 8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                leading: null,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Icon(Icons.login_rounded, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontFamily: 'ReadexPro',
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurfaceVariant,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: colorScheme.surface,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: colorScheme.brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarIconBrightness: colorScheme.brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: colorScheme.brightness == Brightness.dark
                      ? Brightness.dark
                      : Brightness.light,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: IconButton(
                      onPressed: () {
                        // On mobile, just pop the route
                        Navigator.of(context).pop();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.error,
                      ),
                      tooltip: 'إغلاق',
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Username Field
                        TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: controller.usernameController,
                          decoration: CustomWidgetsTheme.primaryInputDecoration(
                            hintText: 'اسم المستخدم',
                            prefixIcon: Icon(
                              Icons.person_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: controller.passwordController,
                          decoration: CustomWidgetsTheme.primaryInputDecoration(
                            hintText: 'كلمة المرور',
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (value) async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            controller.logining.value = true;
                            await controller.login();
                            controller.logining.value = false;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Login Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: controller.logining.value
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: colorScheme.primary,
                                    ),
                                  )
                                : FilledButton.icon(
                                    onPressed: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      controller.logining.value = true;
                                      await controller.login();
                                      controller.logining.value = false;
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.login_rounded),
                                    label: const Text(
                                      'تسجيل دخول',
                                      style: TextStyle(
                                        fontFamily: 'ReadexPro',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        
                        // Theme Toggle
                        const SizedBox(height: 16),
                        Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              ThemeController.to.isDarkMode 
                                  ? Icons.dark_mode_rounded 
                                  : Icons.light_mode_rounded,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'المظهر:',
                              style: TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => ThemeController.to.toggleTheme(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ThemeController.to.isDarkMode ? 'داكن' : 'فاتح',
                                  style: TextStyle(
                                    fontFamily: 'ReadexPro',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
