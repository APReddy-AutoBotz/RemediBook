import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/features/remedies/presentation/widgets/circular_step_timer.dart';

class PrepSteps extends StatelessWidget {
  final List<String> remedyInstructions;
  
  const PrepSteps({super.key, required this.remedyInstructions});
  
  List<Map<String, dynamic>> get steps {
    return remedyInstructions.asMap().entries.map((entry) {
      return {
        "step": entry.key + 1,
        "title": _extractTitle(entry.value),
        "instruction": entry.value,
        "duration": null, // Could parse durations from instructions in future
      };
    }).toList();
  }
  
  String _extractTitle(String instruction) {
    // Extract first few words as title
    if (instruction.length > 30) {
      return instruction.substring(0, 25).split(' ').first;
    }
    return instruction.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            "PREPARATION PATH",
             style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: RemediTheme.charcoal.withOpacity(0.5),
              ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: steps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildStepTile(context, steps[index]);
          },
        ),
      ],
    );
  }

  Widget _buildStepTile(BuildContext context, Map<String, dynamic> step) {
    final stepNum = step["step"] as int;
    final title = step["title"] as String;
    final instruction = step["instruction"] as String;
    final duration = step["duration"] as Duration?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: RemediTheme.deepTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$stepNum",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: RemediTheme.deepTeal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: RemediTheme.deepTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instruction,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: RemediTheme.charcoal.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Timer (if exists)
          if (duration != null) ...[
            const SizedBox(width: 12),
            CircularStepTimer(
              duration: duration,
              onComplete: () {
                // Could trigger a confetti or toast here
                debugPrint("Step $stepNum Completed");
              },
            ),
          ],
        ],
      ),
    );
  }
}
