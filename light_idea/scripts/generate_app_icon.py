#!/usr/bin/env python3
"""
轻灵感应用图标生成脚本
根据侧边栏设计规范生成 Android 和 iOS 所需的所有尺寸图标
设计规范:
- 背景色: #065F46 (深绿色)
- 图标: 白色灯泡 (Material Design lightbulb)
- 形状: 圆角方形
"""

import os
from PIL import Image, ImageDraw

ICON_BG_COLOR = "#065F46"
ICON_FG_COLOR = "#FFFFFF"

LIGHTBULB_PATH = [
    (0.5, 0.21),  
    (0.5, 0.17),  
    (0.42, 0.09), 
    (0.30, 0.09), 
    (0.22, 0.17), 
    (0.22, 0.30), 
    (0.28, 0.40), 
    (0.34, 0.48), 
    (0.34, 0.56), 
    (0.66, 0.56), 
    (0.66, 0.48), 
    (0.72, 0.40), 
    (0.78, 0.30), 
    (0.78, 0.21), 
    (0.72, 0.13), 
    (0.64, 0.09), 
    (0.56, 0.07), 
    (0.50, 0.07), 
    (0.44, 0.07), 
    (0.36, 0.09), 
    (0.28, 0.13), 
    (0.22, 0.21), 
]

LIGHTBULB_BASE = [
    (0.38, 0.60),
    (0.38, 0.64),
    (0.40, 0.66),
    (0.40, 0.70),
    (0.60, 0.70),
    (0.60, 0.66),
    (0.62, 0.64),
    (0.62, 0.60),
]

LIGHTBULB_BOTTOM = [
    (0.42, 0.72),
    (0.42, 0.76),
    (0.44, 0.78),
    (0.56, 0.78),
    (0.58, 0.76),
    (0.58, 0.72),
]

def create_lightbulb_icon(size: int, corner_radius_ratio: float = 0.20) -> Image.Image:
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    corner_radius = int(size * corner_radius_ratio)
    
    bg_color = tuple(int(ICON_BG_COLOR[i:i+2], 16) for i in (1, 3, 5))
    draw.rounded_rectangle([0, 0, size-1, size-1], radius=corner_radius, fill=bg_color)
    
    fg_color = tuple(int(ICON_FG_COLOR[i:i+2], 16) for i in (1, 3, 5))
    
    scale = size
    padding = size * 0.10
    
    bulb_points = [(int(p[0] * scale), int(p[1] * scale)) for p in LIGHTBULB_PATH]
    draw.polygon(bulb_points, fill=fg_color)
    
    base_points = [(int(p[0] * scale), int(p[1] * scale)) for p in LIGHTBULB_BASE]
    draw.polygon(base_points, fill=fg_color)
    
    bottom_points = [(int(p[0] * scale), int(p[1] * scale)) for p in LIGHTBULB_BOTTOM]
    draw.polygon(bottom_points, fill=fg_color)
    
    return img

def create_lightbulb_icon_v2(size: int, corner_radius_ratio: float = 0.20) -> Image.Image:
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    corner_radius = int(size * corner_radius_ratio)
    
    bg_color = tuple(int(ICON_BG_COLOR[i:i+2], 16) for i in (1, 3, 5))
    draw.rounded_rectangle([0, 0, size-1, size-1], radius=corner_radius, fill=bg_color)
    
    fg_color = tuple(int(ICON_FG_COLOR[i:i+2], 16) for i in (1, 3, 5))
    
    center_x = size // 2
    center_y = int(size * 0.38)
    
    bulb_width = int(size * 0.32)
    bulb_height = int(size * 0.30)
    
    draw.ellipse([
        center_x - bulb_width,
        center_y - bulb_height,
        center_x + bulb_width,
        center_y + bulb_height
    ], fill=fg_color)
    
    neck_width = int(size * 0.16)
    neck_height = int(size * 0.08)
    neck_y = center_y + bulb_height
    
    draw.rectangle([
        center_x - neck_width,
        neck_y,
        center_x + neck_width,
        neck_y + neck_height
    ], fill=fg_color)
    
    base_width = int(size * 0.20)
    base_height = int(size * 0.04)
    base_y = neck_y + neck_height
    
    for i in range(3):
        y = base_y + i * (base_height + 2)
        w = base_width - i * int(size * 0.02)
        draw.rectangle([
            center_x - w,
            y,
            center_x + w,
            y + base_height
        ], fill=fg_color)
    
    return img

def create_lightbulb_icon_v3(size: int, corner_radius_ratio: float = 0.20) -> Image.Image:
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    corner_radius = int(size * corner_radius_ratio)
    
    bg_color = tuple(int(ICON_BG_COLOR[i:i+2], 16) for i in (1, 3, 5))
    draw.rounded_rectangle([0, 0, size-1, size-1], radius=corner_radius, fill=bg_color)
    
    fg_color = tuple(int(ICON_FG_COLOR[i:i+2], 16) for i in (1, 3, 5))
    
    margin = int(size * 0.18)
    icon_size = size - 2 * margin
    
    bulb_center_x = size // 2
    bulb_center_y = margin + int(icon_size * 0.35)
    bulb_radius = int(icon_size * 0.38)
    
    draw.ellipse([
        bulb_center_x - bulb_radius,
        bulb_center_y - bulb_radius,
        bulb_center_x + bulb_radius,
        bulb_center_y + bulb_radius
    ], fill=fg_color)
    
    base_top = bulb_center_y + bulb_radius - int(bulb_radius * 0.15)
    base_bottom = margin + int(icon_size * 0.85)
    base_width = int(icon_size * 0.32)
    
    draw.rounded_rectangle([
        bulb_center_x - base_width // 2,
        base_top,
        bulb_center_x + base_width // 2,
        base_bottom
    ], radius=int(size * 0.02), fill=fg_color)
    
    screw_width = int(icon_size * 0.26)
    screw_height = int(icon_size * 0.06)
    screw_y = base_bottom
    
    for i in range(3):
        y = screw_y + i * screw_height
        w = screw_width - i * int(icon_size * 0.02)
        draw.rounded_rectangle([
            bulb_center_x - w // 2,
            y,
            bulb_center_x + w // 2,
            y + screw_height - 1
        ], radius=1, fill=fg_color)
    
    return img

ANDROID_SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

IOS_SIZES = [
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
]

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    
    android_base = os.path.join(project_dir, 'android', 'app', 'src', 'main', 'res')
    ios_base = os.path.join(project_dir, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
    
    print("正在生成 Android 图标...")
    for folder, size in ANDROID_SIZES.items():
        output_dir = os.path.join(android_base, folder)
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, 'ic_launcher.png')
        
        icon = create_lightbulb_icon_v3(size)
        icon.save(output_path, 'PNG')
        print(f"  生成: {output_path} ({size}x{size})")
    
    print("\n正在生成 iOS 图标...")
    os.makedirs(ios_base, exist_ok=True)
    for filename, size in IOS_SIZES:
        output_path = os.path.join(ios_base, filename)
        
        icon = create_lightbulb_icon_v3(size)
        icon.save(output_path, 'PNG')
        print(f"  生成: {output_path} ({size}x{size})")
    
    print("\n图标生成完成！")
    print(f"\n设计规范:")
    print(f"  背景色: {ICON_BG_COLOR} (深绿色)")
    print(f"  图标: 白色灯泡")
    print(f"  形状: 圆角方形 (圆角比例 20%)")

if __name__ == '__main__':
    main()
