import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CustomTileProvider extends TileProvider {
  final String userAgent;

  CustomTileProvider({required this.userAgent});

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    final url = getTileUrl(coords, options);
    return NetworkImage(url, headers: {'User-Agent': userAgent});
  }
}
