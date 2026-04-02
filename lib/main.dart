import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'background_removal_service.dart';
import 'outfit_creator.dart';
import 'setting_screen.dart';
import 'webcam_capture_screen.dart';


void main() {
  runApp(const WizdrobeApp());
}

class WizdrobeApp extends StatelessWidget {
  const WizdrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wizdrobe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF275AFF)),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _selectedIndex = 0;
  final List<WardrobeItem> _items = [];

  void _addItem(WardrobeItem item) {
    setState(() {
      _items.insert(0, item);
    });
  }

  void _updateItem(int index, WardrobeItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      WardrobeScreen(
        items: _items,
        onAddItem: _addItem,
        onUpdateItem: _updateItem,
      ),
      const OutfitCreator(),
      const SavedOutfitsBody(),
      const SettingScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF7F8FA),
        selectedItemColor: const Color(0xFF275AFF),
        unselectedItemColor: const Color(0xFF6B7280),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            label: 'Wizdrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            label: 'Outfits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class WardrobeItem {
  const WardrobeItem({
    required this.name,
    required this.imageBytes,
    required this.backgroundRemoved,
    required this.category,
  });

  final String name;
  final Uint8List imageBytes;
  final bool backgroundRemoved;
  final WardrobeCategory category;
}

enum WardrobeCategory { tops, bottoms, shoes, outerwear, accessories }

class _AddItemFormResult {
  const _AddItemFormResult({
    required this.category,
    required this.name,
    required this.removeBackground,
  });

  final WardrobeCategory category;
  final String name;
  final bool removeBackground;
}

class _PickedImageData {
  const _PickedImageData({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onUpdateItem,
  });

