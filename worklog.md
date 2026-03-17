# سجل العمل - MoAmriAccounting Refactoring

---
Task ID: 1
Agent: Super Z (Main Agent)
Task: إصلاح مشاكل التصميم في مستودع MoAmriAccounting

Work Log:
- تم تحليل المشروع وتحديد المشاكل الأربعة الرئيسية
- تم إنشاء هيكلية جديدة منظمة (core/, domain/)
- تم إنشاء نظام معالجة الأخطاء (AppError)
- تم إنشاء Repository Interfaces للمواد والعملاء
- تم إنشاء Services لفصل منطق العمل
- تم تقسيم sale_page.dart (663 سطر) إلى 6 widgets صغيرة

Stage Summary:
- **المشكلة 1**: منطق العمل داخل كلاسات قاعدة البيانات
  - الحل: إنشاء `MaterialService` و `CustomerService` في `lib/domain/services/`
  
- **المشكلة 2**: عدم وجود Repository interfaces
  - الحل: إنشاء `MaterialRepository` و `CustomerRepository` في `lib/domain/repositories/`
  
- **المشكلة 3**: معالجة أخطاء غير منظمة
  - الحل: إنشاء `AppError` في `lib/core/errors/app_error.dart` مع أنواع مختلفة من الأخطاء
  
- **المشكلة 4**: طرق بناء واجهة طويلة (~400 سطر)
  - الحل: تقسيم `sale_page.dart` إلى:
    - `search_section.dart` - قسم البحث
    - `categories_materials_section.dart` - قسم التصنيفات والمواد
    - `sale_data_grid.dart` - جدول البيانات
    - `total_card.dart` - بطاقة الإجمالي
    - `bottom_actions_section.dart` - الإجراءات السفلية
    - `barcode_listener_widget.dart` - مستمع الباركود

**الملفات الجديدة:**
```
lib/
├── core/
│   └── errors/
│       ├── app_error.dart
│       └── index.dart
├── domain/
│   ├── repositories/
│   │   ├── material_repository.dart
│   │   ├── customer_repository.dart
│   │   └── index.dart
│   └── services/
│       ├── material_service.dart
│       ├── customer_service.dart
│       └── index.dart
└── sale/
    └── widgets/
        ├── search_section.dart
        ├── categories_materials_section.dart
        ├── sale_data_grid.dart
        ├── total_card.dart
        ├── bottom_actions_section.dart
        ├── barcode_listener_widget.dart
        └── index.dart
```

---
Task ID: 2
Agent: Super Z (Main Agent)
Task: إعادة تصميم التطبيق محاسبي من الصفر (UI/UX Redesign)

Work Log:
- تم إنشاء نظام ألوان احترافي جديد (AppPalette) بألوان Deep Blue و Slate Gray
- تم إنشاء نظام تصميم متكامل (AppDesignSystem) مع Material 3
- تم إنشاء Reusable Widgets للحقول والأزرار
- تم تصميم Dashboard جديد مع ملخص الحسابات
- تم تصميم شاشة فاتورة جديدة متكاملة

