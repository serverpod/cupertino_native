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
                  onPressed: () => _set('Plain'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.plain,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Gray',
                  onPressed: () => _set('Gray'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.gray,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Tinted',
                  onPressed: () => _set('Tinted'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.tinted,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Bordered',
                  onPressed: () => _set('Bordered'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.bordered,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'BorderedProminent',
                  onPressed: () => _set('BorderedProminent'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.borderedProminent,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Filled',
                  onPressed: () => _set('Filled'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.filled,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Glass',
                  onPressed: () => _set('Glass'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Glass Chat',
                  imageAsset: CNImageAsset('assets/icons/chat.svg', size: 18),
                  onPressed: () => _set('Glass Chat'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    imagePadding: 10,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
                CNButton(
                  label: 'ProminentGlass',
                  onPressed: () => _set('ProminentGlass'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.prominentGlass,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Disabled',
                  onPressed: null,
                  config: const CNButtonConfig(
                    style: CNButtonStyle.bordered,
                    shrinkWrap: true,
                  ),
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
                  onPressed: () => _set('Icon Plain'),
                  config: const CNButtonConfig(style: CNButtonStyle.plain),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  onPressed: () => _set('Icon Gray'),
                  config: const CNButtonConfig(style: CNButtonStyle.gray),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  onPressed: () => _set('Icon Tinted'),
                  config: const CNButtonConfig(style: CNButtonStyle.tinted),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  onPressed: () => _set('Icon Bordered'),
                  config: const CNButtonConfig(style: CNButtonStyle.bordered),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  onPressed: () => _set('Icon BorderedProminent'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.borderedProminent,
                  ),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  onPressed: () => _set('Icon Filled'),
                  config: const CNButtonConfig(style: CNButtonStyle.filled),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  onPressed: () => _set('Icon Glass'),
                  config: const CNButtonConfig(style: CNButtonStyle.glass),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  onPressed: () => _set('Icon ProminentGlass'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.prominentGlass,
                  ),
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
                  onPressed: () => _set('Custom Icon Plain'),
                  config: const CNButtonConfig(style: CNButtonStyle.plain),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  onPressed: () => _set('Custom Icon Gray'),
                  config: const CNButtonConfig(style: CNButtonStyle.gray),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  onPressed: () => _set('Custom Icon Tinted'),
                  config: const CNButtonConfig(style: CNButtonStyle.tinted),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  onPressed: () => _set('Custom Icon Bordered'),
                  config: const CNButtonConfig(style: CNButtonStyle.bordered),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  customIcon: CupertinoIcons.home,
                  onPressed: () => _set('Custom Icon Glass'),
                  config: const CNButtonConfig(style: CNButtonStyle.glass),
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
                  onPressed: () => _set('SVG Plain'),
                  config: const CNButtonConfig(style: CNButtonStyle.plain),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/chat.svg'
                        : 'assets/icons/search.svg',
                    size: 18,
                  ),
                  onPressed: () => _set('SVG Gray'),
                  config: const CNButtonConfig(style: CNButtonStyle.gray),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/home.svg'
                        : 'assets/icons/profile.svg',
                    size: 18,
                  ),
                  onPressed: () => _set('SVG Tinted'),
                  config: const CNButtonConfig(style: CNButtonStyle.tinted),
                ),
                CNButton.icon(
                  icon: const CNSymbol('house.fill', size: 18),
                  imageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/search.svg'
                        : 'assets/icons/chat.svg',
                    size: 18,
                  ),
                  onPressed: () => _set('SVG Bordered'),
                  config: const CNButtonConfig(style: CNButtonStyle.bordered),
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
                  onPressed: () => _set('SVG Glass'),
                  config: const CNButtonConfig(style: CNButtonStyle.glass),
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
                  onPressed: () => _set('SVG ProminentGlass'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.prominentGlass,
                  ),
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
                  onPressed: () => _set('Leading'),
                  config: const CNButtonConfig(
                    imagePlacement: CNImagePlacement.leading,
                    imagePadding: 6.0,
                    style: CNButtonStyle.glass,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Trailing',
                  imageAsset: CNImageAsset('assets/icons/search.svg', size: 16),
                  onPressed: () => _set('Trailing'),
                  config: const CNButtonConfig(
                    imagePlacement: CNImagePlacement.trailing,
                    imagePadding: 6.0,
                    style: CNButtonStyle.glass,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Top',
                  imageAsset: CNImageAsset(
                    'assets/icons/profile.svg',
                    size: 16,
                  ),
                  onPressed: () => _set('Top'),
                  config: const CNButtonConfig(
                    imagePlacement: CNImagePlacement.top,
                    imagePadding: 6.0,
                    style: CNButtonStyle.glass,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Bottom',
                  imageAsset: CNImageAsset('assets/icons/chat.svg', size: 16),
                  onPressed: () => _set('Bottom'),
                  config: const CNButtonConfig(
                    imagePlacement: CNImagePlacement.bottom,
                    imagePadding: 6.0,
                    style: CNButtonStyle.glass,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Top',
                  imageAsset: CNImageAsset(
                    'assets/icons/profile.svg',
                    size: 16,
                  ),
                  onPressed: () => _set('Top'),
                  config: const CNButtonConfig(
                    imagePlacement: CNImagePlacement.top,
                    imagePadding: 6.0,
                    style: CNButtonStyle.glass,
                    shrinkWrap: true,
                  ),
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
                  onPressed: () => _set('No Padding'),
                  config: const CNButtonConfig(
                    imagePlacement: CNImagePlacement.leading,
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'With Padding',
                  imageAsset: CNImageAsset('assets/icons/search.svg', size: 16),
                  onPressed: () => _set('With Padding'),
                  config: const CNButtonConfig(
                    imagePlacement: CNImagePlacement.leading,
                    imagePadding: 8.0,
                    shrinkWrap: true,
                  ),
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
                  config: const CNButtonConfig(shrinkWrap: true),
                ),
                CNButton(
                  label: 'Extra Padding',
                  onPressed: () => _set('Extra Padding'),
                  config: const CNButtonConfig(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Minimal',
                  onPressed: () => _set('Minimal'),
                  config: const CNButtonConfig(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Liquid Glass Effects (iOS 26+)'),
            const SizedBox(height: 12),
            const Text(
              'These examples demonstrate Liquid Glass blending and morphing effects.',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            const Text('CNGlassButtonGroup - Horizontal Buttons'),
            const SizedBox(height: 12),
            const Text(
              'Using CNGlassButtonGroup for proper blending effects',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            CNGlassButtonGroup(
              axis: Axis.horizontal,
              spacing: 8.0,
              spacingForGlass: 40.0,
              buttons: [
                CNButton(
                  label: 'Home',
                  imageAsset: CNImageAsset('assets/icons/home.svg', size: 16),
                  onPressed: () => _set('Home'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectUnionId: 'toolbar-group',
                    glassEffectId: 'toolbar-home',
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Search',
                  imageAsset: CNImageAsset('assets/icons/search.svg', size: 16),
                  onPressed: () => _set('Search'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectUnionId: 'toolbar-group',
                    glassEffectId: 'toolbar-search',
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Profile',
                  imageAsset: CNImageAsset(
                    'assets/icons/profile.svg',
                    size: 16,
                  ),
                  onPressed: () => _set('Profile'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectUnionId: 'toolbar-group',
                    glassEffectId: 'toolbar-profile',
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Glass Effect Container with column of buttons - Using CNGlassButtonGroup
            const Text('Glass Effect Container - Column of Buttons'),
            const SizedBox(height: 12),
            const Text(
              'Vertical layout with proper blending',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            CNGlassButtonGroup(
              axis: Axis.vertical,
              spacing: 12.0,
              spacingForGlass: 40.0,
              buttons: [
                CNButton(
                  label: 'Option 1',
                  onPressed: () => _set('Option 1'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectUnionId: 'menu-group',
                    glassEffectId: 'menu-option-1',
                    shrinkWrap: true,
                    borderRadius: 12.0,
                  ),
                ),
                CNButton(
                  label: 'Option 2',
                  onPressed: () => _set('Option 2'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectUnionId: 'menu-group',
                    glassEffectId: 'menu-option-2',
                    shrinkWrap: true,
                    borderRadius: 12.0,
                  ),
                ),
                CNButton(
                  label: 'Option 3',
                  onPressed: () => _set('Option 3'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectUnionId: 'menu-group',
                    glassEffectId: 'menu-option-3',
                    shrinkWrap: true,
                    borderRadius: 12.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Buttons with glassEffectId for morphing - Using CNGlassButtonGroup
            const Text('Glass Effect ID - Morphing Transitions'),
            const SizedBox(height: 12),
            const Text(
              'Buttons with glassEffectId can morph into each other during transitions.',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            CNGlassButtonGroup(
              axis: Axis.horizontal,
              spacing: 24.0,
              spacingForGlass: 24.0,
              buttons: [
                CNButton(
                  label: 'Morph Button 1',
                  customIcon: CupertinoIcons.heart_fill,
                  onPressed: () => _set('Morph Button 1'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectId: 'morph-button',
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Morph Button 2',
                  customIcon: CupertinoIcons.star_fill,
                  onPressed: () => _set('Morph Button 2'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectId: 'morph-button',
                    shrinkWrap: true,
                  ),
                ),
                CNButton(
                  label: 'Morph Button 3',
                  customIcon: CupertinoIcons.bookmark_fill,
                  onPressed: () => _set('Morph Button 3'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectId: 'morph-button',
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Interactive glass effects
            const Text('Interactive Glass Effects'),
            const SizedBox(height: 12),
            const Text(
              'Interactive glass effects respond to touch and pointer interactions in real time.',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Interactive',
                  onPressed: () => _set('Interactive'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectInteractive: true,
                    shrinkWrap: true,
                  ),
                ),
                CNButton.icon(
                  icon: const CNSymbol('hand.tap.fill', size: 18),
                  onPressed: () => _set('Interactive Icon'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.glass,
                    glassEffectInteractive: true,
                  ),
                ),
                CNButton(
                  label: 'Prominent Interactive',
                  onPressed: () => _set('Prominent Interactive'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.prominentGlass,
                    glassEffectInteractive: true,
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Combined example: Union + ID + Interactive - Using CNGlassButtonGroup
            const Text('Combined Effects'),
            const SizedBox(height: 12),
            const Text(
              'Buttons can combine union, ID, and interactive effects.',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            CNGlassButtonGroup(
              axis: Axis.horizontal,
              spacing: 8.0,
              spacingForGlass: 40.0,
              buttons: [
                CNButton.icon(
                  icon: const CNSymbol('play.fill', size: 18),
                  onPressed: () => _set('Play'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.prominentGlass,
                    glassEffectUnionId: 'media-controls',
                    glassEffectId: 'play-button',
                    glassEffectInteractive: true,
                  ),
                ),
                CNButton.icon(
                  icon: const CNSymbol('pause.fill', size: 18),
                  onPressed: () => _set('Pause'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.prominentGlass,
                    glassEffectUnionId: 'media-controls',
                    glassEffectId: 'pause-button',
                    glassEffectInteractive: true,
                  ),
                ),
                CNButton.icon(
                  icon: const CNSymbol('stop.fill', size: 18),
                  onPressed: () => _set('Stop'),
                  config: const CNButtonConfig(
                    style: CNButtonStyle.prominentGlass,
                    glassEffectUnionId: 'media-controls',
                    glassEffectId: 'stop-button',
                    glassEffectInteractive: true,
                  ),
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
