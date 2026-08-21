import 'package:flutter/material.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/shared/domain/entities/media_entity.dart';

class LocationContactCard extends StatefulWidget {
  final List<MediaEntity> media;
  final String locationName;
  final String contactName;
  final String contactPhone;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LocationContactCard({
    super.key,
    this.media = const [],
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<LocationContactCard> createState() => _LocationContactCardState();
}

class _LocationContactCardState extends State<LocationContactCard> {
  bool isLoading = false;
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleLongPress() {
    setState(() {
      _isPressed = false;
    });

    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (widget.media.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.media[0].url,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        ),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/map_thumb.png',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: _handleTapDown,

      onTapUp: _handleTapUp,

      onTapCancel: _handleTapCancel,

      onTap: widget.onTap,

      onLongPress: _handleLongPress,

      // Flutter mặc định long press khoảng 500ms.
      // Set rõ ràng để đảm bảo đúng yêu cầu.
      onLongPressStart: (_) {
        setState(() {
          _isPressed = true;
        });
      },

      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: _handleLongPress,
            splashColor: AppColors.primary.withAlpha(25),
            highlightColor: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  imageWidget,

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.locationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.contactName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.contactPhone,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.location_on, color: AppColors.primary, size: 32),
    );
  }
}
