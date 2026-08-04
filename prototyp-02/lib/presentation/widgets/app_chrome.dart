// lib/presentation/widgets/app_chrome.dart
import 'package:flutter/material.dart';
import '../screens/privacy_info_screen.dart';

class GlobalFooterWrapper extends StatelessWidget {
  final Widget child;
  const GlobalFooterWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 40), child: child),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyInfoScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Impressum | Datenschutz',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Renamed from _AppBackground (private) to AppBackground (public) so other files can use it.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlobalFooterWrapper(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/gelb_verlauf.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withValues(alpha: 0.8)),
          child,
        ],
      ),
    );
  }
}
