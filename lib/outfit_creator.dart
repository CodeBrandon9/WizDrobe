import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'wardrobe_models.dart';

class _PlacedPiece {
  _PlacedPiece({
    required this.id,
    required this.imageBytes,
    required this.name,
    required this.position,
    required this.width,
    required this.aspectRatio,
  });

  final int id;
  final Uint8List imageBytes;
  final String name;
  Offset position;
  /// Display width in logical pixels; height is `width / aspectRatio`.
  double width;
  /// `imageWidth / imageHeight` from decoded bytes (always > 0).
  double aspectRatio;

  double get imageHeight => width / aspectRatio;
}

class OutfitCreator extends StatefulWidget {
  const OutfitCreator({
    super.key,
    required this.wardrobeItems,
    this.onSaveOutfit,
  });

  final List<WardrobeItem> wardrobeItems;
  final void Function(String name, Uint8List previewPng)? onSaveOutfit;

  @override
  State<OutfitCreator> createState() => _OutfitCreatorState();
}

class _OutfitCreatorState extends State<OutfitCreator> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey _canvasKey = GlobalKey();
  final List<_PlacedPiece> _pieces = [];
  int _nextPieceId = 1;
  bool _saving = false;
  int? _selectedPieceId;

  static const double _minPieceWidth = 56;
  static const double _maxPieceWidth = 520;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<double> _decodeAspectRatio(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final im = frame.image;
      final w = im.width.toDouble();
      final h = im.height.toDouble();
      im.dispose();
      if (h <= 0 || w <= 0) return 1;
      return w / h;
    } catch (_) {
      return 1;
    }
  }

  Future<void> _addPieceFromWardrobe(WardrobeItem item) async {
    final bytes = Uint8List.fromList(item.imageBytes);
    final ar = await _decodeAspectRatio(bytes);
    if (!mounted) return;
    setState(() {
      final n = _pieces.length;
      final id = _nextPieceId++;
      _pieces.add(
        _PlacedPiece(
          id: id,
          imageBytes: bytes,
          name: item.name,
          position: Offset(20 + (n % 6) * 12.0, 20 + (n % 6) * 12.0),
          width: 130,
          aspectRatio: ar,
        ),
      );
      _selectedPieceId = id;
    });
  }

  void _selectPiece(int id) {
    setState(() {
      _selectedPieceId = id;
      final i = _pieces.indexWhere((p) => p.id == id);
      if (i == -1 || i == _pieces.length - 1) return;
      final p = _pieces.removeAt(i);
      _pieces.add(p);
    });
  }

  Future<void> _openWardrobePicker() async {
    if (widget.wardrobeItems.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add photos to your wardrobe first.'),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7F8FA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFE3E8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tap an item to add to the canvas',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: widget.wardrobeItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.wardrobeItems[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _addPieceFromWardrobe(item);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ColoredBox(
                                      color: const Color(0xFFF3F4F6),
                                      child: Image.memory(
                                        item.imageBytes,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removePiece(int id) {
    setState(() {
      _pieces.removeWhere((p) => p.id == id);
      if (_selectedPieceId == id) {
        _selectedPieceId = null;
      }
    });
  }

  Future<void> _saveOutfit() async {
    if (_pieces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one wardrobe photo to the canvas.'),
        ),
      );
      return;
    }

    final name = _nameController.text.trim().isEmpty
        ? 'Untitled outfit'
        : _nameController.text.trim();

    setState(() => _saving = true);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) {
        throw StateError('Canvas not ready');
      }
      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }
      if (!mounted) return;
      final image = await boundary.toImage(pixelRatio: dpr.clamp(1.0, 3.0));
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        throw StateError('Could not encode image');
      }
      final png = byteData.buffer.asUint8List();
      widget.onSaveOutfit?.call(name, png);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved “$name” to Outfits.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save image. Try again after a moment.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildPiece(_PlacedPiece piece) {
    final selected = _selectedPieceId == piece.id;
    final borderColor =
        selected ? const Color(0xFF275AFF) : const Color(0xFFE4E7EC);
    final imageH = piece.imageHeight;

    void movePiece(DragUpdateDetails details) {
      setState(() {
        piece.position += details.delta;
      });
    }

    return Positioned(
      left: piece.position.dx,
      top: piece.position.dy,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: piece.width,
            height: imageH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _selectPiece(piece.id),
                    onLongPress: () => _removePiece(piece.id),
                    onPanUpdate: selected ? movePiece : null,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor,
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.memory(
                          piece.imageBytes,
                          width: piece.width,
                          height: imageH,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) {
                        // Diagonal drag keeps aspect ratio via width-only control.
                        final delta =
                            (details.delta.dx + details.delta.dy) / 2;
                        setState(() {
                          piece.width = (piece.width + delta).clamp(
                            _minPieceWidth,
                            _maxPieceWidth,
                          );
                        });
                      },
                      child: Tooltip(
                        message: 'Drag to resize',
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF275AFF),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.open_in_full,
                            size: 12,
                            color: Color(0xFF275AFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: selected ? movePiece : null,
              onTap: () => _selectPiece(piece.id),
              child: SizedBox(
                width: piece.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    piece.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFDFE3E8), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 18,
                    color: Color(0xFF275AFF),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Create outfit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Outfit name (e.g., Summer casual)',
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(9),
                            child: InkWell(
                              onTap: _openWardrobePicker,
                              borderRadius: BorderRadius.circular(9),
                              child: const SizedBox(
                                height: 44,
                                child: Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add from wardrobe',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _saveOutfit,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined, size: 18),
                            label: Text(_saving ? 'Saving…' : 'Save'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF275AFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tap a photo to select it, then drag to move. Drag the blue handle to resize (aspect ratio kept). Tap empty canvas to deselect. Long-press a photo to remove.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DashedBorderContainer(
                        child: RepaintBoundary(
                          key: _canvasKey,
                          child: ColoredBox(
                            color: Colors.white,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                if (_pieces.isNotEmpty)
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(
                                        () => _selectedPieceId = null,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                if (_pieces.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.layers_outlined,
                                            size: 48,
                                            color: Color(0xFFCBD5E1),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Blank canvas',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Tap “Add from wardrobe” to place your clothing photos here.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ..._pieces.map(_buildPiece),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  const DashedBorderContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double? boxHeight;
          if (constraints.hasBoundedHeight) {
            final h = constraints.maxHeight - 8.0;
            boxHeight = h < 0 ? 0.0 : h;
          }
          return CustomPaint(
            painter: _DashedRectPainter(),
            child: Container(
              width: double.infinity,
              height: boxHeight,
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = const Color(0xFFDFE3E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 6.0;

    void drawDashedLine(Offset p1, Offset p2) {
      final total = (p2 - p1).distance;
      final dashAndSpace = dashWidth + dashSpace;
      final dashCount = (total / dashAndSpace).floor();
      final direction = (p2 - p1) / total;
      var start = p1;
      for (var i = 0; i < dashCount; i++) {
        final end = start + direction * dashWidth;
        canvas.drawLine(start, end, paint);
        start = start + direction * dashAndSpace;
      }
    }

    drawDashedLine(rect.topLeft, rect.topRight);
    drawDashedLine(rect.topRight, rect.bottomRight);
    drawDashedLine(rect.bottomRight, rect.bottomLeft);
    drawDashedLine(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
