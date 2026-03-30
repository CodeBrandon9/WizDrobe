import 'package:flutter/material.dart';
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      'Setting 1',
      'Setting 2',
      'Setting 3',
      'Setting 4',
      'Setting 5',
      'Setting 6',
    ];

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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.1,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 28,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.circle, size: 14),
                              label: const Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF02062E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final isActive = index == 0;
                          return Container(
                            alignment: Alignment.topLeft,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFF8FAFD)
                                  : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FA),
          border: Border(
            top: BorderSide(color: Color(0xFFD1D5DB), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _BottomTabItem(
              icon: Icons.checkroom_outlined,
              label: 'Wizdrobe',
            ),
            _BottomTabItem(icon: Icons.add_box_outlined, label: 'Create'),
            _BottomTabItem(icon: Icons.photo_library_outlined, label: 'Outfits'),
            _BottomTabItem(icon: Icons.settings_outlined, label: 'Settings',selected: true),
          ],
        ),
      ),
    );
  }
}


class _BottomTabItem extends StatelessWidget {
  const _BottomTabItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF275AFF) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
