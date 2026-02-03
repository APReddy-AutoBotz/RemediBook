import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../domain/models/artifact_model.dart';
import '../../data/repositories/artifact_repository.dart';
import '../../../dashboard/presentation/widgets/heal_streak_ring.dart';

/// Artifact Dashboard - Museum Display (Pillar 3)
class ArtifactDashboard extends StatefulWidget {
  const ArtifactDashboard({super.key});

  @override
  State<ArtifactDashboard> createState() => _ArtifactDashboardState();
}

class _ArtifactDashboardState extends State<ArtifactDashboard> {
  final ArtifactRepository _repository = ArtifactRepository();
  late Future<ArtifactMetrics> _metricsFuture;
  late Future<List<WellnessArtifact>> _artifactsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _repository.getMetrics();
    _artifactsFuture = _repository.getAllArtifacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediTheme.warmLimestone,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceMD, vertical: RemediTheme.spaceLG),
            sliver: SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
          ),

          // Metrics Cards
          SliverToBoxAdapter(
            child: FutureBuilder<ArtifactMetrics>(
              future: _metricsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 200);
                }
                return _buildMetricsSection(snapshot.data!);
              },
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceMD, vertical: RemediTheme.spaceMD),
              child: Text(
                'Wellness Impact'.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: RemediTheme.charcoal.withOpacity(0.5),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // Artifact Gallery (Staggered Grid)
          FutureBuilder<List<WellnessArtifact>>(
            future: _artifactsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final artifacts = snapshot.data!;
              if (artifacts.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RemediTheme.spaceMD,
                ),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: RemediTheme.spaceMD,
                  crossAxisSpacing: RemediTheme.spaceMD,
                  childCount: artifacts.length,
                  itemBuilder: (context, index) {
                    return _buildArtifactCard(artifacts[index]);
                  },
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: RemediTheme.spaceXL),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(ArtifactMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heal Streak Ring integrated into Museum Display
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 40),
              child: CustomPaint(
                size: const Size(180, 180), // Matched Home screen size
                painter: HealStreakPainter(
                  progress: 0.75,
                  pulse: 1.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '12',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
                      ),
                      const Text(
                        'DAY STREAK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 9,
                          color: RemediTheme.deepTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          
          // Metrics Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Protocols',
                  metrics.protocolsCompleted.toString(),
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: RemediTheme.spaceSM),
              Expanded(
                child: _buildMetricCard(
                  'Saved',
                  metrics.guidesSaved.toString(),
                  Icons.bookmark_outline,
                ),
              ),
              const SizedBox(width: RemediTheme.spaceSM),
              Expanded(
                child: _buildMetricCard(
                  'Evidence',
                  metrics.evidenceSourcesReviewed.toString(),
                  Icons.library_books,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wellness Pulse',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Your healing journey continues',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: RemediTheme.darkForest.withOpacity(0.4),
              ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(RemediTheme.spaceMD),
      decoration: RemediDecorations.stone(
        borderRadius: RemediTheme.radiusStone,
        shadowOpacity: 0.03,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: RemediTheme.deepTeal.withOpacity(0.6),
          ),
          const SizedBox(height: RemediTheme.spaceXS),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: RemediTheme.deepTeal,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: RemediTheme.charcoal.withOpacity(0.6),
                  fontSize: 10,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactCard(WellnessArtifact artifact) {
    return Container(
      decoration: RemediDecorations.stoneBordered(
        borderRadius: RemediTheme.radiusStone,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 140,
              color: RemediTheme.mutedSage.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 48,
                  color: RemediTheme.deepTeal.withOpacity(0.3),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(RemediTheme.spaceSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guide ID
                  Text(
                    artifact.guideId,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: RemediTheme.deepTeal,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    artifact.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: RemediTheme.spaceXS),

                  // Date
                  Text(
                    'Generated ${_formatDate(artifact.generatedDate)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: RemediTheme.charcoal.withOpacity(0.5),
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: RemediTheme.spaceXS),

                  // Evidence Count
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: RemediTheme.mutedSage,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${artifact.evidenceCount} sources',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: RemediTheme.charcoal.withOpacity(0.6),
                                  fontSize: 10,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(RemediTheme.spaceXL),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RemediTheme.warmLimestone,
              shape: BoxShape.circle,
              border: Border.all(color: RemediTheme.deepTeal.withOpacity(0.1), width: 2),
              boxShadow: [
                BoxShadow(
                  color: RemediTheme.deepTeal.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_stories,
              size: 64,
              color: RemediTheme.deepTeal.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: RemediTheme.spaceLG),
          
          Text(
            'No Artifacts Yet',
            style: GoogleFonts.lora( // More premium font
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: RemediTheme.darkForest,
            ),
          ),
          const SizedBox(height: RemediTheme.spaceSM),
          
          Text(
            'Generate your first wellness guide to start your collection. Your personalized guides will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: RemediTheme.charcoal.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Call to Action
          ElevatedButton.icon(
            onPressed: () {
               // Navigation to Discovery
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiscoveryScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RemediTheme.deepTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 4,
              shadowColor: RemediTheme.deepTeal.withOpacity(0.3),
            ),
            icon: const Icon(Icons.search, size: 20),
            label: Text(
              "Start Discovery",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
