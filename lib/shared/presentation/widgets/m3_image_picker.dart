import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smgo/core/exceptions/app_exception.dart';
import 'package:smgo/core/resources/app_strings.dart';

/// Model đại diện cho mỗi item ảnh trong lưới
class GridImageItem {
  final String id;
  final String path;
  final bool isUploading;

  const GridImageItem({
    required this.id,
    required this.path,
    this.isUploading = false,
  });

  GridImageItem copyWith({String? id, String? path, bool? isUploading}) {
    return GridImageItem(
      id: id ?? this.id,
      path: path ?? this.path,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class M3ImagePickerGrid extends StatefulWidget {
  final List<GridImageItem> initialImages;
  final Function(List<GridImageItem>)? onImagesChanged;
  final Future<({String id, String path})?> Function(XFile file)? onUploadImage;
  final int maxImages;
  final String takeNewPhotoTitle;
  final String selectFromLibrary;
  final String cameraTitle;
  final String imageLibraryTitle;
  final String Function(String permissionName) requestPermissionText;
  final String Function(String permissionName) requestPermissionContentText;
  final String cancelButtonTitle;
  final String openSettingsButtonTitle;
  final String Function(String content) addImageButtonTitle;
  final bool reset;

  const M3ImagePickerGrid({
    super.key,
    this.initialImages = const [],
    this.onImagesChanged,
    this.onUploadImage,
    this.maxImages = 12,
    this.takeNewPhotoTitle = 'Chụp ảnh mới',
    this.selectFromLibrary = 'Chọn từ thư viện',
    this.cameraTitle = 'Camera',
    this.imageLibraryTitle = 'Ảnh thư viện',
    this.requestPermissionText = _genRequestPermissionText,
    this.requestPermissionContentText = _genRequestPermissionContentText,
    this.cancelButtonTitle = 'Huỷ',
    this.openSettingsButtonTitle = 'Mở Cài đặt',
    this.addImageButtonTitle = _genAddImageButtonTitle,
    this.reset = false,
  });

  @override
  State<M3ImagePickerGrid> createState() => _M3ImagePickerGridState();

  static String _genRequestPermissionText(String permissionName) {
    return 'Yêu cầu quyền $permissionName';
  }

  static String _genRequestPermissionContentText(String permissionName) {
    return 'Ứng dụng cần quyền truy cập $permissionName để chọn ảnh. Vui lòng bật lại quyền này trong Cài đặt.';
  }

  static String _genAddImageButtonTitle(String content) {
    return 'Thêm ảnh ($content)';
  }
}

class _M3ImagePickerGridState extends State<M3ImagePickerGrid> {
  late List<GridImageItem> _images;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  @override
  void didUpdateWidget(M3ImagePickerGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reset == true) {
      setState(() {
        _images.clear();
      });
    }
  }

  // --- XỬ LÝ QUYỀN VÀ NGUỒN ẢNH ---
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (mounted) _showPermissionSettingsDialog(permission);
      return false;
    }

    return false;
  }

