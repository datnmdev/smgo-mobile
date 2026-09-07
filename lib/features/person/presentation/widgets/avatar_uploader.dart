import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';

class AvatarUploader extends StatefulWidget {
  final String? previewUrl;
  final String defaultAvatarAsset;
  final Future<void> Function(File imageFile) onPickImage;
  final double size;

  const AvatarUploader({
    super.key,
    this.previewUrl,
    required this.defaultAvatarAsset,
    required this.onPickImage,
    this.size = 100,
  });

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  final ImagePicker _picker = ImagePicker();

  File? _selectedLocalImage;
  bool _isLoading = false;

  Future<void> _handlePickImage(ImageSource source) async {
    Navigator.of(context).pop(); // Đóng BottomSheet

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      setState(() {
        _selectedLocalImage = file;
        _isLoading = true;
      });

      await widget.onPickImage(file);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.aUErrorPickImageContent.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    }
  }

  void _showImageSourceBottomSheet() {
    final lightTheme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      // Bỏ showDragHandle mặc định để dùng thanh kéo custom
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return Theme(
          data: lightTheme,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thanh kéo Custom (Drag Indicator)
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Danh sách lựa chọn
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.black87),
                  title: Text(
                    AppStrings.aUTakeNewPhotoLabel.tr(),
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () => _handlePickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.black87,
                  ),
                  title: Text(
                    AppStrings.aUSelectFromGalleryLabel.tr(),
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () => _handlePickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarImage() {
    if (_selectedLocalImage != null) {
      return Image.file(
        _selectedLocalImage!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    if (widget.previewUrl != null && widget.previewUrl!.isNotEmpty) {
      return Image.network(
        widget.previewUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(widget.defaultAvatarAsset, fit: BoxFit.cover);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return Image.asset(widget.defaultAvatarAsset, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildAvatarImage(),
                  if (_isLoading)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _isLoading ? null : _showImageSourceBottomSheet,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF008744),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
