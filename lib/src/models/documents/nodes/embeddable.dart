import 'dart:convert';

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
}

class ImageWithInfo {
  ImageWithInfo({
    required this.imageUrl,
    required this.width,
    required this.height,
  });
  final String imageUrl;
  final int width;
  final int height;

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
    return ImageWithInfo(
      imageUrl: imageUrl,
      width: width,
      height: height,
    );
  }

  Map toMap() {
    final map = {};
    map['imageUrl'] = imageUrl;
    map['width'] = width;
    map['height'] = height;
    return map;
  }
}
