import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/services/healing_schedule_service.dart';

/// Interactive Daily Path Timeline Widget - PILLAR 3
/// Displays dynamic 24-hour healing schedule with block grouping
class DailyPathTimeline extends StatefulWidget {
  final List<ScheduleSlot> schedule;
  final Function(int completedCount, int totalCount)? onCompletionChanged;

  const DailyPathTimeline({
    super.key,
    required this.schedule,
    this.onCompletionChanged,
  });

  @override
  State<DailyPathTimeline> createState() => _DailyPathTimelineState();
}

class _DailyPathTimelineState extends State<DailyPathTimeline> {
  void _onItemToggled(int index) {
    setState(() {
      widget.schedule[index].isCompleted = !widget.schedule[index].isCompleted;
      widget.schedule[index].completedAt = 
          widget.schedule[index].isCompleted ? DateTime.now() : null;
    });

    // Trigger haptic feedback on completion
    if (widget.schedule[index].isCompleted) {
      HapticFeedback.mediumImpact();
    }

    // Notify parent of completion change
    final completedCount = widget.schedule.where((item) => item.isCompleted).length;
    widget.onCompletionChanged?.call(completedCount, widget.schedule.length);
  }

  /// Group schedule slots by block
  Map<ScheduleBlock, List<ScheduleSlot>> _groupByBlock() {
    final grouped = <ScheduleBlock, List<ScheduleSlot>>{};
    
    for (final slot in widget.schedule) {
      grouped.putIfAbsent(slot.block, () => []).add(slot);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedule.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Daily Path',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Text(
            'Generating your personalized schedule...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: RemediTheme.charcoal.withOpacity(0.5),
            ),
          ),
        ],
      );
    }

    final groupedSlots = _groupByBlock();
    final blockOrder = [
      ScheduleBlock.morning,
      ScheduleBlock.midDay,
      ScheduleBlock.evening,
      ScheduleBlock.night,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Daily Path',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Your personalized 24-hour healing schedule',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: RemediTheme.charcoal.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 32),
        
        // Render blocks in order
        ...blockOrder.where((block) => groupedSlots.containsKey(block)).map((block) {
          final slotsInBlock = groupedSlots[block]!;
          return _buildBlock(block, slotsInBlock);
        }).toList(),
      ],
    );
  }

  Widget _buildBlock(ScheduleBlock block, List<ScheduleSlot> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Block header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: RemediTheme.deepTeal.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HealingScheduleService.getBlockName(block),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: RemediTheme.deepTeal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    HealingScheduleService.getBlockTimeRange(block),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RemediTheme.charcoal.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Slots in this block
        ...List.generate(slots.length, (index) {
          final globalIndex = widget.schedule.indexOf(slots[index]);
          return PathItemWidget(
            key: ValueKey(slots[index].time),
            slot: slots[index],
            onToggle: () => _onItemToggled(globalIndex),
            isLast: index == slots.length - 1,
          );
        }),
        
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Individual Path Item Widget with interactive states
class PathItemWidget extends StatefulWidget {
  final ScheduleSlot slot;
  final VoidCallback onToggle;
  final bool isLast;

  const PathItemWidget({
    super.key,
    required this.slot,
    required this.onToggle,
    this.isLast = false,
  });

  @override
  State<PathItemWidget> createState() => _PathItemWidgetState();
}

class _PathItemWidgetState extends State<PathItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup pulse animation for current window items
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse if in current window
    if (widget.slot.isInCurrentWindow() && !widget.slot.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getIconBackgroundColor() {
    if (widget.slot.isCompleted) {
      return RemediTheme.deepTeal;
    } else if (widget.slot.isFuture()) {
      return RemediTheme.mutedSage.withOpacity(0.15);
    } else if (widget.slot.isMissed()) {
      return RemediTheme.mutedSage.withOpacity(0.3);
    } else if (widget.slot.isInCurrentWindow()) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  Color _getIconColor() {
    if (widget.slot.isCompleted) {
      return Colors.white;
    } else if (widget.slot.isFuture()) {
      return RemediTheme.mutedSage.withOpacity(0.5);
    } else if (widget.slot.isMissed()) {
      return RemediTheme.mutedSage;
    } else if (widget.slot.isInCurrentWindow()) {
      return RemediTheme.emberGold;
    } else {
      return RemediTheme.deepTeal;
    }
  }

  Widget _buildIcon() {
    final iconWidget = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.slot.isCompleted 
              ? RemediTheme.deepTeal.withOpacity(0.2)
              : widget.slot.isInCurrentWindow()
                  ? RemediTheme.emberGold.withOpacity(0.3)
                  : widget.slot.isFuture()
                      ? RemediTheme.mutedSage.withOpacity(0.2)
                      : RemediTheme.deepTeal.withOpacity(0.2),
        ),
        boxShadow: [
          if (widget.slot.isCompleted) BoxShadow(
            color: RemediTheme.deepTeal.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          if (widget.slot.isInCurrentWindow() && !widget.slot.isCompleted) BoxShadow(
            color: RemediTheme.emberGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.slot.isCompleted ? Icons.check : widget.slot.icon,
        size: 16,
        color: _getIconColor(),
      ),
    );

    // Add pulse animation for current window
    if (widget.slot.isInCurrentWindow() && !widget.slot.isCompleted) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  @override
  Widget build(BuildContext context) {
    final isFuture = widget.slot.isFuture();
    
    return GestureDetector(
      onTap: isFuture ? null : widget.onToggle, // Disable tap for future slots
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isFuture ? 0.5 : 1.0, // Dim future slots
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  widget.slot.time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isFuture 
                        ? RemediTheme.charcoal.withOpacity(0.3)
                        : RemediTheme.charcoal.withOpacity(0.5),
                  ),
                ),
              ),
              Column(
                children: [
                  _buildIcon(),
                  if (!widget.isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: RemediTheme.deepTeal.withOpacity(0.1),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.slot.isCompleted 
                                  ? RemediTheme.charcoal.withOpacity(0.5) 
                                  : isFuture
                                      ? RemediTheme.charcoal.withOpacity(0.4)
                                      : widget.slot.isMissed()
                                          ? RemediTheme.mutedSage
                                          : RemediTheme.charcoal,
                              decoration: widget.slot.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            child: Text(widget.slot.title),
                          ),
                        ),
                        if (isFuture)
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: RemediTheme.mutedSage.withOpacity(0.5),
                          ),
                      ],
                    ),
                    Text(
                      widget.slot.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isFuture
                            ? RemediTheme.charcoal.withOpacity(0.3)
                            : RemediTheme.charcoal.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
