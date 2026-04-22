import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wizdrobe/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('P#10 golden path: wardrobe → creator → outfits', (tester) async {
    const outfitName = 'Golden Path Outfit';

    runApp(const WizdrobeApp(bypassImagePicker: true));
    await tester.pumpAndSettle();

    // 1. Add clothing to the wardrobe
    await tester.tap(find.byKey(const ValueKey('wardrobe_add_item')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('add_item_name_field')),
      'Golden Path Tee',
    );
    await tester.tap(find.byKey(const ValueKey('add_item_remove_background_switch')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add_item_continue')));
    await tester.pumpAndSettle();

    expect(find.text('Golden Path Tee'), findsWidgets);

    // 2. Create outfit in the creator section
    await tester.tap(find.byKey(const ValueKey('nav_create')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('creator_outfit_name')),
      outfitName,
    );

    await tester.tap(find.byKey(const ValueKey('creator_add_from_wardrobe')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('wardrobe_picker_item_0')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('creator_save_outfit')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 3. View saved outfit
    await tester.tap(find.byKey(const ValueKey('nav_outfits')));
    await tester.pumpAndSettle();

    // Outfits tab shares an IndexedStack with Create; scope the title to the outfits pane.
    expect(
      find.descendant(
        of: find.byType(SavedOutfitsBody),
        matching: find.text(outfitName),
      ),
      findsOneWidget,
    );
  });
}