  void _showPickerBottomSheet(BuildContext context) {
    if (_images.length >= widget.maxImages) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(widget.takeNewPhotoTitle),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(widget.selectFromLibrary),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. Chụp từ Camera
  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      _handleNewSelectedFiles([photo]);
    }
  }

  // 2. Chọn từ Thư viện
  Future<void> _pickFromGallery() async {
    final List<XFile> selected = await _picker.pickMultiImage();
    if (selected.isNotEmpty) {
      _handleNewSelectedFiles(selected);
    }
  }

  // Xử lý thêm ảnh và upload lên server
  Future<void> _handleNewSelectedFiles(List<XFile> files) async {
    // 1. Kiểm tra giới hạn số lượng ảnh tối đa
    final availableSlots = widget.maxImages - _images.length;
    final filesToProcess = files.take(availableSlots).toList();

    if (filesToProcess.isEmpty) return;

    // 2. Tạo danh sách các item tạm thời (đang upload) và thêm vào state ngay lập tức
    final List<GridImageItem> newTempItems = [];
    final List<Future<void>> uploadFutures = [];

    for (int i = 0; i < filesToProcess.length; i++) {
      final file = filesToProcess[i];
      final tempId = '${DateTime.now().microsecondsSinceEpoch}_${i}_temp';

      final newItem = GridImageItem(
        id: tempId,
        path: file.path,
        isUploading: true,
      );
      newTempItems.add(newItem);

      // Chuẩn bị sẵn tiến trình upload cho từng file
      if (widget.onUploadImage != null) {
        uploadFutures.add(_uploadSingleFile(file, tempId));
      }
    }

    // Cập nhật UI hiển thị tất cả các ảnh đang loading cùng lúc
    setState(() {
      _images.addAll(newTempItems);
    });
    widget.onImagesChanged?.call(_images);

    // 3. Chạy tất cả các tiến trình upload song song
    if (uploadFutures.isNotEmpty) {
      await Future.wait(uploadFutures);
    }
  }

  // Hàm phụ trợ xử lý upload từng file độc lập
  Future<void> _uploadSingleFile(XFile file, String tempId) async {
    try {
      // Thêm timeout 30 giây để tránh việc upload bị treo vô thời hạn khi rớt mạng
      final result = await widget.onUploadImage!(file).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw AppException(
            code: 'TIMEOUT_ERROR',
            message: AppStrings.m3IPGUploadRequestTimeoutErrorMessage.tr(),
          );
        },
      );

      if (result == null) {
        throw AppException(
          code: 'UPLOAD_ERROR',
          message: AppStrings.m3IPGUploadImageFailedErrorMessage.tr(),
        );
      }

      // Tìm vị trí của item tạm trong danh sách hiện tại và cập nhật thành công
      final index = _images.indexWhere((element) => element.id == tempId);
      if (index != -1 && mounted) {
        setState(() {
          _images[index] = GridImageItem(
            id: result.id,
            path: result.path,
            isUploading: false,
          );
        });
        widget.onImagesChanged?.call(_images);
      }
    } catch (e) {
      final index = _images.indexWhere((element) => element.id == tempId);
      if (index != -1 && mounted) {
        setState(() {
          _images.removeAt(index);
        });
        widget.onImagesChanged?.call(_images);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged?.call(_images);
  }

  void _showPermissionSettingsDialog(Permission permission) {
    String permissionName = permission == Permission.camera
        ? widget.cameraTitle
        : widget.imageLibraryTitle;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(widget.requestPermissionText(permissionName)),
        content: Text(widget.requestPermissionContentText(permissionName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(widget.cancelButtonTitle),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(dialogContext);
              openAppSettings();
            },
            child: Text(widget.openSettingsButtonTitle),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: FullScreenImageViewer(images: _images, initialIndex: index),
        ),
      ),
    );
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool showAddButton = _images.length < widget.maxImages;
    final int totalItems = showAddButton ? _images.length + 1 : _images.length;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (showAddButton && index == _images.length) {
          // Thêm key cố định cho nút thêm ảnh
          return KeyedSubtree(
            key: const ValueKey('add_button_key'),
            child: _buildAddButton(colorScheme),
          );
        }

        // Bắt buộc gắn Key theo item.id để Flutter phân biệt chính xác từng ô khi cập nhật state
        final item = _images[index];
        return KeyedSubtree(
          key: ValueKey(item.id),
          child: _buildImageTile(context, index, colorScheme),
        );
      },
    );
  }

  Widget _buildAddButton(ColorScheme colorScheme) {
    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPickerBottomSheet(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              widget.addImageButtonTitle(
                '${_images.length}/${widget.maxImages}',
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(
    BuildContext context,
    int index,
    ColorScheme colorScheme,
  ) {
    final item = _images[index];
    final heroTag = 'm3_image_${item.id}';
    final bool isNetwork =
        item.path.startsWith('http://') || item.path.startsWith('https://');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: item.isUploading
                ? null
                : () => _openFullScreen(context, index),
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    isNetwork
                        ? Image.network(item.path, fit: BoxFit.cover)
                        : Image.file(File(item.path), fit: BoxFit.cover),
                    if (item.isUploading)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!item.isUploading)
          Positioned(
            top: 6,
            right: 6,
            child: SizedBox(
              width: 28,
              height: 28,
              child: IconButton.filledTonal(
                padding: EdgeInsets.zero,
                iconSize: 16,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer.withAlpha(
                    (0.9 * 255).round(),
                  ),
                  foregroundColor: colorScheme.onErrorContainer,
                ),
                icon: const Icon(Icons.close),
                onPressed: () => _removeImage(index),
              ),
            ),
          ),
      ],
    );
  }
}

// Màn hình xem ảnh toàn màn hình
class FullScreenImageViewer extends StatefulWidget {
  final List<GridImageItem> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(240),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_currentIndex + 1} / ${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final item = widget.images[index];
          final bool isNetwork =
              item.path.startsWith('http://') ||
              item.path.startsWith('https://');

          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'm3_image_${item.id}',
                child: isNetwork
                    ? Image.network(item.path, fit: BoxFit.contain)
                    : Image.file(File(item.path), fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}
