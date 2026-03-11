import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../services/biometric_service.dart';
import '../theme/custom_widgets_theme.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final biometricService = BiometricService.to;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    _buildLogoSection(colorScheme),
                    
                    const SizedBox(height: 32),
                    
                    // Login Card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
                                Text(
                                  'تسجيل الدخول',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'ReadexPro',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'أدخل بياناتك للوصول إلى حسابك',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'ReadexPro',
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
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
                                    height: 50,
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
                                
                                // Biometric Login Section
                                Obx(() {
                                  if (!biometricService.isBiometricAvailable || 
                                      !biometricService.hasSavedCredentials) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  return Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      
                                      // Divider with text
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: colorScheme.outlineVariant,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              'أو',
                                              style: TextStyle(
                                                fontFamily: 'ReadexPro',
                                                fontSize: 12,
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: colorScheme.outlineVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Biometric Button
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final result = await biometricService.authenticate(
                                            localizedReason: 'استخدم ${biometricService.getBiometricTypeName()} لتسجيل الدخول',
                                          );
                                          
                                          if (result.success) {
                                            // Get saved credentials
                                            final credentials = await biometricService.getSavedCredentials();
                                            if (credentials != null) {
                                              controller.usernameController.text = credentials['username']!;
                                              controller.passwordController.text = credentials['password']!;
                                              
                                              // Auto login
                                              controller.logining.value = true;
                                              await controller.login();
                                              controller.logining.value = false;
                                            }
                                          } else {
                                            // Show error
                                            Get.snackbar(
                                              'فشل المصادقة',
                                              result.message,
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: colorScheme.errorContainer,
                                              colorText: colorScheme.onErrorContainer,
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: colorScheme.primary,
                                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        icon: Icon(biometricService.getBiometricIcon()),
                                        label: Text(
                                          'تسجيل الدخول بـ ${biometricService.getBiometricTypeName()}',
                                          style: const TextStyle(
                                            fontFamily: 'ReadexPro',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                
                                // Enable Biometric Option (after first login)
                                Obx(() {
                                  if (!biometricService.isBiometricAvailable || 
                                      biometricService.hasSavedCredentials) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  return Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      
                                      // Enable biometric checkbox
                                      InkWell(
                                        onTap: () => biometricService.setBiometricEnabled(
                                          !biometricService.isBiometricEnabled,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: biometricService.isBiometricEnabled,
                                                onChanged: (value) => biometricService.setBiometricEnabled(value ?? false),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                biometricService.getBiometricIcon(),
                                                size: 20,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'تفعيل ${biometricService.getBiometricTypeName()} لتسجيل الدخول',
                                                  style: TextStyle(
                                                    fontFamily: 'ReadexPro',
                                                    fontSize: 13,
                                                    color: colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Theme Toggle
                    Obx(() => Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ThemeController.to.isDarkMode 
                                    ? Icons.dark_mode_rounded 
                                    : Icons.light_mode_rounded,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'المظهر:',
                                style: TextStyle(
                                  fontFamily: 'ReadexPro',
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => ThemeController.to.toggleTheme(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ThemeController.to.isDarkMode ? 'داكن' : 'فاتح',
                                    style: TextStyle(
                                      fontFamily: 'ReadexPro',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                    
                    const SizedBox(height: 24),
                    
                    // Version info
                    Text(
                      'الإصدار 1.0.0',
                      style: TextStyle(
                        fontFamily: 'ReadexPro',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(ColorScheme colorScheme) {
    return Column(
      children: [
        // Logo Container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.calculate_rounded,
            size: 50,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),
        
        // App Name
        Text(
          'محاسبي',
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tagline
        Text(
          'نظام المحاسبة المتكامل',
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
