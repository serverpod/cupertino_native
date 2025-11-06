import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class AppBarDemoPage extends StatelessWidget {
  const AppBarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Liquid Glass Examples'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Liquid Glass Extension Examples',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Text with Liquid Glass (Capsule)',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 8),
            const Text('Hello, World!').liquidGlass(),
            const SizedBox(height: 24),
            const Text(
              'Text with Liquid Glass (Rectangle)',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Hello, World!'),
            ).liquidGlass(
              shape: CNGlassEffectShape.capsule,
              cornerRadius: 8.0,
              interactive: true,
            ),

            const SizedBox(height: 24),
            const Text(
              'Text with Liquid Glass (Tinted & Interactive)',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 8),
            const Text('Hello, World!').liquidGlass(
              effect: CNGlassEffect.regular,
              tint: CupertinoColors.systemOrange,
              interactive: true,
              
            ),
            const SizedBox(height: 24),
            const Text(
              'Button with Liquid Glass',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 8),
            CNButton(
              label: 'Glass Button',
              onPressed: () {},
              config: const CNButtonConfig(
                style: CNButtonStyle.glass,
                shrinkWrap: true,
              ),
            ).liquidGlass(shape: CNGlassEffectShape.rect, cornerRadius: 12.0),
          ],
        ),
      ),
    );
  }
}
