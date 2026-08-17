import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
// import 'package:flutter_compass/flutter_compass.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/utils/location_util.dart';
import 'package:shipgo/core/widgets/google_map_screen.dart';

enum MapMode { view, select }

class DirectionConePainter extends CustomPainter {
  final double heading;

  DirectionConePainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((heading - 90) * math.pi / 180);

    final path = Path();
    path.moveTo(0, 0);

    const angleSpread = 50.0 * math.pi / 180;
    const radius = 55.0;

    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      -angleSpread / 2,
      angleSpread,
      false,
    );
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withValues(alpha: 0.4),
          Colors.blue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DirectionConePainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}

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
  });

  @override
  State<M3MapWidget> createState() => _M3MapWidgetState();
}

class _M3MapWidgetState extends State<M3MapWidget>
    with TickerProviderStateMixin {
  late MapController _mapController;
  LatLng? _currentCenter;
  String? _address;
  // LatLng? _userLocation;
  // double? _userHeading;
  StreamSubscription? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.center;
    _address = widget.address;

    // Lắng nghe hướng la bàn từ thiết bị
    // _compassSubscription = FlutterCompass.events?.listen((event) {
    //   if (event.heading != null && mounted) {
    //     setState(() {
    //       _userHeading = event.heading;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant M3MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.address != widget.address) {
        _address = widget.address;
      }
      if (oldWidget.center?.latitude != widget.center?.latitude ||
          oldWidget.center?.longitude != widget.center?.longitude) {
        _currentCenter = widget.center;
      }
    });
  }

  // Hàm tạo hiệu ứng chuyển động mượt mà cho bản đồ
  void _animatedMapMove(LatLng destLocation, double destZoom) {
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
    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    controller.forward().whenComplete(() {
      controller.dispose();
    });
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    _animatedMapMove(camera.center, camera.zoom + 1);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _animatedMapMove(camera.center, camera.zoom - 1);
  }

  // void _openFullScreen() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => FullScreenMapPage(
  //         initialCenter: _currentCenter,
  //         initialZoom: _mapController.camera.zoom,
  //         initialUserLocation: _userLocation,
  //         initialUserHeading: _userHeading,
  //         onLocationChanged: (newLocation) {
  //           setState(() {
  //             _currentCenter = newLocation;
  //           });
  //           _mapController.move(newLocation, _mapController.camera.zoom);
  //           widget.onLocationSelected?.call(newLocation);
  //         },
  //         onUserLocationUpdated: (userLoc) {
  //           setState(() {
  //             _userLocation = userLoc;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _openGoogleMapPickerScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapsScreen(
          googleMapMode: widget.mode == MapMode.view
              ? GoogleMapMode.view
              : GoogleMapMode.select,
          title:  widget.mode == MapMode.view ? AppStrings.googleMapsViewScreenTitle.tr() : AppStrings.googleMapsPickerScreenTitle.tr(),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            _buildMap(_currentCenter, interactive: false),
            if (_currentCenter != null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ),
            if (_currentCenter == null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: AppColors.primary.withAlpha((0.3 * 255).round()),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          widget.selectLocationError,
                          style: TextStyle(
                            fontSize: 16,
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
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  if (widget.mode == MapMode.select)
                    FloatingActionButton.small(
                      heroTag: 'refresh_map_btn',
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 3,
                      onPressed: _resetCurrentCenter,
                      child: const Icon(Icons.refresh),
                    ),
                  FloatingActionButton.small(
                    heroTag: 'fullscreen_map_btn',
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 3,
                    onPressed: _openGoogleMapPickerScreen,
                    child: const Icon(Icons.fullscreen_rounded),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentCenter != null)
                    FloatingActionButton.small(
                      heroTag: 'zoom_in_normal_btn',
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 2,
                      onPressed: _zoomIn,
                      child: const Icon(Icons.add_rounded),
                    ),
                  if (_currentCenter != null) const SizedBox(height: 1),
                  if (_currentCenter != null)
                    FloatingActionButton.small(
                      heroTag: 'zoom_out_normal_btn',
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 2,
                      onPressed: _zoomOut,
                      child: const Icon(Icons.remove_rounded),
                    ),
                  if (_currentCenter != null) const SizedBox(height: 1),
                  if (widget.mode == MapMode.select)
                    FloatingActionButton.small(
                      heroTag: 'current_location_normal_btn',
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      foregroundColor: colorScheme.onSurfaceVariant,
                      elevation: 2,
                      onPressed: () async {
                        LatLng? currentPos =
                            await LocationUtils.getCurrentLatLng();
                        if (currentPos != null) {
                          setState(() {
                            // _userLocation = currentPos;
                            _currentCenter = currentPos;
                          });
                          _animatedMapMove(currentPos, 18.0);
                          widget.onLocationSelected?.call(currentPos);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.cannotGetLocationError),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.my_location_rounded),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LatLng? center, {required bool interactive}) {
    final List<Marker> markers = [];
    final List<CircleMarker> circles = [];

    // if (_userLocation != null) {
    //   circles.add(
    //     CircleMarker(
    //       point: _userLocation!,
    //       color: Colors.blue.withValues(alpha: 0.15),
    //       borderStrokeWidth: 1.5,
    //       borderColor: Colors.blue.withValues(alpha: 0.5),
    //       useRadiusInMeter: true,
    //       radius: 35,
    //     ),
    //   );

    //   markers.add(
    //     Marker(
    //       point: _userLocation!,
    //       width: 100,
    //       height: 100,
    //       alignment: Alignment.center,
    //       child: CustomPaint(
    //         painter: DirectionConePainter(heading: _userHeading ?? 0.0),
    //         child: Center(
    //           child: Container(
    //             width: 24,
    //             height: 24,
    //             decoration: BoxDecoration(
    //               color: Colors.blue,
    //               shape: BoxShape.circle,
    //               border: Border.all(color: Colors.white, width: 3),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Colors.black.withValues(alpha: 0.3),
    //                   blurRadius: 4,
    //                   offset: const Offset(0, 2),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center ?? const LatLng(10.762622, 106.660172),
        initialZoom: widget.initialZoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
        onPositionChanged: (position, hasGesture) {
          _currentCenter = position.center;
          widget.onLocationSelected?.call(_currentCenter!);
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

// Màn hình bản đồ toàn màn hình
// class FullScreenMapPage extends StatefulWidget {
//   final LatLng initialCenter;
//   final double initialZoom;
//   final LatLng? initialUserLocation;
//   final double? initialUserHeading;
//   final ValueChanged<LatLng> onLocationChanged;
//   final ValueChanged<LatLng> onUserLocationUpdated;

//   const FullScreenMapPage({
//     super.key,
//     required this.initialCenter,
//     required this.initialZoom,
//     this.initialUserLocation,
//     this.initialUserHeading,
//     required this.onLocationChanged,
//     required this.onUserLocationUpdated,
//   });

//   @override
//   State<FullScreenMapPage> createState() => _FullScreenMapPageState();
// }

// class _FullScreenMapPageState extends State<FullScreenMapPage>
//     with TickerProviderStateMixin {
//   late MapController _mapController;
//   late LatLng _currentCenter;
//   LatLng? _userLocation;
//   double? _userHeading;
//   StreamSubscription? _compassSubscription;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _currentCenter = widget.initialCenter;
//     _userLocation = widget.initialUserLocation;
//     _userHeading = widget.initialUserHeading;

//     // Lắng nghe cảm biến la bàn
//     _compassSubscription = FlutterCompass.events?.listen((event) {
//       if (event.heading != null && mounted) {
//         setState(() {
//           _userHeading = event.heading;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _compassSubscription?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _animatedMapMove(LatLng destLocation, double destZoom) {
//     final camera = _mapController.camera;
//     final latTween = Tween<double>(
//       begin: camera.center.latitude,
//       end: destLocation.latitude,
//     );
//     final lngTween = Tween<double>(
//       begin: camera.center.longitude,
//       end: destLocation.longitude,
//     );
//     final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

//     final controller = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     final Animation<double> animation = CurvedAnimation(
//       parent: controller,
//       curve: Curves.fastOutSlowIn,
//     );

//     controller.addListener(() {
//       _mapController.move(
//         LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
//         zoomTween.evaluate(animation),
//       );
//     });

//     controller.forward().whenComplete(() {
//       controller.dispose();
//     });
//   }

//   void _zoomIn() {
//     final camera = _mapController.camera;
//     _animatedMapMove(camera.center, camera.zoom + 1);
//   }

//   void _zoomOut() {
//     final camera = _mapController.camera;
//     _animatedMapMove(camera.center, camera.zoom - 1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     final List<Marker> fullScreenMarkers = [];
//     final List<CircleMarker> fullScreenCircles = [];

//     if (_userLocation != null) {
//       fullScreenCircles.add(
//         CircleMarker(
//           point: _userLocation!,
//           color: Colors.blue.withValues(alpha: 0.15),
//           borderStrokeWidth: 1.5,
//           borderColor: Colors.blue.withValues(alpha: 0.5),
//           useRadiusInMeter: true,
//           radius: 35,
//         ),
//       );

//       // Marker có kèm theo chùm tia sáng hướng quay mặt
//       fullScreenMarkers.add(
//         Marker(
//           point: _userLocation!,
//           width: 100,
//           height: 100,
//           alignment: Alignment.center,
//           child: CustomPaint(
//             painter: DirectionConePainter(heading: _userHeading ?? 0.0),
//             child: Center(
//               child: Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 3),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.3),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentCenter,
//               initialZoom: widget.initialZoom,
//               onPositionChanged: (position, hasGesture) {
//                 if (hasGesture) {
//                   setState(() {
//                     _currentCenter = position.center;
//                   });
//                   widget.onLocationChanged(_currentCenter);
//                 }
//               },
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate:
//                     'https://qkwp9rg7-8081.asse.devtunnels.ms/tile/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.techbox.shipgo',
//                 maxNativeZoom: 18,
//                 maxZoom: 19,
//                 panBuffer: 2,
//               ),
//               CircleLayer(circles: fullScreenCircles),
//               MarkerLayer(markers: fullScreenMarkers),
//             ],
//           ),

//           const Center(
//             child: Padding(
//               padding: EdgeInsets.only(bottom: 40),
//               child: Icon(Icons.location_pin, color: Colors.red, size: 45),
//             ),
//           ),

//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Material(
//                     color: colorScheme.surface,
//                     elevation: 3,
//                     shape: const CircleBorder(),
//                     child: IconButton(
//                       icon: const Icon(Icons.arrow_back_rounded),
//                       color: colorScheme.onSurface,
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: SearchBar(
//                       controller: _searchController,
//                       hintText: 'Tìm kiếm địa điểm...',
//                       leading: const Icon(Icons.search_rounded),
//                       elevation: WidgetStateProperty.all(3),
//                       padding: WidgetStateProperty.all(
//                         const EdgeInsets.symmetric(horizontal: 16),
//                       ),
//                       onSubmitted: (query) {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           Positioned(
//             bottom: 32,
//             right: 16,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 FloatingActionButton.small(
//                   heroTag: 'zoom_in_fullscreen_btn',
//                   backgroundColor: colorScheme.surface,
//                   foregroundColor: colorScheme.onSurface,
//                   elevation: 3,
//                   onPressed: _zoomIn,
//                   child: const Icon(Icons.add_rounded),
//                 ),
//                 const SizedBox(height: 4),
//                 FloatingActionButton.small(
//                   heroTag: 'zoom_out_fullscreen_btn',
//                   backgroundColor: colorScheme.surface,
//                   foregroundColor: colorScheme.onSurface,
//                   elevation: 3,
//                   onPressed: _zoomOut,
//                   child: const Icon(Icons.remove_rounded),
//                 ),
//               ],
//             ),
//           ),

//           Positioned(
//             bottom: 32,
//             left: 16,
//             child: Column(
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'pin_drop_rounded',
//                   backgroundColor: colorScheme.surfaceContainerHigh,
//                   foregroundColor: colorScheme.onSurfaceVariant,
//                   elevation: 4,
//                   onPressed: _showLatLongInputDialog,
//                   child: const Icon(Icons.pin_drop_rounded),
//                 ),
//                 SizedBox(height: 8),
//                 FloatingActionButton(
//                   heroTag: 'current_location_fullscreen_btn',
//                   backgroundColor: colorScheme.surfaceContainerHigh,
//                   foregroundColor: colorScheme.onSurfaceVariant,
//                   elevation: 4,
//                   onPressed: () async {
//                     LatLng? currentPos = await LocationUtils.getCurrentLatLng();
//                     if (currentPos != null) {
//                       setState(() {
//                         _userLocation = currentPos;
//                         _currentCenter = currentPos;
//                       });
//                       widget.onUserLocationUpdated(currentPos);
//                       widget.onLocationChanged(currentPos);
//                       _animatedMapMove(currentPos, 18.0);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Không thể lấy được vị trí hiện tại!'),
//                         ),
//                       );
//                     }
//                   },
//                   child: const Icon(Icons.my_location_rounded),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLatLongInputDialog() {
//     final TextEditingController latLngController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Nhập tọa độ định vị'),
//           content: TextField(
//             controller: latLngController,
//             decoration: const InputDecoration(
//               labelText: 'Tọa độ',
//               hintText: 'Ví dụ: 10,762622, 106,660172',
//               helperText: 'Định dạng: lat, long',
//             ),
//             autofocus: true,
//             keyboardType: TextInputType.text,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Hủy'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 final text = latLngController.text.trim();

//                 // Dùng Regex tìm tất cả các chuỗi số (hỗ trợ số âm, dấu phẩy hoặc chấm thập phân)
//                 final regex = RegExp(r'-?\d+[\.,]\d+|-?\d+');
//                 final matches = regex
//                     .allMatches(text)
//                     .map((m) => m.group(0)!)
//                     .toList();

//                 if (matches.length >= 2) {
//                   // Lấy 2 số đầu tiên tìm được làm lat và long, chuyển dấu phẩy thành dấu chấm để parse double
//                   final latStr = matches[0].replaceAll(',', '.');
//                   final lngStr = matches[1].replaceAll(',', '.');

//                   final lat = double.tryParse(latStr);
//                   final lng = double.tryParse(lngStr);

//                   if (lat != null && lng != null) {
//                     // Kiểm tra giới hạn hợp lệ của Lat và Long
//                     if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
//                       final newTarget = LatLng(lat, lng);

//                       setState(() {
//                         _currentCenter = newTarget;
//                       });

//                       // Di chuyển bản đồ đến tọa độ vừa nhập với zoom 18
//                       _animatedMapMove(newTarget, 18.0);

//                       // Cập nhật về trang trước đó
//                       widget.onLocationChanged(newTarget);

//                       Navigator.pop(context);
//                       return;
//                     }
//                   }
//                 }

//                 // Nếu nhập sai định dạng hoặc không đủ 2 số hợp lệ
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Sai định dạng! Vui lòng nhập: lat, long (VD: 10,762622, 106,660172)',
//                     ),
//                   ),
//                 );
//               },
//               child: const Text('Đi đến'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
