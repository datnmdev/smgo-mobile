import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/utils/location_util.dart';
import 'package:shipgo/shared/widgets/google_map_screen.dart';

enum MapMode { view, select }

class M3MapWidget extends StatefulWidget {
  final MapMode mode;
  final LatLng? center;
  final String? address;
  final double initialZoom;
  final ValueChanged<LatLng?>? onLocationSelected;
  final String selectLocationError;
  final String cannotGetLocationError;
  final String mapTemplateUrl;
  final String userAgentPackageName;
  final bool showControls;

  const M3MapWidget({
    super.key,
    this.center,
    this.address,
    this.initialZoom = 18.0,
    this.onLocationSelected,
    this.selectLocationError = 'Vui lòng chọn 1 vị trí trên bản đồ',
    this.cannotGetLocationError = 'Không thể lấy được vị trí hiện tại!',
    this.mapTemplateUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    required this.userAgentPackageName,
    this.mode = MapMode.select,
    this.showControls = true,
  });

  @override
  State<M3MapWidget> createState() => _M3MapWidgetState();
}

class _M3MapWidgetState extends State<M3MapWidget>
    with TickerProviderStateMixin {
  late MapController _mapController;
  LatLng? _currentCenter;
  String? _address;
  StreamSubscription? _compassSubscription;
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.center;
    _address = widget.address;
  }

  @override
  void dispose() {
    _animController?.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant M3MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool centerChanged = oldWidget.center != widget.center;

    if (oldWidget.address != widget.address) {
      _address = widget.address;
    }
    if (centerChanged) {
      _currentCenter = widget.center;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentCenter != null) {
          _animatedMapMove(_currentCenter!, widget.initialZoom);
        }
      });
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    _animController?.stop();
    _animController?.dispose();
    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final Animation<double> animation = CurvedAnimation(
      parent: _animController!,
      curve: Curves.fastOutSlowIn,
    );
    _animController!.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    _animController!.forward();
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    _animatedMapMove(camera.center, camera.zoom + 1);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _animatedMapMove(camera.center, camera.zoom - 1);
  }

  void _openGoogleMapPickerScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapsScreen(
          googleMapMode: widget.mode == MapMode.view
              ? GoogleMapMode.view
              : GoogleMapMode.select,
          title: widget.mode == MapMode.view
              ? AppStrings.googleMapsViewScreenTitle.tr()
              : AppStrings.googleMapsPickerScreenTitle.tr(),
          pickLocationError: AppStrings.gMPSpickLocationError.tr(),
          acceptButtonTitle: AppStrings.gMPScceptButtonTitle.tr(),
          searchQuery: _address ?? '',
          pinnedLocation: _currentCenter,
          onLocationSelected: (location, name) {
            if (location != null && mounted) {
              final newLocation = location;
              setState(() {
                _currentCenter = newLocation;
              });
              _animatedMapMove(newLocation, 18.0);
              widget.onLocationSelected?.call(newLocation);
            }
          },
        ),
      ),
    );
  }

  void _resetCurrentCenter() {
    setState(() {
      _currentCenter = null;
      widget.onLocationSelected?.call(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 260,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double mapHeight = constraints.maxHeight;
            final double scaleFactor = (mapHeight / 260).clamp(0.7, 1.5);

            final double buttonSize = 36.0 * scaleFactor;
            final double iconSize = 20.0 * scaleFactor;

            return Stack(
              children: [
                _buildMap(_currentCenter, interactive: false),
                if (_currentCenter != null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40 * scaleFactor),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40 * scaleFactor,
                      ),
                    ),
                  ),
                if (_currentCenter == null)
                  Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          color: AppColors.primary.withAlpha(
                            (0.3 * 255).round(),
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              widget.selectLocationError,
                              style: TextStyle(
                                fontSize: 16 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (widget.showControls) ...[
                  Positioned(
                    top: 12 * scaleFactor,
                    right: 12 * scaleFactor,
                    child: Row(
                      children: [
                        if (widget.mode == MapMode.select)
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: FloatingActionButton.small(
                              heroTag: 'refresh_map_btn',
                              backgroundColor: colorScheme.surface,
                              foregroundColor: colorScheme.onSurface,
                              elevation: 3,
                              onPressed: _resetCurrentCenter,
                              child: Icon(Icons.refresh, size: iconSize),
                            ),
                          ),
                        if (widget.mode == MapMode.select)
                          SizedBox(width: 8 * scaleFactor),
                        SizedBox(
                          width: buttonSize,
                          height: buttonSize,
                          child: FloatingActionButton.small(
                            heroTag: 'fullscreen_map_btn',
                            backgroundColor: colorScheme.surface,
                            foregroundColor: colorScheme.onSurface,
                            elevation: 3,
                            onPressed: _openGoogleMapPickerScreen,
                            child: Icon(
                              Icons.fullscreen_rounded,
                              size: iconSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12 * scaleFactor,
                    right: 12 * scaleFactor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentCenter != null)
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: FloatingActionButton.small(
                              heroTag: 'zoom_in_normal_btn',
                              backgroundColor: colorScheme.surface,
                              foregroundColor: colorScheme.onSurface,
                              elevation: 2,
                              onPressed: _zoomIn,
                              child: Icon(Icons.add_rounded, size: iconSize),
                            ),
                          ),
                        if (_currentCenter != null)
                          SizedBox(height: 4 * scaleFactor),
                        if (_currentCenter != null)
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: FloatingActionButton.small(
                              heroTag: 'zoom_out_normal_btn',
                              backgroundColor: colorScheme.surface,
                              foregroundColor: colorScheme.onSurface,
                              elevation: 2,
                              onPressed: _zoomOut,
                              child: Icon(Icons.remove_rounded, size: iconSize),
                            ),
                          ),
                        if (_currentCenter != null)
                          SizedBox(height: 4 * scaleFactor),
                        if (widget.mode == MapMode.select)
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: FloatingActionButton.small(
                              heroTag: 'current_location_normal_btn',
                              backgroundColor: colorScheme.surfaceContainerHigh,
                              foregroundColor: colorScheme.onSurfaceVariant,
                              elevation: 2,
                              onPressed: () async {
                                LatLng? currentPos =
                                    await LocationUtils.getCurrentLatLng();
                                if (currentPos != null) {
                                  setState(() {
                                    _currentCenter = currentPos;
                                  });
                                  _animatedMapMove(currentPos, 18.0);
                                  widget.onLocationSelected?.call(currentPos);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        widget.cannotGetLocationError,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.my_location_rounded,
                                size: iconSize,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMap(LatLng? center, {required bool interactive}) {
    final List<Marker> markers = [];
    final List<CircleMarker> circles = [];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center ?? const LatLng(10.762622, 106.660172),
        initialZoom: widget.initialZoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            _currentCenter = position.center;
            widget.onLocationSelected?.call(_currentCenter);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: widget.mapTemplateUrl,
          userAgentPackageName: widget.userAgentPackageName,
          maxNativeZoom: 18,
          maxZoom: 19,
          panBuffer: 2,
        ),
        if (circles.isNotEmpty) CircleLayer(circles: circles),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );
  }
}
