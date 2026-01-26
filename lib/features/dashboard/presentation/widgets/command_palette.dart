import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/features/discovery/presentation/screens/discovery_screen.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutExpo,
      height: _isExpanded ? MediaQuery.of(context).size.height : 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _isExpanded ? RemediTheme.warmLimestone.withOpacity(0.95) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(_isExpanded ? 0 : 20),
      ),
      child: _isExpanded ? _buildFullScreenSearch() : _buildCompactSearch(),
    );
  }

  Widget _buildCompactSearch() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: RemediTheme.deepTeal),
                SizedBox(width: 12),
                Text(
                  'Ask the ancient text...',
                  style: TextStyle(color: RemediTheme.deepTeal, fontSize: 16),
                ),
                Spacer(),
                Icon(Icons.mic_rounded, color: RemediTheme.deepTeal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenSearch() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(fontSize: 24, color: RemediTheme.darkForest),
                        decoration: const InputDecoration(
                          hintText: 'Search symptoms...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: RemediTheme.mutedSage),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiscoveryScreen(query: value),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 32),
                      onPressed: _toggleExpanded,
                    ),
                  ],
                ),
                const Divider(color: RemediTheme.mutedSage),
                const SizedBox(height: 32),
                _buildSuggestionRow('Respiratory Relief'),
                _buildSuggestionRow('Immunity Boosters'),
                _buildSuggestionRow('Ancient Herbs for Sleep'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: RemediTheme.mutedSage, size: 20),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(fontSize: 18, color: RemediTheme.charcoal),
          ),
        ],
      ),
    );
  }
}
