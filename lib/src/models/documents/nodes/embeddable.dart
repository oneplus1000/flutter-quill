import 'dart:convert';
import 'package:crypto/crypto.dart';

/// An object which can be embedded into a Quill document.
///
/// See also:
///
/// * [BlockEmbed] which represents a block embed.
class Embeddable {
  const Embeddable(this.type, this.data);

  /// The type of this object.
  final String type;

  /// The data payload of this object.
  final dynamic data;

  Map<String, dynamic> toJson() {
    return {type: data};
  }

  static Embeddable fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    assert(m.length == 1, 'Embeddable map must only have one key');

    return Embeddable(m.keys.first, m.values.first);
  }
}

/// There are two built-in embed types supported by Quill documents, however
/// the document model itself does not make any assumptions about the types
/// of embedded objects and allows users to define their own types.
class BlockEmbed extends Embeddable {
  const BlockEmbed(String type, String data) : super(type, data);

  static const String imageType = 'image';
  static BlockEmbed image(String imageUrl) => BlockEmbed(imageType, imageUrl);

  static const String videoType = 'video';
  static BlockEmbed video(String videoUrl) => BlockEmbed(videoType, videoUrl);

  static const String imageWithInfoType = 'image_with_info';
  static BlockEmbed imageWithInfo(ImageWithInfo imageinfo) {
    final map = imageinfo.toMap();
    final jsonString = jsonEncode(map);
    final be = BlockEmbed(imageWithInfoType, jsonString);
    return be;
  }

  static const String formulaType = 'formula';
  static BlockEmbed formula(String formula) => BlockEmbed(formulaType, formula);

  static const String customType = 'custom';
  static BlockEmbed custom(CustomBlockEmbed customBlock) =>
      BlockEmbed(customType, customBlock.toJsonString());
}

class CustomBlockEmbed extends BlockEmbed {
  const CustomBlockEmbed(String type, String data) : super(type, data);

  String toJsonString() => jsonEncode(toJson());

  static CustomBlockEmbed fromJsonString(String data) {
    final embeddable = Embeddable.fromJson(jsonDecode(data));
    return CustomBlockEmbed(embeddable.type, embeddable.data);
  }
}

class ImageWithInfo {
  ImageWithInfo({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.fileKey,
  });
  final String imageUrl;
  final int width;
  final int height;
  final String fileKey;

  String cssClassName() {
    final hash = md5.convert(utf8.encode(fileKey)).toString();
    return 'cls_$hash';
  }

  // ignore: sort_constructors_first
  factory ImageWithInfo.fromJson(String jsonString) {
    var imageUrl = '';
    final Map map = jsonDecode(jsonString);
    if (map.containsKey('imageUrl')) {
      imageUrl = map['imageUrl'];
    }

    var width = 0;
    var height = 0;
    if (map.containsKey('width')) {
      width = map['width'];
    }
    if (map.containsKey('height')) {
      height = map['height'];
    }
    var fileKey = '';
    if (map.containsKey('fileKey')) {
      fileKey = map['fileKey'];
    }

    return ImageWithInfo(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fileKey: fileKey,
    );
  }

  Map toMap() {
    final map = {};
    map['imageUrl'] = imageUrl;
    map['width'] = width;
    map['height'] = height;
    map['fileKey'] = fileKey;
    return map;
  }
}