  final List<WardrobeItem> items;
  final ValueChanged<WardrobeItem> onAddItem;
  final void Function(int index, WardrobeItem item) onUpdateItem;

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  static const String _apiKeyStorageKey = 'remove_bg_api_key';
  final ImagePicker _picker = ImagePicker();
  final BackgroundRemovalService _bgService = const BackgroundRemovalService();
  String _removeBgApiKey = '';
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStoredApiKey();
  }

  Future<void> _loadStoredApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_apiKeyStorageKey);
    if (!mounted) return;
    if (stored != null && stored.trim().isNotEmpty) {
      setState(() {
        _removeBgApiKey = stored.trim();
      });
    }
  }

  Future<void> _handleAddItem() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item Photo'),
        content: const Text('Choose how you want to add your clothing photo.'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Camera'),
          ),
        ],
      ),
    );
    if (source == null || !mounted) {
      return;
    }

    final pickedImage = await _pickImage(source);
    if (pickedImage == null || !mounted) {
      return;
    }

    final selectedImageBytes = pickedImage.bytes;

    final formResult = await _showAddItemDetailsDialog(
      selectedImageBytes: selectedImageBytes,
    );
    if (formResult == null || !mounted) {
      return;
    }

    Uint8List bytes = selectedImageBytes;
    bool removedBg = false;

    if (formResult.removeBackground && mounted) {
      try {
        final apiKey = await _ensureApiKey();
        if (apiKey == null || !mounted) return;
        final processed = await _bgService.removeBackground(
          imageBytes: bytes,
          fileName: pickedImage.fileName,
          apiKey: apiKey,
        );
        bytes = processed;
        removedBg = true;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI background removal failed: $e',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    }

    widget.onAddItem(
      WardrobeItem(
        name: formResult.name,
        imageBytes: bytes,
        backgroundRemoved: removedBg,
        category: formResult.category,
      ),
    );
  }

  Future<_PickedImageData?> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera && kIsWeb) {
      final webcamResult = await Navigator.of(context).push<WebcamCaptureResult>(
        MaterialPageRoute(builder: (_) => const WebcamCaptureScreen()),
      );
      if (webcamResult != null) {
        return _PickedImageData(
          bytes: webcamResult.bytes,
          fileName: webcamResult.fileName,
        );
      }
      if (!mounted) return null;
      // Fallback for browsers/devices where webcam stream cannot be opened.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falling back to browser camera/file picker.'),
        ),
      );
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked == null) {
        return null;
      }
      return _PickedImageData(
        bytes: await picked.readAsBytes(),
        fileName: picked.name,
      );
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Could not access camera. Please allow camera permissions and try again. ($e)'
                : 'Could not open gallery. Please try again. ($e)',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
      return null;
    }
  }

  Future<_AddItemFormResult?> _showAddItemDetailsDialog({
    required Uint8List selectedImageBytes,
  }) async {
    WardrobeCategory category = WardrobeCategory.tops;
    bool removeBackground = true;
    final nameController = TextEditingController();

    final result = await showModalBottomSheet<_AddItemFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Item Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<WardrobeCategory>(
                  initialValue: category,
                  isExpanded: true,
                  items: WardrobeCategory.values
                      .map(
                        (value) => DropdownMenuItem<WardrobeCategory>(
                          value: value,
                          child: Text(_categoryLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() {
                      category = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Selected photo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ColoredBox(
                        color: const Color(0xFFF3F4F6),
                        child: Image.memory(
                          selectedImageBytes,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Item name (e.g., Black hoodie)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: Text('Remove background with AI')),
                    Switch.adaptive(
                      value: removeBackground,
                      onChanged: (value) {
                        setLocalState(() {
                          removeBackground = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        Navigator.pop(
                          context,
                          _AddItemFormResult(
                            category: category,
                            name: name,
                            removeBackground: removeBackground,
                          ),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    nameController.dispose();
    return result;
  }

  Future<void> _removeItemBackground(int index) async {
    final original = widget.items[index];
    if (original.backgroundRemoved) return;

    try {
      final apiKey = await _ensureApiKey();
      if (apiKey == null || !mounted) return;
      final processed = await _bgService.removeBackground(
        imageBytes: original.imageBytes,
        fileName: original.name,
        apiKey: apiKey,
      );
      if (!mounted) return;
      widget.onUpdateItem(
        index,
        WardrobeItem(
          name: original.name,
          imageBytes: processed,
          backgroundRemoved: true,
          category: original.category,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background removed successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove background: $e')),
      );
    }
  }

  Future<String?> _ensureApiKey() async {
    if (_removeBgApiKey.trim().isNotEmpty) {
      return _removeBgApiKey.trim();
    }
    return _promptForApiKey();
  }

  Future<String?> _promptForApiKey() async {
    final controller = TextEditingController(text: _removeBgApiKey);
    String? value;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect AI background removal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your remove.bg API key to enable true AI background removal.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'remove.bg API key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              value = controller.text.trim();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (value == null || value!.isEmpty) return null;
    _removeBgApiKey = value!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyStorageKey, _removeBgApiKey);
    if (!mounted) return _removeBgApiKey;
    setState(() {});
    return _removeBgApiKey;
  }

  @override
  Widget build(BuildContext context) {
    final topCount = widget.items
        .where((item) => item.category == WardrobeCategory.tops)
        .length;
    final bottomCount = widget.items
        .where((item) => item.category == WardrobeCategory.bottoms)
        .length;
    final shoesCount = widget.items
        .where((item) => item.category == WardrobeCategory.shoes)
        .length;
    final outerwearCount = widget.items
        .where((item) => item.category == WardrobeCategory.outerwear)
        .length;
    final accessoriesCount = widget.items
        .where((item) => item.category == WardrobeCategory.accessories)
        .length;
    final categories = <String>[
      'All (${widget.items.length})',
      'Tops ($topCount)',
      'Bottoms ($bottomCount)',
      'Shoes ($shoesCount)',
      'Outerwear ($outerwearCount)',
      'Access. ($accessoriesCount)',
    ];
    final filteredEntries = widget.items.asMap().entries.where((entry) {
      if (_selectedCategoryIndex == 0) {
        return true;
      }
      final selected = WardrobeCategory.values[_selectedCategoryIndex - 1];
      return entry.value.category == selected;
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          const _AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'My Wardrobe',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.1,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: _promptForApiKey,
                          icon: Icon(
                            Icons.key_outlined,
                            size: 14,
                            color: _removeBgApiKey.trim().isEmpty
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF275AFF),
                          ),
                          label: Text(
                            _removeBgApiKey.trim().isEmpty ? 'AI Key' : 'AI On',
                            style: TextStyle(
                              fontSize: 12,
                              color: _removeBgApiKey.trim().isEmpty
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFF275AFF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: _handleAddItem,
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text(
                              'Add',
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3.35,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final isActive = _selectedCategoryIndex == index;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFF8FAFD)
                                  : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (filteredEntries.isEmpty) ...[
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          _selectedCategoryIndex == 0
                              ? 'No items in your wardrobe yet.'
                              : 'No items in this category yet.',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          'Tap "Add" to get started!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ] else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          final item = entry.value;
                          return _WardrobeItemCard(
                            item: item,
                            onRemoveBackground: () =>
                                _removeItemBackground(entry.key),
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
    );
  }
}

class _WardrobeItemCard extends StatefulWidget {
  const _WardrobeItemCard({
    required this.item,
    required this.onRemoveBackground,
  });

  final WardrobeItem item;
  final VoidCallback onRemoveBackground;

  @override
  State<_WardrobeItemCard> createState() => _WardrobeItemCardState();
}

class _WardrobeItemCardState extends State<_WardrobeItemCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final platform = defaultTargetPlatform;
    final touchOnlyPlatform = !kIsWeb &&
        (platform == TargetPlatform.android || platform == TargetPlatform.iOS);
    final showButton = _hovering || touchOnlyPlatform;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: const Color(0xFFF3F4F6),
                    child: Image.memory(
                      widget.item.imageBytes,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _categoryLabel(widget.item.category),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (widget.item.backgroundRemoved)
                const Text(
                  'AI background removed',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF275AFF),
                  ),
                )
              else if (showButton)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: InkWell(
                    onTap: widget.onRemoveBackground,
                    child: const Text(
                      'Remove background',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF275AFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class SavedOutfitsBody extends StatelessWidget {
  const SavedOutfitsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          _AppHeader(),
          Expanded(
            child: Center(
              child: Text(
                'No saved outfits yet.',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(WardrobeCategory category) {
  switch (category) {
    case WardrobeCategory.tops:
      return 'Tops';
    case WardrobeCategory.bottoms:
      return 'Bottoms';
    case WardrobeCategory.shoes:
      return 'Shoes';
    case WardrobeCategory.outerwear:
      return 'Outerwear';
    case WardrobeCategory.accessories:
      return 'Accessories';
  }
}
