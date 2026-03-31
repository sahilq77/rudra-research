import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_report/get_survey_report_response.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_survey_view.dart/my_report_survey_chart_controller.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/responsive_utils.dart'
    show ResponsiveHelper, AppStyleResponsive;
import '../../../../widgets/app_style.dart';

const List<Color> _chartColors = [
  Colors.cyan,
  Colors.orange,
  Colors.green,
  Colors.purple,
  Colors.pink,
  Colors.teal,
  Colors.indigo,
];

class MyReportSurveyView extends StatelessWidget {
  const MyReportSurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final MyReportSurveyChartController controller = Get.put(
      MyReportSurveyChartController(),
    );
    return Scaffold(
      appBar: _buildAppbar('Survey Report'),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        backgroundColor: AppColors.white,
        child: Obx(
          () =>
              controller.surveyData.isEmpty &&
                  controller.locationHierarchy.isEmpty
              ? _buildNoReportScreen()
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // ── Existing pie chart cards ──
                    ...List.generate(controller.surveyData.length, (index) {
                      final data = controller.surveyData[index];
                      final total = data.sections.fold(
                        0.0,
                        (s, e) => s + e.value,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          color: Colors.black,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          data.title,
                                          style: AppStyle
                                              .reportCardTitle
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
                                                      16,
                                                    ),
                                              ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total Count',
                                          style: AppStyle
                                              .reportCardRowCount
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
                                                      12,
                                                    ),
                                              ),
                                        ),
                                        Text(
                                          '$total',
                                          style: AppStyle
                                              .reportCardRowCount
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
                                                      12,
                                                    ),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(),
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sections: data.sections
                                          .map(
                                            (s) => PieChartSectionData(
                                              color: s.color,
                                              value: s.value,
                                              radius: 60,
                                              titleStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 30,
                                      pieTouchData: PieTouchData(
                                        touchCallback: (e, _) {},
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...data.sections.map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          color: s.color,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          s.label,
                                          style: AppStyle
                                              .reportCardRowCount
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
                                                      12,
                                                    ),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // ── Ward Count by Assembly (replaces Ward & Area count cards) ──
                    if (controller.locationHierarchy.isNotEmpty)
                      _LocationHierarchySection(
                        hierarchy: controller.locationHierarchy,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNoReportScreen() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: Get.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, size: 80, color: AppColors.grey),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Text(
                'No Report Data Available',
                style: AppStyle.heading1PoppinsGrey.responsive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(String title) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Get.back(),
      ),
      title: Text(title, style: AppStyle.heading1PoppinsWhite.responsive),
    );
  }
}

// ─────────────────────────────────────────────
// Ward Count by Assembly section
// ─────────────────────────────────────────────
class _LocationHierarchySection extends StatelessWidget {
  final List<LocationHierarchy> hierarchy;
  const _LocationHierarchySection({required this.hierarchy});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ward Count by Assembly',
              style: AppStyle.reportCardTitle.responsive.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...hierarchy.map((a) => _AssemblyTile(assembly: a)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Assembly tile → expands: ward pie chart + table + ward tiles
// ─────────────────────────────────────────────
class _AssemblyTile extends StatefulWidget {
  final LocationHierarchy assembly;
  const _AssemblyTile({required this.assembly});
  @override
  State<_AssemblyTile> createState() => _AssemblyTileState();
}

class _AssemblyTileState extends State<_AssemblyTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final wards = widget.assembly.wards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RowHeader(
          expanded: _expanded,
          title: widget.assembly.assemblyName,
          subtitle: 'Click to view wards',
          trailing:
              '${widget.assembly.assemblyResponseCount} responses (${wards.length} wards)',
          accentColor: AppColors.primary,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded && wards.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Ward pie chart + table
          _ChartTablePanel(
            title: '${widget.assembly.assemblyName} - Wards',
            chartLabel: 'Ward Count Chart',
            names: wards.map((w) => w.wardName).toList(),
            counts: wards
                .map((w) => int.tryParse(w.wardResponseCount) ?? 0)
                .toList(),
          ),
          const SizedBox(height: 8),
          // Ward tiles for drill-down
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              children: wards
                  .map(
                    (w) => _WardTile(
                      ward: w,
                      assemblyName: widget.assembly.assemblyName,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Ward tile → expands: village list + area pie chart + table
//             tap village → filter chart to that village
// ─────────────────────────────────────────────
class _WardTile extends StatefulWidget {
  final WardHierarchy ward;
  final String assemblyName;
  const _WardTile({required this.ward, required this.assemblyName});
  @override
  State<_WardTile> createState() => _WardTileState();
}

class _WardTileState extends State<_WardTile> {
  bool _expanded = false;
  int? _selectedVillageIndex;

  @override
  Widget build(BuildContext context) {
    final villages = widget.ward.villages;
    final allNames = villages.map((v) => v.areaName).toList();
    final allCounts = villages
        .map((v) => int.tryParse(v.villageResponseCount) ?? 0)
        .toList();

    final chartNames = _selectedVillageIndex == null
        ? allNames
        : [allNames[_selectedVillageIndex!]];
    final chartCounts = _selectedVillageIndex == null
        ? allCounts
        : [allCounts[_selectedVillageIndex!]];
    final chartTitle = _selectedVillageIndex == null
        ? '${widget.assemblyName} - ${widget.ward.wardName} Areas'
        : '${widget.assemblyName} - ${allNames[_selectedVillageIndex!]}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RowHeader(
          expanded: _expanded,
          title: widget.ward.wardName,
          subtitle: 'Click to view areas',
          trailing:
              '${widget.ward.wardResponseCount} responses (${villages.length} areas)',
          accentColor: Colors.orange,
          onTap: () => setState(() {
            _expanded = !_expanded;
            if (!_expanded) _selectedVillageIndex = null;
          }),
        ),
        if (_expanded && villages.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Village rows
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              children: villages.asMap().entries.map((e) {
                final isSelected = _selectedVillageIndex == e.key;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedVillageIndex = isSelected ? null : e.key;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.teal.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? Colors.teal : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _chartColors[e.key % _chartColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.value.areaName,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                12,
                              ),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          '${e.value.villageResponseCount} responses',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              11,
                            ),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isSelected
                              ? Icons.pie_chart
                              : Icons.pie_chart_outline,
                          size: 16,
                          color: isSelected ? Colors.teal : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Area pie chart + table
          _ChartTablePanel(
            title: chartTitle,
            chartLabel: 'Area Count Chart',
            names: chartNames,
            counts: chartCounts,
            highlightIndex: _selectedVillageIndex,
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Reusable expandable row header
// ─────────────────────────────────────────────
class _RowHeader extends StatelessWidget {
  final bool expanded;
  final String title;
  final String subtitle;
  final String trailing;
  final Color accentColor;
  final VoidCallback onTap;

  const _RowHeader({
    required this.expanded,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: expanded
              ? accentColor.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: expanded
                ? accentColor.withOpacity(0.4)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyle.reportCardTitle.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(11),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailing,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(11),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Pie chart + table panel
// ─────────────────────────────────────────────
class _ChartTablePanel extends StatelessWidget {
  final String title;
  final String chartLabel;
  final List<String> names;
  final List<int> counts;
  final int? highlightIndex;

  const _ChartTablePanel({
    required this.title,
    required this.chartLabel,
    required this.names,
    required this.counts,
    this.highlightIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorOffset = highlightIndex ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(13),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            chartLabel,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(12),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: counts.asMap().entries.map((e) {
                  final colorIdx =
                      (highlightIndex != null ? colorOffset : e.key) %
                      _chartColors.length;
                  return PieChartSectionData(
                    color: _chartColors[colorIdx],
                    value: e.value.toDouble(),
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...names.asMap().entries.map((e) {
            final colorIdx =
                (highlightIndex != null ? colorOffset : e.key) %
                _chartColors.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: _chartColors[colorIdx],
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
