import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/src/marker/basicmarker.dart';
import 'package:mapsforge_flutter/src/marker/imarkerdatastore.dart';

///
/// Holds a collection of markers. Marker could mark a POI (e.g. restaurants) or ways (e.g. special interest areas)
///
class MarkerDataStore extends IMarkerDataStore {
  static final _log = new Logger('MarkerDataStore');

  final List<BasicMarker> _markers = [];

  final Set<BasicMarker> _markersNeedInit = Set();

  BoundingBox? _previousBoundingBox;

  int? _previousZoomLevel;

  @protected
  bool disposed = false;

  /// returns the markers to draw for the given [boundary]. If this method needs more time return an empty list and call [setRepaint()] when finished.
  @override
  List<BasicMarker> getMarkers(
      GraphicFactory graphicFactory, BoundingBox boundary, int zoomLevel) {
    if (boundary != _previousBoundingBox || zoomLevel != _previousZoomLevel) {
      retrieveMarkersFor(graphicFactory, boundary, zoomLevel);
      _previousBoundingBox = boundary;
      _previousZoomLevel = zoomLevel;
    }
    List<BasicMarker> markersToDraw = _markers
        .where((marker) => marker.shouldPaint(boundary, zoomLevel))
        .toList();
    List<BasicMarker> markersToInit = markersToDraw
        .where((element) => _markersNeedInit.contains(element))
        .toList();
    if (markersToInit.length > 0) {
      _markersNeedInit.removeAll(markersToInit);
      _initMarkers(graphicFactory, markersToInit);
      markersToDraw.removeWhere((element) => markersToInit.contains(element));
      return markersToDraw;
    }
    return markersToDraw;
  }

  /// This method will be called if boundary or zoomlevel changes to give the implementation the chance to replace/retrieve markers for the new boundary/zoomlevel.
  /// If this method changes something asynchronously it must call [setRepaint] afterwards.
  void retrieveMarkersFor(
      GraphicFactory graphicFactory, BoundingBox boundary, int zoomLevel) {}

  /// Initializes the markers which are currently not initialized and are needed now
  Future<void> _initMarkers(
      GraphicFactory graphicFactory, List<BasicMarker> markersToInit) async {
    //_log.info("Initializing ${markersToInit.length} markers now");
    for (BasicMarker m in markersToInit) {
      await m.initResources(graphicFactory);
    }
    if (!disposed) setRepaint();
  }

  @override
  @mustCallSuper
  void dispose() {
    clearMarkers();
    disposed = true;
    super.dispose();
  }

  @protected
  void setRepaint() {
    notifyListeners();
  }

  void addMarker(BasicMarker marker) {
    _markersNeedInit.add(marker);
    _markers.add(marker);
  }

  void removeMarker(BasicMarker marker) {
    _markersNeedInit.remove(marker);
    _markers.remove(marker);
    marker.dispose();
  }

  void clearMarkers() {
    _markersNeedInit.clear();
    _markers.forEach((marker) {
      marker.dispose();
    });
    _markers.clear();
  }

  @override
  List<BasicMarker> isTapped(
      MapViewPosition mapViewPosition, double tappedX, double tappedY) {
    return _markers
        .where((element) => element.isTapped(mapViewPosition, tappedX, tappedY))
        .toList();
  }
}
