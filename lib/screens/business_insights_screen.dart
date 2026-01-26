import 'package:flutter/material.dart';
import '../theme.dart';

class BusinessInsightsScreen extends StatelessWidget {
  const BusinessInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit Economics', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            _buildMetricTile('Estimated Affiliate Revenue', '₹4,250', '5% conversion from fulfillment partners'),
            _buildMetricTile('Projected User LTV', '₹15,000 / year', 'Based on 12 minor ailments per year'),
            _buildMetricTile('CAC (Customer Acquisition Cost)', '₹120', 'Viral loops & organic SEO'),
            
            const SizedBox(height: 48),
            Text('Market Trends', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              child: Center(
                child: Text(
                  'Chart: Pollution-related Cough Trends\n(+25% this week)', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.darkForest.withOpacity(0.6), fontFamily: 'Serif'),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            Text('Future Roadmap', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _buildRoadmapItem('Expansion to 500+ Ailments'),
            _buildRoadmapItem('B2B Wellness Integration for Corporations'),
            _buildRoadmapItem('Predictive AI for Seasonal Outbreaks'),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: AppTheme.mutedSage),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontFamily: 'Sans-Serif', fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkForest, fontSize: 13)),
                const SizedBox(height: 4),
                Text(sub, style: TextStyle(fontSize: 11, color: AppTheme.charcoalBody.withOpacity(0.5))),
              ],
            ),
          ),
          Text(value, style: const TextStyle(color: AppTheme.deepTeal, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Serif')),
        ],
      ),
    );
  }
}
