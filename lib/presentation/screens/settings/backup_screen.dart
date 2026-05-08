import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExporting = false;
  bool _isImporting = false;
  String? _exportResult;
  final _importCtrl = TextEditingController();
  String _importStatus = '';
  bool _importSuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importCtrl.dispose();
    super.dispose();
  }

  Future<void> _doExport() async {
    setState(() {
      _isExporting = true;
      _exportResult = null;
    });
    try {
      final provider = context.read<AppProvider>();
      final result = await provider.exportBackup();
      setState(() {
        _exportResult = result;
        _isExporting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb
                ? 'تم تصدير البيانات بنجاح - انسخ النص أدناه'
                : 'تم حفظ النسخة الاحتياطية في: $result'),
            backgroundColor: AppColors.statusCompleted,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التصدير: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _doImport() async {
    final text = _importCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _importStatus = 'الرجاء لصق نص النسخة الاحتياطية';
        _importSuccess = false;
      });
      return;
    }

    // Validate JSON
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        setState(() {
          _importStatus = 'ملف النسخة الاحتياطية غير صالح';
          _importSuccess = false;
        });
        return;
      }
    } catch (_) {
      setState(() {
        _importStatus = 'صيغة JSON غير صحيحة';
        _importSuccess = false;
      });
      return;
    }

    // Confirm
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() {
      _isImporting = true;
      _importStatus = '';
    });

    try {
      final provider = context.read<AppProvider>();
      await provider.importBackup(text);
      setState(() {
        _isImporting = false;
        _importStatus = 'تم استيراد البيانات بنجاح!';
        _importSuccess = true;
        _importCtrl.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم استعادة البيانات بنجاح'),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _importStatus = 'خطأ في الاستيراد: $e';
        _importSuccess = false;
      });
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.warning_rounded, color: AppColors.priorityMedium),
                const SizedBox(width: 8),
                const Text('تحذير'),
              ],
            ),
            content: const Text(
              'سيتم حذف جميع البيانات الحالية واستبدالها بالنسخة الاحتياطية.\n\nهل تريد المتابعة؟',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed),
                child: const Text('متابعة',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('النسخ الاحتياطي والاستعادة',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textPrimary)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.upload_rounded), text: 'تصدير'),
            Tab(icon: Icon(Icons.download_rounded), text: 'استيراد'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(isDark, cardBg, textPrimary),
          _buildImportTab(isDark, cardBg, textPrimary),
        ],
      ),
    );
  }

  Widget _buildExportTab(bool isDark, Color cardBg, Color textPrimary) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('ما يتم تصديره؟',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textPrimary)),
                ],
              ),
              const SizedBox(height: 12),
              ...[
                'جميع الأهداف وتفاصيلها',
                'جميع المشاريع وبياناتها',
                'جميع المهام مع كل الحقول',
                'جميع المراحل والقوائم التفقدية',
                'سجلات العقبات والأحداث',
                'الأنواع المخصصة',
              ].map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: AppColors.statusCompleted),
                        const SizedBox(width: 8),
                        Text(item,
                            style: TextStyle(
                                fontSize: 13, color: textPrimary)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Export button
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _doExport,
          icon: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.upload_rounded, color: Colors.white),
          label: Text(
            _isExporting ? 'جارٍ التصدير...' : 'تصدير النسخة الاحتياطية',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        ),
        const SizedBox(height: 16),

        // Export result
        if (_exportResult != null && kIsWeb) ...[
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.statusCompleted.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.code_rounded,
                          color: AppColors.statusCompleted, size: 18),
                      const SizedBox(width: 8),
                      Text('البيانات المصدّرة (JSON)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textPrimary)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _exportResult!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم النسخ إلى الحافظة'),
                              backgroundColor: AppColors.statusCompleted,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('نسخ'),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    _exportResult!,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_exportResult != null && !kIsWeb) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.statusCompleted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.statusCompleted.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.statusCompleted, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تم الحفظ بنجاح',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusCompleted)),
                      const SizedBox(height: 4),
                      Text(_exportResult!,
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _exportResult!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم نسخ المسار'),
                          backgroundColor: AppColors.statusCompleted),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),

        // Tips
        _buildTipsCard(isDark, textPrimary, [
          'احتفظ بنسخة احتياطية منتظمة لبياناتك',
          'يمكنك مشاركة ملف JSON بين الأجهزة',
          'استخدم خاصية الاستيراد لاستعادة البيانات',
        ]),
      ],
    );
  }

  Widget _buildImportTab(bool isDark, Color cardBg, Color textPrimary) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Warning card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.priorityMedium.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.priorityMedium.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.priorityMedium, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تنبيه مهم',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.priorityMedium,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      'سيتم حذف جميع البيانات الحالية عند الاستيراد. تأكد من أخذ نسخة احتياطية أولاً.',
                      style: TextStyle(
                          fontSize: 13,
                          color: textPrimary,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // JSON Input
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.code_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('الصق نص النسخة الاحتياطية',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textPrimary)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final data =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          _importCtrl.text = data!.text!;
                        }
                      },
                      icon: const Icon(Icons.paste_rounded, size: 16),
                      label: const Text('لصق'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _importCtrl,
                  maxLines: 8,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '{"version":"1.1.0","goals":[...],...}',
                    hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textHint,
                        fontSize: 12),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkBackground
                        : AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              if (_importCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: TextButton.icon(
                    onPressed: () => setState(() => _importCtrl.clear()),
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    label: const Text('مسح'),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.accentRed),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Status message
        if (_importStatus.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _importSuccess
                  ? AppColors.statusCompleted.withOpacity(0.1)
                  : AppColors.accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _importSuccess
                    ? AppColors.statusCompleted.withOpacity(0.3)
                    : AppColors.accentRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _importSuccess
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: _importSuccess ? AppColors.statusCompleted : AppColors.accentRed,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _importStatus,
                    style: TextStyle(
                        color: _importSuccess
                            ? AppColors.statusCompleted
                            : AppColors.accentRed,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        // Import button
        ElevatedButton.icon(
          onPressed: _isImporting ? null : _doImport,
          icon: _isImporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.download_rounded, color: Colors.white),
          label: Text(
            _isImporting ? 'جارٍ الاستيراد...' : 'استيراد البيانات',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        ),
        const SizedBox(height: 20),

        _buildTipsCard(isDark, textPrimary, [
          'الصق نص JSON من نسخة سابقة',
          'تأكد من صحة الصيغة قبل الاستيراد',
          'ستُحفظ الأنواع المخصصة تلقائياً',
        ]),
      ],
    );
  }

  Widget _buildTipsCard(
      bool isDark, Color textPrimary, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.priorityMedium, size: 18),
              const SizedBox(width: 8),
              Text('نصائح',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                        child: Text(tip,
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
