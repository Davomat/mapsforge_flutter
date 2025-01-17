import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/src/graphics/display.dart';
import 'package:mapsforge_flutter/src/graphics/mappaint.dart';
import 'package:mapsforge_flutter/src/graphics/mappath.dart';
import 'package:mapsforge_flutter/src/graphics/style.dart';
import 'package:mapsforge_flutter/src/model/boundingbox.dart';
import 'package:mapsforge_flutter/src/model/ilatlong.dart';

import 'basicmarker.dart';
import 'markercallback.dart';

class PathMarker<T> extends BasicMarker<T> {
  List<ILatLong> path = [];

  MapPaint? stroke;

  final double strokeWidth;

  final int strokeColor;

  MapPath? mapPath;

  PathMarker({
    display = Display.ALWAYS,
    minZoomLevel = 0,
    maxZoomLevel = 65535,
    double rotation = 0,
    item,
    this.strokeWidth = 1.0,
    this.strokeColor = 0xff000000,
  })  : assert(display != null),
        assert(minZoomLevel >= 0),
        assert(maxZoomLevel <= 65535),
        assert(rotation >= 0 && rotation <= 360),
        assert(strokeWidth >= 0),
        super(
          display: display,
          minZoomLevel: minZoomLevel,
          maxZoomLevel: maxZoomLevel,
          rotation: rotation,
          item: item,
        );

  @override
  Future<void> initResources(GraphicFactory graphicFactory) async {
    await super.initResources(graphicFactory);
    if (stroke == null && strokeWidth > 0) {
      this.stroke = graphicFactory.createPaint();
      this.stroke!.setColorFromNumber(strokeColor);
      this.stroke!.setStyle(Style.STROKE);
      this.stroke!.setStrokeWidth(strokeWidth);
      //this.stroke.setTextSize(fontSize);
    }
  }

  void addLatLong(ILatLong latLong) {
    path.add(latLong);
    mapPath = null;
  }

  @override
  bool shouldPaint(BoundingBox boundary, int zoomLevel) {
    return minZoomLevel <= zoomLevel && maxZoomLevel >= zoomLevel;
  }

  @override
  void renderBitmap(MarkerCallback markerCallback) {
    if (stroke == null) return;
    //if (mapPath == null) {
    mapPath = markerCallback.graphicFactory.createPath();

    path.forEach((latLong) {
      double y = markerCallback.mapViewPosition.projection!
              .latitudeToPixelY(latLong.latitude) -
          markerCallback.mapViewPosition.leftUpper!.y;
      double x = markerCallback.mapViewPosition.projection!
              .longitudeToPixelX(latLong.longitude) -
          markerCallback.mapViewPosition.leftUpper!.x;

      if (mapPath!.isEmpty())
        mapPath!.moveTo(x, y);
      else
        mapPath!.lineTo(x, y);
    });
    // }
    markerCallback.renderPath(mapPath!, stroke!);
  }
}
