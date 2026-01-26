import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';

class RedAlertModal extends StatelessWidget {
  const RedAlertModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFF8B0000), // High-contrast deep red
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 64),
          const SizedBox(height: 24),
          Text(
            'Emergency Detected',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our system indicates this may require immediate medical attention. RemediBook is for educational wellness only and is NOT a substitute for professional emergency services.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8B0000),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('CALL EMERGENCY (911/112)'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I am safe, continue to search', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }
}
