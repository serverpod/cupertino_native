import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  String _last = 'None';
  bool _useAlternateSvgIcons = false;

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Text buttons'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Plain',
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Plain'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Gray',
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Gray'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Tinted',
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Tinted'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Bordered',
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Bordered'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'BorderedProminent',
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('BorderedProminent'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Filled',
                  style: CNButtonStyle.filled,
                  onPressed: () => _set('Filled'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Glass',
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Glass'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Glass Chat',
                  imageAsset: CNImageAsset('assets/icons/chat.svg', size: 18),
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Glass Chat'),
                  imagePadding: 10,
                  shrinkWrap: true,
                  height: 48,
                  horizontalPadding: 24,
                ),
                CNButton(
                  label: 'ProminentGlass',
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('ProminentGlass'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Disabled',
                  style: CNButtonStyle.bordered,
                  onPressed: null,
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Icon buttons (SF Symbols)'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Icon Plain'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Icon Gray'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Icon Tinted'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Icon Bordered'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('Icon BorderedProminent'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.filled,
                  onPressed: () => _set('Icon Filled'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Icon Glass'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('Icon ProminentGlass'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Icon buttons (Custom Icons)'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home, // Custom IconData!
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Custom Icon Plain'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Custom Icon Gray'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Custom Icon Tinted'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Custom Icon Bordered'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Custom Icon Glass'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Icon buttons (SVG Assets)'),
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _useAlternateSvgIcons = !_useAlternateSvgIcons;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CupertinoColors.systemBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _useAlternateSvgIcons ? 'Reset' : 'Switch',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/profile.svg'
                        : 'assets/icons/home.svg',
                    size: 18,
                  ),
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('SVG Plain'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/chat.svg'
                        : 'assets/icons/search.svg',
                    size: 18,
                  ),
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('SVG Gray'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/home.svg'
                        : 'assets/icons/profile.svg',
                    size: 18,
                  ),
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('SVG Tinted'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/search.svg'
                        : 'assets/icons/chat.svg',
                    size: 18,
                  ),
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('SVG Bordered'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/chat.svg'
                        : 'assets/icons/home.svg',
                    size: 18,
                    color: CupertinoColors.systemRed,
                  ),
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('SVG Glass'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/profile.svg'
                        : 'assets/icons/search.svg',
                    size: 18,
                    color: CupertinoColors.systemBlue,
                  ),
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('SVG ProminentGlass'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Image Placement'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Leading',
                  imageAsset: CNImageAsset('assets/icons/home.svg', size: 16),
                  imagePlacement: CNImagePlacement.leading,
                  imagePadding: 6.0,
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Leading'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Trailing',
                  imageAsset: CNImageAsset('assets/icons/search.svg', size: 16),
                  imagePlacement: CNImagePlacement.trailing,
                  imagePadding: 6.0,
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Trailing'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Top',
                  imageAsset: CNImageAsset(
                    'assets/icons/profile.svg',
                    size: 16,
                  ),
                  imagePlacement: CNImagePlacement.top,
                  imagePadding: 6.0,
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Top'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Bottom',
                  imageAsset: CNImageAsset('assets/icons/chat.svg', size: 16),
                  imagePlacement: CNImagePlacement.bottom,
                  imagePadding: 6.0,
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Bottom'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'ksdjksd jlajd  hjghjg hg ',
                  imageAsset: CNImageAsset(
                    'assets/icons/profile.svg',
                    size: 16,
                  ),
                  imagePlacement: CNImagePlacement.top,
                  imagePadding: 6.0,
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Top'),
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Image Padding'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'No Padding',
                  imageAsset: CNImageAsset('assets/icons/home.svg', size: 16),
                  imagePlacement: CNImagePlacement.leading,
                  onPressed: () => _set('No Padding'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'With Padding',
                  imageAsset: CNImageAsset('assets/icons/search.svg', size: 16),
                  imagePlacement: CNImagePlacement.leading,
                  imagePadding: 8.0,
                  onPressed: () => _set('With Padding'),
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Horizontal Padding'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Default',
                  onPressed: () => _set('Default'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Extra Padding',
                  horizontalPadding: 24.0,
                  onPressed: () => _set('Extra Padding'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Minimal',
                  horizontalPadding: 4.0,
                  onPressed: () => _set('Minimal'),
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 48),
            Center(child: Text('Last pressed: $_last')),
          ],
        ),
      ),
    );
  }
}
