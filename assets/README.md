# Assets Folder

This folder contains all the static assets used in the Flutter application.

## Folder Structure

```
assets/
├── images/          # General images (logos, backgrounds, placeholders, etc.)
├── icons/           # Custom icons (if not using Material Icons)
└── fonts/           # Custom fonts (if needed)
```

## How to Use Images

### 1. Adding Images

- Place your image files in the appropriate folder (`images/` or `icons/`)
- Supported formats: PNG, JPG, JPEG, GIF, WebP
- Recommended to use PNG for icons and logos, JPG for photos

### 2. Using Images in Code

#### Method 1: Using AppImages constants (Recommended)

```dart
import 'package:your_app/core/constants/app_images.dart';

// In your widget
Image.asset(AppImages.logo)
```

#### Method 2: Direct path

```dart
Image.asset('assets/images/your_image.png')
```

#### Method 3: Using CustomImage widget (Recommended for better UX)

```dart
import 'package:your_app/shared/widgets/custom_image.dart';

// Basic usage
CustomImage(
  imagePath: AppImages.logo,
  width: 200,
  height: 100,
)

// Circular image (for avatars)
CircularImage(
  imagePath: AppImages.userAvatar,
  size: 50,
)
```

### 3. Adding New Image Constants

When you add a new image, update the `lib/core/constants/app_images.dart` file:

```dart
class AppImages {
  // ... existing constants ...

  // Add your new image
  static const String myNewImage = 'assets/images/my_new_image.png';
}
```

## Image Guidelines

### File Naming

- Use lowercase letters
- Separate words with underscores
- Be descriptive: `user_profile_avatar.png` instead of `img1.png`

### Image Optimization

- Compress images to reduce app size
- Use appropriate formats:
  - PNG: For icons, logos, images with transparency
  - JPG: For photos and complex images
  - WebP: For better compression (if supported)

### Resolution

- Provide appropriate resolutions for different screen densities
- Consider using `2.0x`, `3.0x` folders for high-DPI images

## Example Usage

```dart
import 'package:flutter/material.dart';
import 'package:your_app/core/constants/app_images.dart';
import 'package:your_app/shared/widgets/custom_image.dart';

class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Using CustomImage with error handling
        CustomImage(
          imagePath: AppImages.logo,
          width: 200,
          height: 100,
          fit: BoxFit.contain,
        ),

        // Circular avatar
        CircularImage(
          imagePath: AppImages.userAvatar,
          size: 60,
        ),

        // Direct Image.asset usage
        Image.asset(
          AppImages.background,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
```

## Troubleshooting

### Image not showing?

1. Check if the image path is correct
2. Verify the image is in the `pubspec.yaml` assets section
3. Run `flutter clean` and `flutter pub get`
4. Check if the image file exists and has the correct extension

### App size too large?

1. Compress your images
2. Use WebP format when possible
3. Consider lazy loading for large images
4. Remove unused images
