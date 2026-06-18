import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../data/gelato_theme.dart';

enum HandleType { topLeft, topRight, bottomLeft, bottomRight, center, none }

class CropImageScreen extends StatefulWidget {
  final File imageFile;

  const CropImageScreen({super.key, required this.imageFile});

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  ui.Image? _uiImage;
  bool _isLoading = true;

  // Display and Crop parameters
  double _displayedLeft = 0;
  double _displayedTop = 0;
  double _displayedWidth = 0;
  double _displayedHeight = 0;

  Rect _cropRect = Rect.zero;
  HandleType _activeHandle = HandleType.none;
  Offset _dragStartOffset = Offset.zero;
  Rect _dragStartCropRect = Rect.zero;

  static const double _handleSize = 28.0;
  static const double _minCropSize = 60.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _uiImage = fi.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeCropRect(double W, double H) {
    if (_uiImage == null) return;

    final iw = _uiImage!.width.toDouble();
    final ih = _uiImage!.height.toDouble();
    final imageRatio = iw / ih;
    final screenRatio = W / H;

    if (imageRatio > screenRatio) {
      _displayedWidth = W;
      _displayedHeight = W / imageRatio;
      _displayedLeft = 0;
      _displayedTop = (H - _displayedHeight) / 2;
    } else {
      _displayedHeight = H;
      _displayedWidth = H * imageRatio;
      _displayedLeft = (W - _displayedWidth) / 2;
      _displayedTop = 0;
    }

    // Initialize crop box to be a square at 80% of the minimum dimension of the image
    final side = min(_displayedWidth, _displayedHeight) * 0.8;
    final cropLeft = _displayedLeft + (_displayedWidth - side) / 2;
    final cropTop = _displayedTop + (_displayedHeight - side) / 2;

    _cropRect = Rect.fromLTWH(cropLeft, cropTop, side, side);
  }

  HandleType _getHitHandle(Offset localPosition) {
    // Check corner handles
    final tl = Offset(_cropRect.left, _cropRect.top);
    if ((localPosition - tl).distance <= _handleSize) return HandleType.topLeft;

    final tr = Offset(_cropRect.right, _cropRect.top);
    if ((localPosition - tr).distance <= _handleSize) return HandleType.topRight;

    final bl = Offset(_cropRect.left, _cropRect.bottom);
    if ((localPosition - bl).distance <= _handleSize) return HandleType.bottomLeft;

    final br = Offset(_cropRect.right, _cropRect.bottom);
    if ((localPosition - br).distance <= _handleSize) return HandleType.bottomRight;

    // Check center/drag area
    if (_cropRect.contains(localPosition)) return HandleType.center;

    return HandleType.none;
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    final localPos = details.localPosition;
    _activeHandle = _getHitHandle(localPos);
    _dragStartOffset = localPos;
    _dragStartCropRect = _cropRect;
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_activeHandle == HandleType.none) return;

    final localPos = details.localPosition;
    final dx = localPos.dx - _dragStartOffset.dx;
    final dy = localPos.dy - _dragStartOffset.dy;

