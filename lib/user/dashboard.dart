import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CalorieSliderScreen extends StatefulWidget {
  const CalorieSliderScreen({super.key});

  @override
  _CalorieSliderScreenState createState() => _CalorieSliderScreenState();
}

class _CalorieSliderScreenState extends State<CalorieSliderScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  double bmiValue = 44.0; // Example BMI value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calorie Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  _caloriePage(),
                  _weekReviewPage(),
                  _weightProgressPage(),
                  _sleepTrackerPage(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _bmiSection(),
          ],
        ),
      ),
    );
  }

  Widget _caloriePage() {
    return _dashboardCard(
      title: "Calorie Intake",
      subtitle: "Track your daily calorie consumption.",
      buttonText: "View Details",
    );
  }

  Widget _weekReviewPage() {
    return _dashboardCard(
      title: "Week Review",
      subtitle: "Analyze your weekly health trends.",
      buttonText: "Check Insights",
    );
  }

  Widget _weightProgressPage() {
    return _chartCard("Weight Progress", Colors.blue);
  }

  Widget _sleepTrackerPage() {
    return _chartCard("Sleep Hours", Colors.purple);
  }

  Widget _bmiSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("BMI Indicator", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: BMIIndicator(bmi: bmiValue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(height: 300, child: _buildChart(title, color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(String title, Color color) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 2), FlSpot(1, 2.5), FlSpot(2, 3), FlSpot(3, 3.5),
              FlSpot(4, 4), FlSpot(5, 3.8), FlSpot(6, 4.2)
            ],
            isCurved: true,
            color: color,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({required String title, required String subtitle, required String buttonText}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class BMIIndicator extends StatelessWidget {
  final double bmi;

  const BMIIndicator({Key? key, required this.bmi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 10,
            maximum: 40,
            ranges: <GaugeRange>[
              GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue),
              GaugeRange(startValue: 18.5, endValue: 24.9, color: Colors.green),
              GaugeRange(startValue: 25, endValue: 29.9, color: Colors.yellow),
              GaugeRange(startValue: 30, endValue: 40, color: Colors.red),
            ],
            pointers: <GaugePointer>[NeedlePointer(value: bmi)],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(positionFactor: 0.5, widget: Text(bmi.toStringAsFixed(1), style: TextStyle(color: Colors.white, fontSize: 18))),
            ],
          ),
        ],
      ),
    );
  }
}