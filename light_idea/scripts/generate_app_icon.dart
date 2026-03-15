#!/usr/bin/env dart
/// 轻灵感应用图标生成脚本
/// 根据侧边栏设计规范生成 Android 和 iOS 所需的所有尺寸图标
/// 
/// 设计规范:
/// - 背景色: #065F46 (深绿色)
/// - 图标: 白色灯泡 (Material Design lightbulb)
/// - 形状: 圆角方形

import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart';

class Color {
  final int r, g, b, a;
  const Color(this.r, this.g, this.b, this.a);
  
  int toAbgr() => (a << 24) | (b << 16) | (g << 8) | r;
}

const Color kBackgroundColor = Color(6, 95, 70, 255);
const Color kForegroundColor = Color(255, 255, 255, 255);

Image createLightbulbIcon(int size, {double cornerRadiusRatio = 0.20}) {
  final image = Image(width: size, height: size);
  
  final cornerRadius = (size * cornerRadiusRatio).round();
  
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final color = _getPixelColor(x, y, size, cornerRadius);
      image.setPixelRgba(x, y, color.r, color.g, color.b, color.a);
    }
  }
  
  return image;
}

Color _getPixelColor(int x, int y, int size, int cornerRadius) {
  if (!_isInsideRoundedRect(x, y, size, cornerRadius)) {
    return const Color(0, 0, 0, 0);
  }
  
  final margin = (size * 0.18).round();
  final iconSize = size - 2 * margin;
  
  final bulbCenterX = size / 2;
  final bulbCenterY = margin + iconSize * 0.35;
  final bulbRadius = iconSize * 0.38;
  
  final dx = x - bulbCenterX;
  final dy = y - bulbCenterY;
  final distance = math.sqrt(dx * dx + dy * dy);
  
  if (distance <= bulbRadius) {
    return kForegroundColor;
  }
  
  final baseTop = bulbCenterY + bulbRadius - bulbRadius * 0.15;
  final baseBottom = margin + iconSize * 0.85;
  final baseWidth = iconSize * 0.32;
  
  if (y >= baseTop && y <= baseBottom) {
    if (x >= bulbCenterX - baseWidth / 2 && x <= bulbCenterX + baseWidth / 2) {
      return kForegroundColor;
    }
  }
  
  final screwWidth = iconSize * 0.26;
  final screwHeight = iconSize * 0.06;
  var screwY = baseBottom;
  
  for (var i = 0; i < 3; i++) {
    final w = screwWidth - i * iconSize * 0.02;
    if (y >= screwY && y <= screwY + screwHeight) {
      if (x >= bulbCenterX - w / 2 && x <= bulbCenterX + w / 2) {
        return kForegroundColor;
      }
    }
    screwY += screwHeight;
  }
  
  return kBackgroundColor;
}

bool _isInsideRoundedRect(int x, int y, int size, int radius) {
  if (x < 0 || x >= size || y < 0 || y >= size) return false;
  
  if (x >= radius && x < size - radius) return true;
  if (y >= radius && y < size - radius) return true;
  
  int cx, cy;
  if (x < radius && y < radius) {
    cx = radius;
    cy = radius;
  } else if (x >= size - radius && y < radius) {
    cx = size - radius - 1;
    cy = radius;
  } else if (x < radius && y >= size - radius) {
    cx = radius;
    cy = size - radius - 1;
  } else if (x >= size - radius && y >= size - radius) {
    cx = size - radius - 1;
    cy = size - radius - 1;
  } else {
    return true;
  }
  
  final dx = x - cx;
  final dy = y - cy;
  return dx * dx + dy * dy <= radius * radius;
}

const Map<String, int> androidSizes = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const List<(String, int)> iosSizes = [
  ('Icon-App-20x20@1x.png', 20),
  ('Icon-App-20x20@2x.png', 40),
  ('Icon-App-20x20@3x.png', 60),
  ('Icon-App-29x29@1x.png', 29),
  ('Icon-App-29x29@2x.png', 58),
  ('Icon-App-29x29@3x.png', 87),
  ('Icon-App-40x40@1x.png', 40),
  ('Icon-App-40x40@2x.png', 80),
  ('Icon-App-40x40@3x.png', 120),
  ('Icon-App-60x60@2x.png', 120),
  ('Icon-App-60x60@3x.png', 180),
  ('Icon-App-76x76@1x.png', 76),
  ('Icon-App-76x76@2x.png', 152),
  ('Icon-App-83.5x83.5@2x.png', 167),
  ('Icon-App-1024x1024@1x.png', 1024),
];

void main() async {
  final scriptDir = File.fromUri(Platform.script).parent;
  final projectDir = scriptDir.parent;
  
  final androidBase = Directory('${projectDir.path}/android/app/src/main/res');
  final iosBase = Directory('${projectDir.path}/ios/Runner/Assets.xcassets/AppIcon.appiconset');
  
  print('正在生成 Android 图标...');
  for (final entry in androidSizes.entries) {
    final folder = entry.key;
    final size = entry.value;
    
    final outputDir = Directory('${androidBase.path}/$folder');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    
    final outputPath = '${outputDir.path}/ic_launcher.png';
    
    final icon = createLightbulbIcon(size);
    final pngBytes = encodePng(icon);
    File(outputPath).writeAsBytesSync(pngBytes);
    
    print('  生成: $outputPath (${size}x${size})');
  }
  
  print('\n正在生成 iOS 图标...');
  if (!iosBase.existsSync()) {
    iosBase.createSync(recursive: true);
  }
  
  for (final entry in iosSizes) {
    final filename = entry.$1;
    final size = entry.$2;
    
    final outputPath = '${iosBase.path}/$filename';
    
    final icon = createLightbulbIcon(size);
    final pngBytes = encodePng(icon);
    File(outputPath).writeAsBytesSync(pngBytes);
    
    print('  生成: $outputPath (${size}x${size})');
  }
  
  print('\n图标生成完成！');
  print('\n设计规范:');
  print('  背景色: #065F46 (深绿色)');
  print('  图标: 白色灯泡');
  print('  形状: 圆角方形 (圆角比例 20%)');
}