    setState(() {
      if (_activeHandle == HandleType.center) {
        // Drag/move the entire crop rect
        var newRect = _dragStartCropRect.translate(dx, dy);

        // Keep inside image boundary
        double newLeft = newRect.left;
        double newTop = newRect.top;

        if (newLeft < _displayedLeft) {
          newLeft = _displayedLeft;
        } else if (newLeft + newRect.width > _displayedLeft + _displayedWidth) {
          newLeft = _displayedLeft + _displayedWidth - newRect.width;
        }

        if (newTop < _displayedTop) {
          newTop = _displayedTop;
        } else if (newTop + newRect.height > _displayedTop + _displayedHeight) {
          newTop = _displayedTop + _displayedHeight - newRect.height;
        }

        _cropRect = Rect.fromLTWH(newLeft, newTop, newRect.width, newRect.height);
      } else {
        // Handle corner drag (keep 1:1 square ratio)
        double newSide = _dragStartCropRect.width;
        double newLeft = _dragStartCropRect.left;
        double newTop = _dragStartCropRect.top;

        switch (_activeHandle) {
          case HandleType.bottomRight:
            // Symmetrical expansion based on the drag distance
            final delta = max(dx, dy);
            newSide = max(_minCropSize, _dragStartCropRect.width + delta);
            // Limit to image boundary
            final maxRight = _displayedLeft + _displayedWidth;
            final maxBottom = _displayedTop + _displayedHeight;
            if (_dragStartCropRect.left + newSide > maxRight) {
              newSide = maxRight - _dragStartCropRect.left;
            }
            if (_dragStartCropRect.top + newSide > maxBottom) {
              newSide = maxBottom - _dragStartCropRect.top;
            }
            break;

          case HandleType.bottomLeft:
            // Symmetrical expansion: moving left (negative dx) increases size
            final delta = max(-dx, dy);
            newSide = max(_minCropSize, _dragStartCropRect.width + delta);
            // Limit to image boundary
            if (_dragStartCropRect.right - newSide < _displayedLeft) {
              newSide = _dragStartCropRect.right - _displayedLeft;
            }
            final maxBottom = _displayedTop + _displayedHeight;
            if (_dragStartCropRect.top + newSide > maxBottom) {
              newSide = maxBottom - _dragStartCropRect.top;
            }
            newLeft = _dragStartCropRect.right - newSide;
            break;

          case HandleType.topRight:
            // Symmetrical expansion: moving up (negative dy) increases size
            final delta = max(dx, -dy);
            newSide = max(_minCropSize, _dragStartCropRect.width + delta);
            // Limit to image boundary
            final maxRight = _displayedLeft + _displayedWidth;
            if (_dragStartCropRect.left + newSide > maxRight) {
              newSide = maxRight - _dragStartCropRect.left;
            }
            if (_dragStartCropRect.bottom - newSide < _displayedTop) {
              newSide = _dragStartCropRect.bottom - _displayedTop;
            }
            newTop = _dragStartCropRect.bottom - newSide;
            break;

          case HandleType.topLeft:
            // Symmetrical expansion: moving top/left (negative dx/dy) increases size
            final delta = max(-dx, -dy);
            newSide = max(_minCropSize, _dragStartCropRect.width + delta);
            // Limit to image boundary
            if (_dragStartCropRect.right - newSide < _displayedLeft) {
              newSide = _dragStartCropRect.right - _displayedLeft;
            }
            if (_dragStartCropRect.bottom - newSide < _displayedTop) {
              newSide = _dragStartCropRect.bottom - _displayedTop;
            }
            newLeft = _dragStartCropRect.right - newSide;
            newTop = _dragStartCropRect.bottom - newSide;
            break;

          default:
            break;
        }

        _cropRect = Rect.fromLTWH(newLeft, newTop, newSide, newSide);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _activeHandle = HandleType.none;
  }

  Future<void> _cropAndSave() async {
    if (_uiImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate relative coordinates within the displayed image bounds
      final relativeLeft = (_cropRect.left - _displayedLeft) / _displayedWidth;
      final relativeTop = (_cropRect.top - _displayedTop) / _displayedHeight;
      final relativeWidth = _cropRect.width / _displayedWidth;

      // Map to original image coordinates
      final srcLeft = relativeLeft * _uiImage!.width;
      final srcTop = relativeTop * _uiImage!.height;
      final srcSize = relativeWidth * _uiImage!.width;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // We'll crop to a square with size based on the crop resolution
      final destSize = srcSize.round();
      final srcRect = Rect.fromLTWH(srcLeft, srcTop, srcSize, srcSize);
      final dstRect = Rect.fromLTWH(0, 0, destSize.toDouble(), destSize.toDouble());

      final paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = ui.FilterQuality.high;

      canvas.drawImageRect(_uiImage!, srcRect, dstRect, paint);

      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(destSize, destSize);
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final croppedFile = File(
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png');
      await croppedFile.writeAsBytes(buffer);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Crop Photo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoading && _uiImage != null)
            TextButton.icon(
              icon: const Icon(Icons.check_rounded, color: GelatoTheme.green),
              label: const Text(
                'Crop',
                style: TextStyle(
                  color: GelatoTheme.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: _cropAndSave,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: GelatoTheme.blue),
            )
          : _uiImage == null
              ? const Center(
                  child: Text(
                    'Failed to load image.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final W = constraints.maxWidth;
                    final H = constraints.maxHeight;

                    // Initialize the dimensions once when constraints are available
                    if (_cropRect == Rect.zero) {
                      _initializeCropRect(W, H);
                    }

                    return GestureDetector(
                      onPanStart: (details) => _onPanStart(details, constraints),
                      onPanUpdate: (details) => _onPanUpdate(details, constraints),
                      onPanEnd: _onPanEnd,
                      child: Stack(
                        children: [
                          // Underlying Image
                          Positioned(
                            left: _displayedLeft,
                            top: _displayedTop,
                            width: _displayedWidth,
                            height: _displayedHeight,
                            child: RawImage(
                              image: _uiImage,
                              fit: BoxFit.fill,
                            ),
                          ),
                          // Semi-transparent overlay and Crop box visualizer
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _CropOverlayPainter(
                                imageRect: Rect.fromLTWH(
                                  _displayedLeft,
                                  _displayedTop,
                                  _displayedWidth,
                                  _displayedHeight,
                                ),
                                cropRect: _cropRect,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect imageRect;
  final Rect cropRect;

  _CropOverlayPainter({required this.imageRect, required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // 1. Draw overlay on the outer boundaries of the image, excluding the crop area.
    // Left side
    canvas.drawRect(
      Rect.fromLTRB(imageRect.left, imageRect.top, cropRect.left, imageRect.bottom),
      overlayPaint,
    );
    // Right side
    canvas.drawRect(
      Rect.fromLTRB(cropRect.right, imageRect.top, imageRect.right, imageRect.bottom),
      overlayPaint,
    );
    // Top side (between left & right bounds of the crop rect)
    canvas.drawRect(
      Rect.fromLTRB(cropRect.left, imageRect.top, cropRect.right, cropRect.top),
      overlayPaint,
    );
    // Bottom side (between left & right bounds of the crop rect)
    canvas.drawRect(
      Rect.fromLTRB(cropRect.left, cropRect.bottom, cropRect.right, imageRect.bottom),
      overlayPaint,
    );

    // 2. Draw crop area border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(cropRect, borderPaint);

    // 3. Draw grid lines (3x3 rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final thirdW = cropRect.width / 3;
    final thirdH = cropRect.height / 3;

    // Vertical lines
    canvas.drawLine(
      Offset(cropRect.left + thirdW, cropRect.top),
      Offset(cropRect.left + thirdW, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + 2 * thirdW, cropRect.top),
      Offset(cropRect.left + 2 * thirdW, cropRect.bottom),
      gridPaint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdH),
      Offset(cropRect.right, cropRect.top + thirdH),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + 2 * thirdH),
      Offset(cropRect.right, cropRect.top + 2 * thirdH),
      gridPaint,
    );

    // 4. Draw Corner handles
    final handlePaint = Paint()
      ..color = GelatoTheme.blue
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final corners = [
      Offset(cropRect.left, cropRect.top),
      Offset(cropRect.right, cropRect.top),
      Offset(cropRect.left, cropRect.bottom),
      Offset(cropRect.right, cropRect.bottom),
    ];

    for (final corner in corners) {
      // Shadow for handle
      canvas.drawCircle(corner, 8.0, shadowPaint);
      // Main handle circle
      canvas.drawCircle(corner, 7.0, handlePaint);
      // Center dot
      canvas.drawCircle(corner, 2.0, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.imageRect != imageRect || oldDelegate.cropRect != cropRect;
  }
}
