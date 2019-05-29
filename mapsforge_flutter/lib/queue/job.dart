import '../model/tile.dart';

class Job {
  final bool hasAlpha;
  final Tile tile;
  final String key;

  static String _composeKey(int z, int x, int y) {
    return "$z/$x/$y";
  }

  static String _composeKeyFromString(String z, String x, String y) {
    return z + "/" + x + "/" + y;
  }

  Job(this.tile, this.hasAlpha)
      : key = _composeKey(tile.zoomLevel, tile.tileX, tile.tileY) {
    if (tile == null) {
      throw new Exception("tile must not be null");
    }
  }

  /**
   * Returns a unique identifier for the tile.
   * <p/>
   * The key has the form {@code zoom/x/y}, which is the de-facto standard for tile references. The default path
   * separator character of the platform is used between {@code zoom}, {@code x} and {@code y}.
   *
   * @since 0.5.0
   */
  String getKey() {
    return this.key;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Job &&
          runtimeType == other.runtimeType &&
          hasAlpha == other.hasAlpha &&
          tile == other.tile &&
          key == other.key;

  @override
  int get hashCode => hasAlpha.hashCode ^ tile.hashCode ^ key.hashCode;
}
