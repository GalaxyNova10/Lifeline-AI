import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

/// Hospital finder map with dark tiles, wait-time colored markers,
/// route polylines, and draggable hospital list bottom sheet.
class MapScreen extends StatefulWidget {
  final bool showBackButton;
  const MapScreen({super.key, this.showBackButton = false});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  int? _selectedHospitalIndex;

  // Demo user location
  final _userLocation = const LatLng(13.0827, 80.2707); // Chennai

  // Demo hospitals
  final _hospitals = const [
    _Hospital('Apollo Hospital', LatLng(13.0604, 80.2496), 12,
        'Cardiac', 4.5),
    _Hospital('MIOT International', LatLng(13.0120, 80.1780), 25,
        'Ortho', 4.3),
    _Hospital('Fortis Malar', LatLng(13.0067, 80.2567), 38,
        'Neuro', 4.1),
    _Hospital('Government General', LatLng(13.0780, 80.2766), 8,
        'General', 3.8),
    _Hospital('Kauvery Hospital', LatLng(13.0660, 80.2570), 18,
        'Cardiac', 4.4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.showBackButton
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkNavyGradient),
        child: Stack(
          children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 12.5,
              backgroundColor: AppColors.darkBg1,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),

              // Route polyline
              if (_selectedHospitalIndex != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        _userLocation,
                        _hospitals[_selectedHospitalIndex!].location,
                      ],
                      color: AppColors.neonCyan.withValues(alpha: 0.6),
                      strokeWidth: 3,
                    ),
                  ],
                ),

              // User marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),

              // Hospital markers
              MarkerLayer(
                markers: _hospitals.asMap().entries.map((entry) {
                  final i = entry.key;
                  final h = entry.value;
                  final isSelected = _selectedHospitalIndex == i;
                  final color = AppColors.waitColorFor(h.waitMinutes);

                  return Marker(
                    point: h.location,
                    width: 70,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedHospitalIndex = i),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.25)
                                  : AppColors.darkBg1.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: color.withValues(
                                    alpha: isSelected ? 0.8 : 0.5),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              '${h.waitMinutes}m',
                              style: GoogleFonts.firaCode(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          Icon(Icons.location_on,
                              color: color, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Search bar
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg1.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white38, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.inter(
                                fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search hospitals...',
                              hintStyle: GoogleFonts.inter(
                                  fontSize: 14, color: Colors.white30),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
            ),
            ).animate().fadeIn().slideY(begin: -0.2),
          ),

          // Hospital detail card
          if (_selectedHospitalIndex != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _buildHospitalCard(_hospitals[_selectedHospitalIndex!]),
            ),

          // Hospital list indicators
          if (_selectedHospitalIndex == null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _buildHospitalList(),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildHospitalCard(_Hospital hospital) {
    final color = AppColors.waitColorFor(hospital.waitMinutes);

    return GlassCard.elevated(
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_hospital, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${hospital.waitMinutes} min wait',
                            style: GoogleFonts.firaCode(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hospital.specialization,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Close button
              GestureDetector(
                onTap: () => setState(() => _selectedHospitalIndex = null),
                child: const Icon(Icons.close, color: Colors.white30, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _InfoChip(Icons.star, '${hospital.rating}', Colors.amber),
              const SizedBox(width: 10),
              _InfoChip(Icons.directions, '3.2 km', Colors.white54),
              const SizedBox(width: 10),
              _InfoChip(Icons.access_time, 'ETA: 8 min', AppColors.neonCyan),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: 'Navigate',
              icon: Icons.navigation,
              height: 46,
              onPressed: () {},
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.15);
  }

  Widget _buildHospitalList() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _hospitals.length,
        itemBuilder: (context, i) {
          final h = _hospitals[i];
          final color = AppColors.waitColorFor(h.waitMinutes);

          return GestureDetector(
            onTap: () => setState(() => _selectedHospitalIndex = i),
            child: Container(
              width: 160,
              margin: EdgeInsets.only(right: i < _hospitals.length - 1 ? 10 : 0),
              child: ClipRRect(
                borderRadius: AppSpacing.borderRadiusSm,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg1.withValues(alpha: 0.85),
                      borderRadius: AppSpacing.borderRadiusSm,
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          h.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${h.waitMinutes} min',
                              style: GoogleFonts.firaCode(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              h.specialization,
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: Colors.white38),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

class _Hospital {
  final String name;
  final LatLng location;
  final int waitMinutes;
  final String specialization;
  final double rating;

  const _Hospital(this.name, this.location, this.waitMinutes,
      this.specialization, this.rating);
}
