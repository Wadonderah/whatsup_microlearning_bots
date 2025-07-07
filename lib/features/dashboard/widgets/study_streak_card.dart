import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudyStreakCard extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;

  const StudyStreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.lastStudyDate,
  });

  @override
  State<StudyStreakCard> createState() => _StudyStreakCardState();
}

class _StudyStreakCardState extends State<StudyStreakCard>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flameAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _flameController,
      curve: Curves.easeInOut,
    ));

    if (widget.currentStreak > 0) {
      _flameController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isStreakActive = _isStreakActive();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isStreakActive
              ? [
                  Colors.orange.withOpacity(0.1),
                  Colors.red.withOpacity(0.1),
                ]
              : [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isStreakActive
                ? Colors.orange.withOpacity(0.2)
                : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isStreakActive
              ? Colors.orange.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _flameAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isStreakActive ? _flameAnimation.value : 1.0,
                        child: Icon(
                          Icons.local_fire_department,
                          color: isStreakActive ? Colors.orange : Colors.grey,
                          size: 28,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Study Streak',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        isStreakActive ? 'Keep it going!' : 'Start your streak',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isStreakActive
                              ? Colors.orange
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.lastStudyDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isStreakActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getLastStudyText(),
                    style: TextStyle(
                      color: isStreakActive ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Streak Stats
          Row(
            children: [
              Expanded(
                child: _buildStreakStat(
                  context: context,
                  title: 'Current Streak',
                  value: '${widget.currentStreak}',
                  unit: 'days',
                  color: isStreakActive ? Colors.orange : Colors.grey,
                  isMain: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStreakStat(
                  context: context,
                  title: 'Best Streak',
                  value: '${widget.longestStreak}',
                  unit: 'days',
                  color: Colors.purple,
                  isMain: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Streak Calendar (simplified)
          _buildStreakCalendar(context),
        ],
      ),
    );
  }

  Widget _buildStreakStat({
    required BuildContext context,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required bool isMain,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: isMain ? 32 : 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 Days',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) {
            final isToday = DateFormat('yyyy-MM-dd').format(day) ==
                DateFormat('yyyy-MM-dd').format(now);
            final hasStudied = _hasStudiedOnDay(day);

            return Column(
              children: [
                Text(
                  DateFormat('E').format(day).substring(0, 1),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasStudied
                        ? Colors.orange
                        : theme.colorScheme.outline.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: hasStudied
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isStreakActive() {
    if (widget.lastStudyDate == null) return false;
    final now = DateTime.now();
    final lastStudy = widget.lastStudyDate!;
    final difference = now.difference(lastStudy).inDays;
    return difference <= 1 && widget.currentStreak > 0;
  }

  String _getLastStudyText() {
    if (widget.lastStudyDate == null) return 'Never';
    final now = DateTime.now();
    final lastStudy = widget.lastStudyDate!;
    final difference = now.difference(lastStudy).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${difference}d ago';
    }
  }

  bool _hasStudiedOnDay(DateTime day) {
    // Simplified logic - in real app, check actual study sessions
    if (widget.lastStudyDate == null) return false;
    final daysDiff = DateTime.now().difference(day).inDays;
    return daysDiff < widget.currentStreak;
  }
}
