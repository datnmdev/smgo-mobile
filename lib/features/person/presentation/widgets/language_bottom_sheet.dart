import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/features/person/domain/entities/language_entity.dart';

class LanguageBottomSheet extends StatefulWidget {
  final String selectedCode;
  final bool isSubmitting;
  final Function(LanguageEntity language)? onSelected;

  const LanguageBottomSheet({
    super.key,
    this.selectedCode = 'vi',
    this.isSubmitting = false,
    this.onSelected,
  });

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  final List<LanguageEntity> _languages = appLanguages;

  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.selectedCode;
  }

  @override
  void didUpdateWidget(covariant LanguageBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCode != widget.selectedCode) {
      setState(() {
        _selectedCode = widget.selectedCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Khóa cử chỉ vuốt/back hệ thống khi isSubmitting = true
    return PopScope(
      canPop: !widget.isSubmitting,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh gạch xám trên cùng (Drag Handle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Icon + Tiêu đề + Mô tả
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xE8EFE8FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.language,
                      color: Color(0xFF00B14F),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.lBSSelectLanguageTitle.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.lBSSelectLanguageContent.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Danh sách ngôn ngữ (Khóa chạm chọn khi đang submitting)
              AbsorbPointer(
                absorbing: widget.isSubmitting,
                child: Column(
                  children: _languages.map((lang) {
                    final isSelected = lang.code == _selectedCode;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCode = lang.code;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF0FDF4)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(
                                    0xFF00B14F,
                                  ).withAlpha((0.3 * 255).round())
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              lang.flagEmoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.nativeName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lang.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00B14F)
                                      : Colors.grey.shade400,
                                  width: isSelected ? 6 : 1.5,
                                ),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Nút Xác nhận
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.isSubmitting
                      ? null
                      : () {
                          final selectedLang = _languages.firstWhere(
                            (element) => element.code == _selectedCode,
                          );
                          if (widget.onSelected != null) {
                            widget.onSelected!(selectedLang);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    disabledBackgroundColor: const Color(
                      0xFF00B14F,
                    ).withAlpha((0.6 * 255).round()),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: widget.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          AppStrings.lBSConfirmButtonTitle.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
