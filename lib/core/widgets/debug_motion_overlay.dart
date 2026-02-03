import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../motion/motion_prefs.dart';
import '../theme/remedi_theme.dart';

/// DebugMotionOverlay - QA Tool for Motion System
/// Only visible in Debug Mode.
/// Allows toggling motion preference and seeing active background state.
class DebugMotionOverlay extends StatelessWidget {
  final Widget child;

  const DebugMotionOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // If not in debug mode, just return the child directly (zero overhead)
    if (!kDebugMode) return child;

    return Stack(
      children: [
        child,
        
        // Debug Toggle Panel (Top right, safely below status bar if needed)
        Positioned(
          top: 50,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: MotionPrefs.isMotionEnabled,
                builder: (context, isEnabled, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MOTION',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isEnabled ? 'ON' : 'OFF',
                            style: TextStyle(
                              color: isEnabled ? Colors.greenAccent : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Toggle Switch
                      SizedBox(
                        height: 24,
                        width: 40,
                        child: Switch(
                          value: isEnabled,
                          onChanged: (val) => MotionPrefs.setMotion(val),
                          activeColor: RemediTheme.emberGold,
                          activeTrackColor: RemediTheme.deepTeal,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.withOpacity(0.3),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
