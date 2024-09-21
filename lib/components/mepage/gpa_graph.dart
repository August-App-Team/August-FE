import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class GPAGraph extends StatelessWidget {
  final List<GraphData> chartData;

  GPAGraph({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10, // 블러 효과를 줄여서 그림자를 더 세밀하게
              offset: Offset(4, -1), // 좌우 그림자의 길이를 줄임
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10,
              offset: Offset(-1, 0), // 좌우 그림자의 길이를 줄임
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10, // 블러 효과를 줄여서 그림자를 더 세밀하게
              offset: Offset(4, -1), // 좌우 그림자의 길이를 줄임
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10,
              offset: Offset(-1, 0), // 좌우 그림자의 길이를 줄임
            ),
          ],
        ),
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              isVisible: true, // Keep the axis visible to show labels
              interval: 1, // Display a label for every data point
              labelIntersectAction: AxisLabelIntersectAction
                  .rotate45, // Rotate labels to prevent overlapping
              axisLine: AxisLine(width: 0), // Hide the axis line
              majorTickLines: MajorTickLines(size: 0), // Hide major tick lines
              majorGridLines: MajorGridLines(width: 0, color: Colors.grey),
              labelStyle: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            primaryYAxis: NumericAxis(
              isVisible: true, // Keep the axis visible to show labels
              axisLine:
                  AxisLine(width: 0), // Set width to 0 to hide the axis line
              majorTickLines: MajorTickLines(
                  size: 0), // Set size to 0 to hide major tick lines
              majorGridLines: MajorGridLines(
                width: 1,
                color: Theme.of(context).colorScheme.scrim,
              ),
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              minimum: 1,
              maximum: 4.5,
              interval: 1,
              numberFormat: NumberFormat("0.0"),
            ),
            series: <CartesianSeries>[
              LineSeries<GraphData, String>(
                name: 'Course 1',
                dataSource: chartData,
                xValueMapper: (GraphData data, _) => data.semester,
                yValueMapper: (GraphData data, _) => data.gpaCourse,
                color: Theme.of(context).colorScheme.outline,
                markerSettings: MarkerSettings(isVisible: true),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment
                      .bottom, // Align labels to the bottom of data points
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ]),
      );
    }
  }
}

class GraphData {
  final String semester;
  final double gpaCourse;

  GraphData(this.semester, this.gpaCourse);
}
