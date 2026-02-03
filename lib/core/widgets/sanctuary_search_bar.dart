import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/remedi_theme.dart';
import 'sanctuary_glass_card.dart';

/// SanctuarySearchBar - Premium glassmorphic search bar
/// 
/// Features:
/// - Glass styling (12% white fill, 25% border)
/// - Focus state: Teal glow + Ember Gold edge
/// - Haptic feedback on submit
class SanctuarySearchBar extends StatefulWidget {
  final String placeholder;
  final Function(String)? onSubmit;
  final VoidCallback? onTap;
  final bool readOnly;

  const SanctuarySearchBar({
    super.key,
    this.placeholder = 'Search...',
    this.onSubmit,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<SanctuarySearchBar> createState() => _SanctuarySearchBarState();
}

class _SanctuarySearchBarState extends State<SanctuarySearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: double.infinity, // Ensure full width for Expanded child
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.40), // Increased from 0.12 for visibility
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused
                ? const Color(0xFFD4A373).withOpacity(0.5) // Ember Gold on focus
                : RemediTheme.deepTeal.withOpacity(0.15), // Visible border
            width: _isFocused ? 1.5 : 1.0,
          ),
          boxShadow: [
             BoxShadow(
                color: RemediTheme.charcoal.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: _isFocused
                  ? RemediTheme.deepTeal
                  : RemediTheme.deepTeal.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: widget.readOnly
                  ? Text(
                      widget.placeholder,
                      style: TextStyle(
                        color: RemediTheme.charcoal.withOpacity(0.5),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : TextField(
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(
                          color: RemediTheme.charcoal.withOpacity(0.5),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        color: RemediTheme.charcoal,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      onSubmitted: (value) {
                        if (widget.onSubmit != null) {
                          try {
                            HapticFeedback.lightImpact();
                          } catch (e) {
                            // Safe fallback
                          }
                          widget.onSubmit!(value);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
