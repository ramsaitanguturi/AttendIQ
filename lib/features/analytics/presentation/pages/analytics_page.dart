import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/analytics/models/attendance_analytics.dart';
import '../../../../core/analytics/models/risk_status.dart';
import '../controllers/analytics_controller.dart';
import '../../../attendance/presentation/controllers/subject_attendance_stats_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _trendPeriod = 'weekly'; // 'daily', 'weekly', 'monthly'

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Attendance Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          if (analytics == null) {
            return const Center(
              child: Text(
                'No active semester found.\nPlease complete onboarding first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Overall Statistics Hero Card
                  _buildOverallHeroCard(analytics, isDark),
                  const SizedBox(height: 24.0),

                  // 2. Streaks Card
                  _buildStreakCard(analytics.attendanceStreak, isDark),
                  const SizedBox(height: 24.0),

                  // 3. Attendance Trend Chart (Line Chart)
                  _buildTrendChartSection(analytics.attendanceTrend, isDark),
                  const SizedBox(height: 24.0),

                  // 4. Subject Comparison Chart (Bar Chart)
                  _buildSubjectComparisonChartSection(analytics.subjectComparison, isDark),
                  const SizedBox(height: 24.0),

                  // 5. Subject Ranking Summary Card
                  _buildComparisonRankingCard(analytics.subjectComparison, isDark),
                  const SizedBox(height: 24.0),

                  // 6. Risk Level Subjects Section
                  _buildRiskSubjectsSection(analytics, isDark),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error loading analytics data: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallHeroCard(AttendanceAnalytics analytics, bool isDark) {
    Color riskColor = AppColors.primary;
    String riskTitle = 'Safe';
    if (analytics.riskLevel == RiskStatus.CRITICAL) {
      riskColor = AppColors.attendanceLow;
      riskTitle = 'Critical';
    } else if (analytics.riskLevel == RiskStatus.WARNING) {
      riskColor = AppColors.attendanceMid;
      riskTitle = 'Warning';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Attendance',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  riskTitle,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${analytics.overallPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.w900,
                      color: riskColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current Percentage',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              _buildMetricItem('Classes', '${analytics.totalClasses}', isDark),
              _buildMetricItem('Present', '${analytics.totalPresent}', isDark),
              _buildMetricItem('Absent', '${analytics.totalAbsent}', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.0,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(AttendanceStreak streak, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)]
              : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: isDark ? Colors.orange : Colors.deepOrange,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${streak.currentStreak} Classes',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Current Streak',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: isDark ? Colors.amber : Colors.amber[700],
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${streak.longestPresentStreak} Classes',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Longest Streak',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChartSection(AttendanceTrend trend, bool isDark) {
    List<TrendPoint> points = [];
    if (_trendPeriod == 'daily') {
      points = trend.daily;
    } else if (_trendPeriod == 'weekly') {
      points = trend.weekly;
    } else {
      points = trend.monthly;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Trend',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildPeriodSelectorButton('daily', 'D', isDark),
                    _buildPeriodSelectorButton('weekly', 'W', isDark),
                    _buildPeriodSelectorButton('monthly', 'M', isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: points.isEmpty
                ? const Center(child: Text('No trend data available'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: (points.length / 5).clamp(1.0, 100.0),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              final date = points[index].date;
                              return Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      minX: 0,
                      maxX: (points.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(points.length, (index) {
                            return FlSpot(index.toDouble(), points[index].percentage);
                          }),
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF00BFFF)],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: points.length < 15,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: AppColors.primary,
                              strokeWidth: 1.5,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                const Color(0xFF00BFFF).withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelectorButton(String period, String label, bool isDark) {
    final isSelected = _trendPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _trendPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectComparisonChartSection(
    SubjectComparison comparison,
    bool isDark,
  ) {
    // Collect all subjects
    final refStats = ref.watch(allSubjectAttendanceStatsProvider);
    final statsList = refStats.valueOrNull ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Comparison',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: statsList.isEmpty
                ? const Center(child: Text('No subject comparison data'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => isDark ? AppColors.darkSurface : Colors.white,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final subjectName = statsList[group.x.toInt()].subject.name;
                            return BarTooltipItem(
                              '$subjectName\n${rod.toY.toStringAsFixed(1)}%',
                              TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= statsList.length) {
                                return const SizedBox.shrink();
                              }
                              final subject = statsList[index].subject;
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  subject.code,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(statsList.length, (index) {
                        final stats = statsList[index];
                        final color = _parseColor(stats.subject.color);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: stats.attendancePercentage,
                              color: color,
                              width: 16,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRankingCard(SubjectComparison comparison, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Summary',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            'Highest Attendance',
            comparison.highestAttendanceSubject?.subjectName ?? 'N/A',
            '${comparison.highestAttendanceSubject?.percentage.toStringAsFixed(1) ?? '0.0'}%',
            AppColors.primary,
            isDark,
          ),
          const Divider(height: 24),
          _buildComparisonRow(
            'Lowest Attendance',
            comparison.lowestAttendanceSubject?.subjectName ?? 'N/A',
            '${comparison.lowestAttendanceSubject?.percentage.toStringAsFixed(1) ?? '0.0'}%',
            AppColors.attendanceLow,
            isDark,
          ),
          const Divider(height: 24),
          _buildComparisonRow(
            'Most Attended Subject',
            comparison.mostAttendedSubject?.subjectName ?? 'N/A',
            '${comparison.mostAttendedSubject?.present ?? 0} classes',
            Colors.blue,
            isDark,
          ),
          const Divider(height: 24),
          _buildComparisonRow(
            'Most Missed Subject',
            comparison.mostMissedSubject?.subjectName ?? 'N/A',
            '${comparison.mostMissedSubject?.absent ?? 0} classes',
            Colors.orange,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String title,
    String subjectName,
    String statValue,
    Color statColor,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subjectName,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          statValue,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: statColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskSubjectsSection(AttendanceAnalytics analytics, bool isDark) {
    // Let's watch all subjects analytics from the provider and list the Warning/Critical ones
    final refStats = ref.watch(allSubjectAttendanceStatsProvider);
    final statsList = refStats.valueOrNull ?? [];

    final riskList = statsList.where((stats) {
      final percentage = stats.attendancePercentage;
      final target = stats.subject.attendanceTarget;
      return percentage < target || (percentage - target <= 2.5);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Risk Analysis (Warning / Critical)',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (riskList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: const Center(
              child: Text(
                '🎉 All subjects are in the safe zone!',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: riskList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final stats = riskList[index];
              final percentage = stats.attendancePercentage;
              final target = stats.subject.attendanceTarget;
              final isCritical = percentage < target;

              final badgeColor = isCritical ? AppColors.attendanceLow : AppColors.attendanceMid;
              final badgeText = isCritical ? 'Critical' : 'Warning';

              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats.subject.name,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCritical
                                ? 'Need ${stats.requiredClasses} consecutive classes'
                                : 'Safe bunks: ${stats.safeBunks}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}
