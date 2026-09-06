import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/person/presentation/bloc/update_profile_form/update_profile_form_cubit.dart';
import 'package:smgo/features/person/presentation/bloc/update_profile_form/update_profile_form_state.dart';
import 'package:smgo/features/person/presentation/widgets/avatar_uploader.dart';
import 'package:smgo/shared/domain/entities/user_entity.dart';
import 'package:smgo/shared/domain/usecases/get_upload_url_usecase.dart';
import 'package:smgo/shared/domain/usecases/upload_media_usecase.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:smgo/shared/presentation/widgets/m3_error_text.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';

class UpdateProfileBottomSheet extends StatefulWidget {
  final BuildContext context;
  final UserEntity? profile;
  const UpdateProfileBottomSheet({
    required this.profile,
    super.key,
    required this.context,
  });

  static Future<void> show(BuildContext context, {UserEntity? profile}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: UpdateProfileBottomSheet(profile: profile, context: context),
      ),
    );
  }

  @override
  State<UpdateProfileBottomSheet> createState() =>
      _UpdateProfileBottomSheetState();
}

class _UpdateProfileBottomSheetState extends State<UpdateProfileBottomSheet> {
  late UpdateProfileFormCubit _updateProfileFormCubit;
  late TextEditingController _nameController;
  late UserEntity? _profile;

  @override
  void initState() {
    super.initState();
    _updateProfileFormCubit = di<UpdateProfileFormCubit>();
    _profile = widget.profile;

    _nameController = TextEditingController(text: _profile?.name ?? '');

    _updateProfileFormCubit.nameInputChanged(_profile?.name ?? '');
    _updateProfileFormCubit.avatarChanged(_profile?.avatar);
  }

  @override
  void didUpdateWidget(covariant UpdateProfileBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      setState(() {
        _profile = widget.profile;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _updateProfileFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocProvider.value(
      value: _updateProfileFormCubit,
      child: BlocConsumer<UpdateProfileFormCubit, UpdateProfileFormState>(
        listener: (_, state) {
          if (state is UpdateProfileFormDone) {
            widget.context.read<GetProfileCubit>().call();
            context.pop();
            AppDialogUtils.showSuccess(
              context: widget.context,
              title: 'Cập nhật hồ sơ thành công!',
            );
          } else if (state is UpdateProfileFormFailed) {
            AppDialogUtils.showSuccess(
              context: widget.context,
              title: 'Cập nhật hồ sơ thất bại!',
              subtitle: 'Đã xảy ra lỗi. Vui lòng thử lại.',
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is UpdateProfileFormLoading;

          return PopScope(
            canPop: !isSubmitting,
            child: Container(
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Thanh kéo (Drag Indicator)
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // 2. Header: Tiêu đề + Nút đóng X
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cập nhật thông tin cá nhân',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            child: Icon(
                              Icons.close,
                              color: isSubmitting ? Colors.grey : Colors.green,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 3. Mô tả
                      Text(
                        'Cập nhật thông tin để mọi người dễ dàng nhận diện bạn hơn.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Nội dung cuộn chính (Avatar + Input)
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ảnh đại diện',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),

                              AvatarUploader(
                                previewUrl: _profile?.avatarUrl,
                                defaultAvatarAsset: AppAssets.defaultAvatar,
                                onPickImage: (File file) async {
                                  final uploadUrlDataState =
                                      await di<GetUploadUrlUsecase>().call();
                                  if (uploadUrlDataState is DataSuccess) {
                                    final fileBytes = await file.readAsBytes();
                                    await di<UploadMediaUsecase>().call(
                                      params: UploadMediaParams(
                                        presignedUploadUrl:
                                            uploadUrlDataState.data!.uploadUrl,
                                        mimeType:
                                            lookupMimeType(file.path) ??
                                            'application/octet-stream',
                                        fileBytes: fileBytes,
                                      ),
                                    );

                                    _updateProfileFormCubit.avatarChanged(
                                      uploadUrlDataState.data?.mediaId,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 8),

                              Center(
                                child: Text(
                                  'Nhấn vào ảnh để thay đổi',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              const Text(
                                'Họ và tên',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                enabled: !isSubmitting,
                                onChanged: (value) => _updateProfileFormCubit
                                    .nameInputChanged(value),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF008744),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF008744),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF008744),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tên hiển thị sẽ được sử dụng trong ứng dụng SmGo.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (state.nameInput.displayError != null) ...[
                                const SizedBox(height: 6),
                                const M3ErrorText(
                                  errorText: 'Trường này không được bỏ trống',
                                ),
                              ],
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      // 5. Thắt chặt phần nút bấm ở chân giao diện
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF008744),
                                  side: const BorderSide(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        _updateProfileFormCubit.submit();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF008744),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Lưu thay đổi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