Stage Summary:
- **الهوية البصرية الجديدة**:
  - `app_palette.dart`: لوحة ألوان احترافية مع:
    - Primary: Deep Blue (#1A5F7A)
    - Secondary: Slate Gray (#4A5568)
    - Income/Expense/Warning colors
    - Currency colors (ريال/دولار)
  - `app_design_system.dart`: نظام تصميم Material 3 كامل مع:
    - Typography باستخدام خط Cairo
    - Light/Dark themes
    - Component themes (buttons, inputs, cards, etc.)
    - Spacing and border radius constants

- **Reusable Widgets**:
  - `form_fields.dart`:
    - AppTextField - حقل نصي موحد
    - AppCurrencyField - حقل عملة مع تنسيق تلقائي
    - AppQuantityField - حقل كمية مع أزرار +/-
    - AppDropdownField - قائمة منسدلة موحدة
  - `buttons.dart`:
    - AppPrimaryButton - زر رئيسي
    - AppSecondaryButton - زر ثانوي
    - AppDangerButton - زر خطر
    - AppIconButton - زر أيقونة
    - AppFAB - زر عائم
  - `dashboard_widgets.dart`:
    - StatCard - بطاقة إحصائية
    - FinancialSummaryCard - ملخص مالي
    - QuickActionButton - زر إجراء سريع
    - RecentTransactionItem - عنصر معاملة

- **الشاشات الجديدة**:
  - `dashboard_page.dart`: لوحة تحكم حديثة مع:
    - ملخص يومي للمبيعات والمصروفات
    - إجراءات سريعة
    - ملخص مالي شهري
    - آخر المعاملات
    - تصميم متجاوب
  - `invoice_page.dart`: شاشة فاتورة جديدة مع:
    - البحث عن عميل
    - البحث عن منتج/مسح باركود
    - قائمة منتجات تفاعلية
    - طرق دفع متعددة (نقدي/آجل/بطاقة)
    - اختيار العملة
    - ملخص الفاتورة
    - تصميم متجاوب للجوال والحاسوب

**الملفات الجديدة للمرحلة الثانية:**
```
lib/
├── shared/
│   ├── theme/
│   │   ├── app_palette.dart
│   │   ├── app_design_system.dart
│   │   └── index.dart
│   └── widgets/
│       ├── form_fields.dart
│       ├── buttons.dart
│       ├── dashboard_widgets.dart
│       └── index.dart
└── features/
    ├── dashboard/
    │   └── dashboard_page.dart
    └── invoice/
        └── invoice_page.dart
```

---
Task ID: 3
Agent: Super Z (Main Agent)
Task: تصميم شاشات المخزون والعملاء والمصروفات والديون

Work Log:
- تم تصميم شاشة المخزون (InventoryPage) مع:
  - ملخص سريع (إجمالي المنتجات، نفذ من المخزون، مخزون منخفض)
  - قيمة المخزون الإجمالية
  - بحث بالاسم أو الباركود
  - تصفية حسب التصنيف
  - عرض شبكي/قائمة
  - تنبيهات المنتجات المنخفضة والنافذة
  - بطاقات منتجات تفاعلية
- تم تصميم شاشة العملاء (CustomersPage) مع:
  - ملخص العملاء (إجمالي، بديون، إجمالي الديون)
  - بحث بالاسم أو الهاتف
  - تصفية (الكل، بديون، نشطون)
  - بطاقات عملاء مع تفاصيل الديون
  - نموذج إضافة عميل سريع
- تم تصميم شاشة المصروفات (ExpensesPage) مع:
  - ملخص يومي/أسبوعي/شهري
  - تحليل المصروفات حسب التصنيف
  - شريط تقدم لكل تصنيف
  - سجل المصروفات مع تصفية
  - نموذج إضافة مصروف سريع
- تم تصميم شاشة الديون (DebtsPage) مع:
  - تبويبات (ديون لك / ديون عليك)
  - ملخص الديون المستحقة والمتأخرات
  - تصفية (الكل، متأخرات، مستحق قريباً، مسدد)
  - بطاقات ديون مع شريط تقدم السداد
  - نموذج تسجيل دفع سريع

Stage Summary:
- **شاشة المخزون**:
  - عرض شبكي وقائمة قابل للتبديل
  - تصنيفات المنتجات
  - تنبيهات المخزون المنخفض والنافذ
  - بطاقات منتجات مع ألوان حسب الحالة

- **شاشة العملاء**:
  - بطاقات عملاء مع معلومات الديون
  - مؤشر آخر عملية شراء
  - إجراءات سريعة (فاتورة جديدة، تسديد دين)

- **شاشة المصروفات**:
  - تصنيفات مصروفات ملونة
  - شريط تقدم نسبة كل تصنيف
  - تصفية حسب الفترة الزمنية

- **شاشة الديون**:
  - تبويبات ديون مستحقة / ديون عليك
  - شريط تقدم السداد
  - تنبيه المتأخرات
  - نموذج دفع سريع مع طرق دفع

**الملفات الجديدة للمرحلة الثالثة:**
```
lib/
└── features/
    ├── inventory/
    │   ├── inventory_page.dart
    │   └── index.dart
    ├── customers/
    │   ├── customers_page.dart
    │   └── index.dart
    ├── expenses/
    │   ├── expenses_page.dart
    │   └── index.dart
    └── debts/
        ├── debts_page.dart
        └── index.dart
```

**الهيكل الكامل للمشروع بعد التحديث:**
```
lib/
├── core/
│   └── errors/
├── domain/
│   ├── repositories/
│   └── services/
├── shared/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── dashboard/
│   ├── invoice/
│   ├── inventory/
│   ├── customers/
│   ├── expenses/
│   └── debts/
└── sale/
    └── widgets/
```

---
Task ID: 4
Agent: Super Z (Main Agent)
Task: ربط قاعدة البيانات وإنشاء التقارير والإشعارات

Work Log:
- تم إنشاء Controllers لربط الشاشات بقاعدة البيانات:
  - InventoryController: لإدارة المخزون
  - CustomersController: لإدارة العملاء
  - ExpensesController: لإدارة المصروفات
  - DebtsController: لإدارة الديون
- تم إنشاء شاشة التقارير المتقدمة (ReportsPage) مع:
  - ملخص مالي شامل
  - رسوم بيانية للمبيعات والمصروفات
  - تحليل التصنيفات
  - أكثر المنتجات مبيعاً
  - تصفية حسب الفترة الزمنية
- تم إنشاء نظام الإشعارات المتكامل:
  - NotificationsController: للتحكم في الإشعارات
  - NotificationsPage: صفحة عرض الإشعارات
  - NotificationsBadge: شارة عرض عدد الإشعارات الجديدة
  - أنواع الإشعارات: نفاد مخزون، مخزون منخفض، ديون متأخرة

Stage Summary:
- **Controllers للربط بقاعدة البيانات**:
  - `inventory_controller.dart`:
    - تحميل المواد مع Pagination
    - البحث والتصفية
    - إضافة/تعديل/حذف المواد
    - حساب قيمة المخزون
  - `customers_controller.dart`:
    - تحميل العملاء مع الديون
    - البحث والتصفية
    - إضافة/تعديل/حذف العملاء
    - حساب إجمالي الديون
  - `expenses_controller.dart`:
    - تحميل المصروفات
    - تصفية حسب الفترة والتصنيف
    - إحصائيات يومية/أسبوعية/شهرية
    - تحليل حسب التصنيف
  - `debts_controller.dart`:
    - تحميل الديون المستحقة والمطلوبة
    - تسجيل الدفعات
    - تصفية حسب الحالة
    - حساب الإجماليات

- **شاشة التقارير**:
  - بطاقات ملخص (مبيعات، مشتريات، مصروفات، ربح)
  - رسم بياني للمبيعات اليومية
  - رسم بياني للمصروفات
  - تحليل المبيعات حسب التصنيف
  - قائمة أكثر المنتجات مبيعاً
  - تصدير PDF وطباعة

- **نظام الإشعارات**:
  - فحص تلقائي للمخزون المنخفض والنافذ
  - فحص الديون المتأخرة والمستحقة قريباً
  - شارة عرض عدد الإشعارات الجديدة
  - إمكانية تحديد الكل كمقروء
  - إجراءات سريعة لكل إشعار

**الملفات الجديدة للمرحلة الرابعة:**
```
lib/
├── services/
│   └── notifications_controller.dart
└── features/
    ├── inventory/
    │   └── inventory_controller.dart
    ├── customers/
    │   └── customers_controller.dart
    ├── expenses/
    │   └── expenses_controller.dart
    ├── debts/
    │   └── debts_controller.dart
    ├── reports/
    │   └── reports_page.dart
    └── notifications/
        └── notifications_page.dart
```

**الهيكل النهائي الكامل للمشروع:**
```
lib/
├── core/
│   └── errors/
│       ├── app_error.dart
│       └── index.dart
├── domain/
│   ├── repositories/
│   │   ├── material_repository.dart
│   │   ├── customer_repository.dart
│   │   └── index.dart
│   └── services/
│       ├── material_service.dart
│       ├── customer_service.dart
│       └── index.dart
├── shared/
│   ├── theme/
│   │   ├── app_palette.dart
│   │   ├── app_design_system.dart
│   │   └── index.dart
│   └── widgets/
│       ├── form_fields.dart
│       ├── buttons.dart
│       ├── dashboard_widgets.dart
│       └── index.dart
├── services/
│   └── notifications_controller.dart
├── features/
│   ├── dashboard/
│   │   └── dashboard_page.dart
│   ├── invoice/
│   │   └── invoice_page.dart
│   ├── inventory/
│   │   ├── inventory_page.dart
│   │   └── inventory_controller.dart
│   ├── customers/
│   │   ├── customers_page.dart
│   │   └── customers_controller.dart
│   ├── expenses/
│   │   ├── expenses_page.dart
│   │   └── expenses_controller.dart
│   ├── debts/
│   │   ├── debts_page.dart
│   │   └── debts_controller.dart
│   ├── reports/
│   │   └── reports_page.dart
│   └── notifications/
│       └── notifications_page.dart
├── database/
│   └── ... (الملفات الأصلية)
├── controllers/
│   └── main_controller.dart
└── sale/
    └── widgets/
        └── ... (الـ widgets المقسمة)
```

**إحصائيات المشروع:**
- إجمالي الملفات الجديدة: 25+ ملف
- Controllers: 5
- Pages: 7
- Widgets: 15+
- Services: 3
- Repository Interfaces: 2
- Error Types: 6

---
Task ID: 5
Agent: Super Z (Main Agent)
Task: إلغاء الباركود، Caching، والنسخ الاحتياطي

Work Log:
- تم إلغاء نظام الباركود من التطبيق:
  - حذف ملف `barcode_listener_widget.dart`
  - إزالة الاستيراد من `sale_page.dart`
  - إزالة من `index.dart`
- تم إنشاء نظام Caching محسن:
  - `cache_service.dart`: خدمة التخزين المؤقت
  - دعم TTL (Time To Live)
  - تخزين البيانات المتكررة لتحسين الأداء
- تم إنشاء نظام النسخ الاحتياطي:
  - `backup_service.dart`: خدمة النسخ الاحتياطي
  - `backup_page.dart`: شاشة إدارة النسخ الاحتياطية
  - إنشاء/استعادة/حذف/تصدير النسخ الاحتياطية

Stage Summary:
- **إلغاء نظام الباركود**:
  - حذف `barcode_listener_widget.dart`
  - إزالة من `sale/widgets/index.dart`
  - تبسيط شاشة البيع

- **نظام Caching**:
  - `CacheService`:
    - تخزين مع TTL قابل للتخصيص
    - دعم البيانات الفردية والقوائم
    - تنظيف تلقائي للبيانات المنتهية
    - مفاتيح ثابتة للبيانات الشائعة
  - `CacheKeys`: مفاتيح موحدة للـ Cache
  - `CacheDurations`: مدد زمنية موحدة

- **نظام النسخ الاحتياطي**:
  - `BackupService`:
    - إنشاء نسخ احتياطية من قاعدة البيانات
    - استعادة النسخ الاحتياطية
    - حذف وتصدير النسخ
    - تنظيف تلقائي للنسخ القديمة
    - الاحتفاظ بـ 10 نسخ كحد أقصى
  - `BackupPage`:
    - واجهة حديثة لإدارة النسخ
    - إحصائيات النسخ الاحتياطية
    - أزرار إنشاء واستيراد
    - قائمة النسخ المحفوظة
    - خيارات استعادة/تصدير/حذف لكل نسخة

**الملفات الجديدة للمرحلة الخامسة:**
```
lib/
├── services/
│   ├── cache_service.dart
│   └── backup_service.dart
└── features/
    └── backup/
        ├── backup_page.dart
        └── index.dart
```

**الملفات المحذوفة:**
```
lib/sale/widgets/barcode_listener_widget.dart
```

**الهيكل النهائي الكامل للمشروع:**
```
lib/
├── core/
│   └── errors/
│       ├── app_error.dart
│       └── index.dart
├── domain/
│   ├── repositories/
│   │   ├── material_repository.dart
│   │   ├── customer_repository.dart
│   │   └── index.dart
│   └── services/
│       ├── material_service.dart
│       ├── customer_service.dart
│       └── index.dart
├── shared/
│   ├── theme/
│   │   ├── app_palette.dart
│   │   ├── app_design_system.dart
│   │   └── index.dart
│   └── widgets/
│       ├── form_fields.dart
│       ├── buttons.dart
│       ├── dashboard_widgets.dart
│       └── index.dart
├── services/
│   ├── notifications_controller.dart
│   ├── cache_service.dart
│   └── backup_service.dart
├── features/
│   ├── dashboard/
│   │   └── dashboard_page.dart
│   ├── invoice/
│   │   └── invoice_page.dart
│   ├── inventory/
│   │   ├── inventory_page.dart
│   │   └── inventory_controller.dart
│   ├── customers/
│   │   ├── customers_page.dart
│   │   └── customers_controller.dart
│   ├── expenses/
│   │   ├── expenses_page.dart
│   │   └── expenses_controller.dart
│   ├── debts/
│   │   ├── debts_page.dart
│   │   └── debts_controller.dart
│   ├── reports/
│   │   └── reports_page.dart
│   ├── notifications/
│   │   └── notifications_page.dart
│   └── backup/
│       ├── backup_page.dart
│       └── index.dart
├── database/
│   └── ... (الملفات الأصلية)
├── controllers/
│   └── main_controller.dart
└── sale/
    └── widgets/
        └── ... (الـ widgets المقسمة بدون الباركود)
```

**إحصائيات المشروع النهائية:**
- إجمالي الملفات الجديدة: 35+ ملف
- Controllers: 6
- Pages: 8
- Widgets: 20+
- Services: 4
- Repository Interfaces: 2
- Error Types: 6
- Notification Types: 5

---
Task ID: 6
Agent: Super Z (Main Agent)
Task: إضافة شاشة الموردين وتحسين التقارير والإعدادات

Work Log:
- تم إنشاء شاشة الموردين المتكاملة مع:
  - بيانات الاتصال (اسم، هاتف، عنوان، بريد)
  - تتبع كشف الحساب (الديون والمدفوعات)
  - حركات المورد (شراء، سداد، مرتجع)
  - تصفية حسب حالة الرصيد
  - إحصائيات الديون الإجمالية
- تم تحسين شاشة التقارير مع:
  - تبويبات متعددة (المبيعات والأرباح، حركة الصندوق، ديون العملاء، ديون الموردين)
  - تقارير المبيعات والأرباح (يومية، أسبوعية، شهرية، سنوية)
  - حركة الصندوق (الوارد والصادر)
  - تقارير ديون العملاء والموردين
  - رسوم بيانية تفاعلية
- تم إنشاء شاشة الإعدادات الشاملة مع:
  - بيانات المؤسسة (اسم، شعار، رقم ضريبي)
  - إعدادات الطابعة (نوع، حجم الورق، طباعة تلقائية)
  - النسخ الاحتياطي (تلقائي، يدوي، Google Drive)
- تم تحديث home_page.dart للتنقل بين الشاشات الجديدة

Stage Summary:
- **شاشة الموردين**:
  - `supplier.dart`: Entity للمورد مع حساب الرصيد
  - `suppliers_database.dart`: عمليات قاعدة البيانات
  - `suppliers_controller.dart`: إدارة الحالة
  - `suppliers_page.dart`: واجهة المستخدم
  - ميزات:
    - إضافة/تعديل/حذف الموردين
    - تتبع الحركات المالية
    - سداد الديون
    - تصفية وبحث

- **تحسين شاشة التقارير**:
  - 4 تبويبات رئيسية
  - تقارير المبيعات والأرباح
  - حركة الصندوق (وارد/صادر)
  - ديون العملاء مع تفاصيل
  - ديون الموردين مع تفاصيل
  - تصفية حسب الفترة الزمنية
  - تصدير PDF وطباعة

- **شاشة الإعدادات**:
  - قسم بيانات المؤسسة:
    - تحميل شعار الشركة
    - اسم المحل والفرع
    - الرقم الضريبي
    - معلومات الاتصال
  - قسم إعدادات الطابعة:
    - نوع الطابعة (حرارية/عادية)
    - حجم الورق (58مم/80مم)
    - طباعة تلقائية
    - عدد النسخ
  - قسم النسخ الاحتياطي:
    - نسخ احتياطي تلقائي
    - تكرار (يومي/أسبوعي/شهري)
    - مكان الحفظ (جهاز/Google Drive)
    - إدارة النسخ المحفوظة

**الملفات الجديدة للمرحلة السادسة:**
```
lib/
├── database/
│   ├── entities/
│   │   └── supplier.dart
│   └── suppliers_database.dart
└── features/
    ├── suppliers/
    │   ├── suppliers_controller.dart
    │   ├── suppliers_page.dart
    │   └── index.dart
    ├── reports/
    │   └── reports_page.dart (محدثة)
    └── settings/
        ├── settings_page.dart
        └── index.dart
```

**الملفات المحدثة:**
```
lib/pages/home_page.dart (إضافة التنقل للشاشات الجديدة)
```

**الهيكل النهائي الكامل للمشروع:**
```
lib/
├── core/
│   └── errors/
├── domain/
│   ├── repositories/
│   └── services/
├── shared/
│   ├── theme/
│   └── widgets/
├── services/
│   ├── notifications_controller.dart
│   ├── cache_service.dart
│   └── backup_service.dart
├── features/
│   ├── dashboard/
│   ├── invoice/
│   ├── inventory/
│   ├── customers/
│   ├── expenses/
│   ├── debts/
│   ├── reports/
│   ├── notifications/
│   ├── backup/
│   ├── suppliers/
│   └── settings/
├── database/
│   ├── entities/
│   │   ├── customer.dart
│   │   ├── supplier.dart
│   │   └── ... (أخرى)
│   ├── suppliers_database.dart
│   └── ... (أخرى)
├── controllers/
└── sale/
    └── widgets/
```

**إحصائيات المشروع النهائية:**
- إجمالي الملفات: 45+ ملف
- Controllers: 7
- Pages: 10
- Widgets: 25+
- Services: 4
- Database Entities: 10+
- Repository Interfaces: 2

---
Task ID: 7
Agent: Super Z (Main Agent)
Task: تحسين إدارة العملاء مع كشوف الحسابات وحركات السداد

Work Log:
- تم إنشاء CustomerTransaction entity لحركات العميل المالية
- تم إنشاء CustomerTransactionsDatabase لإدارة الحركات
- تم تحسين CustomersController مع كشوف الحسابات الكاملة
- تم إعادة تصميم CustomersPage مع تفاصيل العميل وحركاته
- تم إنشاء CustomerReportPage لتقرير العميل الشامل

Stage Summary:
- **CustomerTransaction Entity**:
  - أنواع الحركات: فاتورة بيع، سداد، مرتجع، رصيد افتتاحي
  - حساب الرصيد بعد كل حركة
  - ألوان وأيقونات لكل نوع حركة

- **CustomerTransactionsDatabase**:
  - إضافة حركات مع تحديث رصيد العميل تلقائياً
  - كشف حساب العميل مع تصفية بالفترة
  - إحصائيات يومية للمبيعات والسداد
  - الديون المتأخرة والمستحقة
  - البحث في العملاء

- **CustomersController المحسن**:
  - تحميل العملاء مع أرصدتهم
  - البحث والتصفية (بالديون/بدون ديون)
  - تسجيل السداد من العميل
  - تسجيل الرصيد الافتتاحي
  - كشف حساب مفصل

- **CustomersPage الجديدة**:
  - قائمة العملاء مع أرصدتهم
  - إحصائيات (إجمالي الديون، عملاء بديون، سداد اليوم)
  - لوحة تفاصيل العميل:
    - بيانات الاتصال
    - الرصيد الحالي
    - كشف الحساب
    - آخر الحركات
    - أزرار إجراءات (سداد، فاتورة، تعديل، تقرير)

- **CustomerReportPage**:
  - تبويبان (كشف الحساب / سجل الحركات)
  - اختيار الفترة الزمنية
  - جدول كشف حساب (مدين/دائن/الرصيد)
  - ملخص الحركات (فواتير، سداد، مراجع)
  - تصدير PDF وطباعة

**الملفات الجديدة للمرحلة السابعة:**
```
lib/
├── database/
│   ├── entities/
│   │   └── customer_transaction.dart
│   └── customer_transactions_database.dart
└── features/
    └── customers/
        ├── customers_controller.dart (محدث)
        ├── customers_page.dart (محدث)
        ├── customer_report_page.dart (جديد)
        └── index.dart (محدث)
```

**الميزات الجديدة:**
- تتبع كامل لحركات العميل
- كشف حساب مفصل مع تصفية بالفترة
- تسجيل السداد من العميل
- الرصيد الافتتاحي للعملاء الجدد
- تقرير شامل للعميل
- إحصائيات يومية للمبيعات والسداد

**إحصائيات المشروع النهائية:**
- إجمالي الملفات: 50+ ملف
- Controllers: 7
- Pages: 11
- Widgets: 25+
- Services: 4
- Database Entities: 12
- Repository Interfaces: 2
