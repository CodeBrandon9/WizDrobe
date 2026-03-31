import 'package:flutter/material.dart';

class OutfitCreator extends StatefulWidget {
  const OutfitCreator({super.key});

  @override
  State<OutfitCreator> createState() => _OutfitCreatorState();
}

class _OutfitCreatorState extends State<OutfitCreator> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                    'Wizdrobe',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
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
                      hintText: 'e.g., Summer Casual',
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
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(width: 12),
                              Icon(Icons.keyboard_arrow_up),
                              SizedBox(width: 6),
                              Text('Select Items'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B7280),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: DashedBorderContainer(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Tap "Select Items" to add clothing',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Click items to add them to your outfit',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
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

// Reusable body widget for IndexedStack navigation
class OutfitCreatorBody extends StatelessWidget {
  const OutfitCreatorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  'Wizdrobe',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
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
                    decoration: InputDecoration(
                      hintText: 'e.g., Summer Casual',
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
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(width: 12),
                              Icon(Icons.keyboard_arrow_up),
                              SizedBox(width: 6),
                              Text('Select Items'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B7280),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: DashedBorderContainer(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Tap "Select Items" to add clothing',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Click items to add them to your outfit',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
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
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;

  const DashedBorderContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return CustomPaint(
          painter: _DashedRectPainter(),
          child: Container(
            width: double.infinity,
            height: constraints.maxHeight - 8,
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        );
      }),
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
      int dashCount = (total / dashAndSpace).floor();
      final direction = (p2 - p1) / total;
      var start = p1;
      for (int i = 0; i < dashCount; i++) {
        final end = start + direction * dashWidth;
        canvas.drawLine(start, end, paint);
        start = start + direction * dashAndSpace;
      }
    }

    // top
    drawDashedLine(rect.topLeft, rect.topRight);
    // right
    drawDashedLine(rect.topRight, rect.bottomRight);
    // bottom
    drawDashedLine(rect.bottomRight, rect.bottomLeft);
    // left
    drawDashedLine(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

 
