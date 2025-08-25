
import 'package:flutter/material.dart';
import 'package:txt_invite/src/utils/constants.dart';

class TextElement {
  String content;
  String fontFace;
  double size;
  Color color;
  double x;
  double y;

  TextElement({
    required this.content,
    required this.fontFace,
    required this.size,
    required this.color,
    required this.x,
    required this.y,
  });
  
  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      content: json['content'] ?? '',
      fontFace: json['fontFace'] ?? FONTS[0],
      size: json['size']?.toDouble() ?? 14,
      color: Color(int.parse(json['color']?.replaceFirst('#', '0xFF') ?? '0xFF000000')),
      x: json['x']?.toDouble() ?? 0,
      y: json['y']?.toDouble() ?? 0,
    );
  }
}

class ImageElement {
  String imageUrl;
  double width;
  double height;
  double x;
  double y;

  ImageElement({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
  });

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      imageUrl: json['imageUrl'] ?? '',
      width: json['width']?.toDouble() ?? 0,
      height: json['height']?.toDouble() ?? 0,
      x: json['x']?.toDouble() ?? 0,
      y: json['y']?.toDouble() ?? 0,
    );
  }
}

class Invitation {
  List<TextElement> textElements;
  List<ImageElement> imageElements;
  String backgroundImage;
  double width;
  double height;

  Invitation({
    required this.textElements,
    required this.imageElements,
    required this.backgroundImage,
    required this.width,
    required this.height,
  });

  Invitation copyWith({
    List<TextElement>? textElements,
    List<ImageElement>? imageElements,
    String? backgroundImage,
    double? width,
    double? height,
  }) {
    return Invitation(
      textElements: textElements ?? this.textElements,
      imageElements: imageElements ?? this.imageElements,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      textElements: (json['textElements'] as List)
          .map((e) => TextElement.fromJson(e))
          .toList(),
      imageElements: (json['imageElements'] as List)
          .map((e) => ImageElement.fromJson(e))
          .toList(),
      backgroundImage: json['backgroundImage'] ?? '',
      width: json['width']?.toDouble() ?? 0,
      height: json['height']?.toDouble() ?? 0,
    );
  }
}
