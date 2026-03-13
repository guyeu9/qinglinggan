import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';

/// 图片选择结果
class ImagePickResult {
  final List<File> images;
  final List<String> paths;

  const ImagePickResult({
    required this.images,
    required this.paths,
  });

  bool get isEmpty => images.isEmpty;
  bool get isNotEmpty => images.isNotEmpty;
  int get length => images.length;
}

/// 图片选择服务
///
/// 支持功能：
/// - 从相册选择单张/多张图片
/// - 拍照
/// - Android 10+ 所有相册访问
/// - 权限管理
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final AppLogger _logger = AppLogger.instance;
  final _uuid = const Uuid();

  /// 检查并请求相册权限
  Future<bool> requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();

      if (sdkInt >= 34) {
        final status = await Permission.photos.request();
        if (status.isGranted) return true;

        final limitedStatus = await Permission.photos.request();
        if (limitedStatus.isLimited) return true;

        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        if (status.isGranted) return true;

        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }

    return true;
  }

  /// 检查并请求相机权限
  Future<bool> requestCameraPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    return true;
  }

  /// 从相册选择单张图片
  Future<Result<ImagePickResult>> pickSingleImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        return Result.error('相册权限未授权');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth ?? 1920,
        maxHeight: maxHeight ?? 1920,
        imageQuality: imageQuality ?? 85,
      );

      if (image == null) {
        return Result.success(const ImagePickResult(images: [], paths: []));
      }

      final savedFile = await _saveImageToAppDirectory(image);
      _logger.info('选择图片成功: ${savedFile.path}');

      return Result.success(ImagePickResult(
        images: [savedFile],
        paths: [savedFile.path],
      ));
    } catch (e, st) {
      _logger.error('选择图片失败', e, st);
      return Result.error('选择图片失败: $e');
    }
  }

  /// 从相册选择多张图片
  Future<Result<ImagePickResult>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      final hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        return Result.error('相册权限未授权');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth ?? 1920,
        maxHeight: maxHeight ?? 1920,
        imageQuality: imageQuality ?? 85,
        limit: limit ?? 9,
      );

      if (images.isEmpty) {
        return Result.success(const ImagePickResult(images: [], paths: []));
      }

      final savedFiles = <File>[];
      final savedPaths = <String>[];

      for (final image in images) {
        final savedFile = await _saveImageToAppDirectory(image);
        savedFiles.add(savedFile);
        savedPaths.add(savedFile.path);
      }

      _logger.info('选择${savedFiles.length}张图片成功');

      return Result.success(ImagePickResult(
        images: savedFiles,
        paths: savedPaths,
      ));
    } catch (e, st) {
      _logger.error('选择多张图片失败', e, st);
      return Result.error('选择图片失败: $e');
    }
  }

  /// 拍照
  Future<Result<ImagePickResult>> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        return Result.error('相机权限未授权');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth ?? 1920,
        maxHeight: maxHeight ?? 1920,
        imageQuality: imageQuality ?? 85,
      );

      if (image == null) {
        return Result.success(const ImagePickResult(images: [], paths: []));
      }

      final savedFile = await _saveImageToAppDirectory(image);
      _logger.info('拍照成功: ${savedFile.path}');

      return Result.success(ImagePickResult(
        images: [savedFile],
        paths: [savedFile.path],
      ));
    } catch (e, st) {
      _logger.error('拍照失败', e, st);
      return Result.error('拍照失败: $e');
    }
  }

  /// 显示图片选择选项（相册/拍照）
  Future<Result<ImagePickResult>> showImageSourceDialog(BuildContext context) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImageSourceSheet(context),
    );

    if (result == null) {
      return Result.success(const ImagePickResult(images: [], paths: []));
    }

    switch (result) {
      case ImageSource.gallery:
        return pickMultipleImages();
      case ImageSource.camera:
        return takePhoto();
    }
  }

  Widget _buildImageSourceSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064e3b) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '选择图片来源',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  context: context,
                  icon: Icons.photo_library,
                  label: '相册',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                _buildSourceOption(
                  context: context,
                  icon: Icons.camera_alt,
                  label: '拍照',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
                      : const Color(0xFF065F46).withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF6EE7B7).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 保存图片到应用目录
  Future<File> _saveImageToAppDirectory(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.jpg';
    final savedPath = '${imagesDir.path}/$fileName';

    final bytes = await image.readAsBytes();
    final savedFile = File(savedPath);
    await savedFile.writeAsBytes(bytes);

    return savedFile;
  }

  /// 获取Android SDK版本
  Future<int> _getAndroidSdkVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      final deviceInfo = await _getAndroidDeviceInfo();
      return deviceInfo;
    } catch (e) {
      _logger.warning('获取Android SDK版本失败: $e');
      return 30;
    }
  }

  Future<int> _getAndroidDeviceInfo() async {
    return 34;
  }

  /// 删除图片
  Future<bool> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.info('删除图片成功: $path');
      }
      return true;
    } catch (e) {
      _logger.error('删除图片失败: $e');
      return false;
    }
  }
}
