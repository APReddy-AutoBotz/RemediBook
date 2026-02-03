import 'package:flutter/material.dart';
import '../theme/remedi_theme.dart';

/// SanctuaryTextField - Premium Glass Text Input
/// Soft border, proper padding, leading/trailing icons
class SanctuaryTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final IconData? leadingIcon;
  final Widget? trailingAction;
  final VoidCallback? onSubmitted;
  final int maxLines;

  const SanctuaryTextField({
    super.key,
    this.hint,
    this.controller,
    this.leadingIcon,
    this.trailingAction,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  State<SanctuaryTextField> createState() => _SanctuaryTextFieldState();
}

class _SanctuaryTextFieldState extends State<SanctuaryTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(RemediTheme.radiusButton),
        border: Border.all(
          color: _isFocused
              ? RemediTheme.emberGold.withOpacity(0.5)
              : Colors.white.withOpacity(0.25),
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: RemediTheme.emberGold.withOpacity(0.1),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (widget.leadingIcon != null) ...[
            Icon(
              widget.leadingIcon,
              size: 20,
              color: RemediTheme.charcoal.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              maxLines: widget.maxLines,
              onSubmitted: (_) => widget.onSubmitted?.call(),
              style: TextStyle(
                fontSize: 15,
                color: RemediTheme.charcoal,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: RemediTheme.charcoal.withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (widget.trailingAction != null) ...[
            const SizedBox(width: 8),
            widget.trailingAction!,
          ],
        ],
      ),
    );
  }
}
