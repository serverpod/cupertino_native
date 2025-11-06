import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Test page to verify that platform views don't overlay app bars, modals, bottom sheets, or dialogs.
class OverlayTestPage extends StatefulWidget {
  const OverlayTestPage({super.key});

  @override
  State<OverlayTestPage> createState() => _OverlayTestPageState();
}

class _OverlayTestPageState extends State<OverlayTestPage> {
  double _sliderValue = 0.5;
  bool _switchValue = false;
  int _segmentedControlIndex = 0;

  void _showModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPopupSurface(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Modal with Native Components',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 1,
                color: CupertinoColors.separator,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Button in Modal:'),
                    const SizedBox(height: 8),
                    CNButton(
                      label: 'Close Modal',
                      onPressed: () => Navigator.of(context).pop(),
                      config: const CNButtonConfig(
                        style: CNButtonStyle.filled,
                        shrinkWrap: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Slider in Modal:'),
                    const SizedBox(height: 8),
                    CNSlider(
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() => _sliderValue = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Switch in Modal:'),
                        CNSwitch(
                          value: _switchValue,
                          onChanged: (value) {
                            setState(() => _switchValue = value);
                          },
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
    );
  }

  void _showBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Bottom Sheet with Native Components'),
        message: const Text('These components should appear above the content below.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Action 1'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Action 2'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          isDefaultAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Dialog with Native Components'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('Icon in Dialog:'),
            const SizedBox(height: 8),
            const CNIcon(
              symbol: CNSymbol('checkmark.circle.fill', size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: CNButton uses LayoutBuilder which conflicts with dialog layout constraints. Use CupertinoButton in dialogs instead.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Overlay Test'),
        leading: CNButton.icon(
          icon: const CNSymbol('arrow.left', size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CNButton.icon(
          icon: const CNSymbol('info.circle', size: 18),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => const CupertinoAlertDialog(
                title: Text('Overlay Test'),
                content: Text(
                  'This page tests that native components don\'t overlay:\n'
                  '• App bars\n'
                  '• Modals\n'
                  '• Bottom sheets\n'
                  '• Dialogs\n\n'
                  'Try opening each overlay and verify the components appear correctly.',
                ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Overlay Test Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This page tests that native components respect z-ordering and don\'t overlay other widgets.',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 32),
            // Test buttons that open overlays
            const Text(
              'Open Overlays:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CNButton(
              label: 'Show Modal',
              onPressed: _showModal,
              config: const CNButtonConfig(
                style: CNButtonStyle.filled,
                shrinkWrap: true,
              ),
            ),
            const SizedBox(height: 12),
            CNButton(
              label: 'Show Bottom Sheet',
              onPressed: _showBottomSheet,
              config: const CNButtonConfig(
                style: CNButtonStyle.filled,
                shrinkWrap: true,
              ),
            ),
            const SizedBox(height: 12),
            CNButton(
              label: 'Show Dialog',
              onPressed: _showDialog,
              config: const CNButtonConfig(
                style: CNButtonStyle.filled,
                shrinkWrap: true,
              ),
            ),
            const SizedBox(height: 32),
            // Native components that should be below overlays
            const Text(
              'Native Components (should be below overlays):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Button:'),
            const SizedBox(height: 8),
            CNButton(
              label: 'Test Button',
              onPressed: () {},
              config: const CNButtonConfig(
                style: CNButtonStyle.tinted,
                shrinkWrap: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Slider:'),
            const SizedBox(height: 8),
            CNSlider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() => _sliderValue = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Switch:'),
                CNSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() => _switchValue = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Segmented Control:'),
            const SizedBox(height: 8),
            CNSegmentedControl(
              labels: const ['One', 'Two', 'Three'],
              selectedIndex: _segmentedControlIndex,
              onValueChanged: (value) {
                setState(() => _segmentedControlIndex = value);
              },
            ),
            const SizedBox(height: 16),
            const Text('Icon:'),
            const SizedBox(height: 8),
            const CNIcon(
              symbol: CNSymbol('star.fill', size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Popup Menu Button:'),
            const SizedBox(height: 8),
            CNPopupMenuButton(
              buttonLabel: 'Options',
              items: const [
                CNPopupMenuItem(label: 'Option 1'),
                CNPopupMenuItem(label: 'Option 2'),
                CNPopupMenuItem(label: 'Option 3'),
              ],
              onSelected: (index) {},
            ),
            const SizedBox(height: 32),
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Instructions:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Tap "Show Modal" - components in modal should appear above all content\n'
                    '2. Tap "Show Bottom Sheet" - bottom sheet should appear above all content\n'
                    '3. Tap "Show Dialog" - dialog should appear above all content\n'
                    '4. Verify that native components below don\'t overlay the app bar\n'
                    '5. Scroll the page and verify components stay within bounds',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

