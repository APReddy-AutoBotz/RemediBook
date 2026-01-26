import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../domain/services/triage_service.dart';

/// Triage Guardian Widget - Symptom Input Scanner
/// Scans user input and triggers appropriate safety UI
class TriageGuardianWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(TriageResult) onTriageResult;
  final String hintText;

  const TriageGuardianWidget({
    super.key,
    required this.controller,
    required this.onTriageResult,
    this.hintText = 'Describe your symptoms...',
  });

  @override
  State<TriageGuardianWidget> createState() => _TriageGuardianWidgetState();
}

class _TriageGuardianWidgetState extends State<TriageGuardianWidget> {
  TriageResult? _lastResult;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      setState(() => _lastResult = null);
      return;
    }

    final result = TriageInterceptor.scan(text);
    
    // Only update if result changed
    if (_lastResult?.level != result.level) {
      setState(() => _lastResult = result);
      widget.onTriageResult(result);

      // Trigger UI based on triage level
      if (result.isEmergency) {
        _showHardRedModal(result);
      }
    }
  }

  void _showHardRedModal(TriageResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HardRedEmergencyModal(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: widget.controller,
          maxLines: 4,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: RemediTheme.charcoal.withOpacity(0.4),
                ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
              borderSide: BorderSide(
                color: RemediTheme.deepTeal.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
              borderSide: BorderSide(
                color: RemediTheme.deepTeal.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
              borderSide: const BorderSide(
                color: RemediTheme.deepTeal,
                width: 2,
              ),
            ),
          ),
        ),

        // Soft Amber Warning (if caution detected)
        if (_lastResult?.isCaution == true) ...[
          const SizedBox(height: RemediTheme.spaceSM),
          SoftAmberWarningBanner(result: _lastResult!),
        ],
      ],
    );
  }
}

/// Hard Red Emergency Modal - Full Screen
/// Clinical Calm urgent styling with single primary action
class HardRedEmergencyModal extends StatelessWidget {
  final TriageResult result;

  const HardRedEmergencyModal({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(RemediTheme.spaceMD),
      child: Container(
        decoration: BoxDecoration(
          color: RemediTheme.warmLimestone,
          borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
          border: Border.all(
            color: const Color(0xFFDC2626), // Hard Red
            width: 3,
          ),
        ),
        padding: const EdgeInsets.all(RemediTheme.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emergency Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),

            const SizedBox(height: RemediTheme.spaceMD),

            // Title
            Text(
              'Emergency Detected',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: RemediTheme.spaceSM),

            // Message
            Text(
              result.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: RemediTheme.spaceMD),

            // Triggered keywords (subtle)
            if (result.triggeredKeywords.isNotEmpty) ...[
              Text(
                'Detected: ${result.triggeredKeywords.take(2).join(", ")}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: RemediTheme.charcoal.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: RemediTheme.spaceMD),
            ],

            // Primary Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // In real app, would trigger phone dialer
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.phone, size: 20),
                label: Text(result.actionRequired ?? 'Call Emergency Services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: RemediTheme.spaceMD,
                  ),
                ),
              ),
            ),

            const SizedBox(height: RemediTheme.spaceSM),

            // Secondary Action
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'I Understand the Risk',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: RemediTheme.charcoal.withOpacity(0.6),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft Amber Warning Banner - Inline
/// Requires checkbox acknowledgment
class SoftAmberWarningBanner extends StatefulWidget {
  final TriageResult result;

  const SoftAmberWarningBanner({
    super.key,
    required this.result,
  });

  @override
  State<SoftAmberWarningBanner> createState() => _SoftAmberWarningBannerState();
}

class _SoftAmberWarningBannerState extends State<SoftAmberWarningBanner> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RemediTheme.spaceMD),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.08), // Soft Amber
        borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFF59E0B),
                size: 24,
              ),
              const SizedBox(width: RemediTheme.spaceSM),
              Expanded(
                child: Text(
                  'Caution Required',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: RemediTheme.spaceSM),

          // Message
          Text(
            widget.result.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
          ),

          const SizedBox(height: RemediTheme.spaceSM),

          // Acknowledgment Checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _acknowledged,
                  onChanged: (value) {
                    setState(() => _acknowledged = value ?? false);
                  },
                  activeColor: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: RemediTheme.spaceSM),
              Expanded(
                child: Text(
                  'I acknowledge this caution and will consult a healthcare provider if symptoms persist',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
