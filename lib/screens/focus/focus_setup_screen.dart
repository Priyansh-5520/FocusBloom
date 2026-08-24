import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/focus_timer_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/plant_data.dart';
import '../../widgets/plant/plant_widget.dart';
import 'focus_active_screen.dart';

class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  int _selectedDuration = 25;
  String _selectedCategory = 'Study';
  String _selectedPlantId = 'oak';
  bool _customDuration = false;
  final _customController = TextEditingController(text: '30');

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _startSession() {
    final minutes = _customDuration
        ? int.tryParse(_customController.text) ?? 25
        : _selectedDuration;

    if (minutes < 1 || minutes > 480) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a duration between 1 and 480 minutes')),
      );
      return;
    }

    final timerProvider = context.read<FocusTimerProvider>();
    timerProvider.setup(
      plannedMinutes: minutes,
      category: _selectedCategory,
      plantTypeId: _selectedPlantId,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FocusActiveScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availablePlants = PlantData.allPlants;

    final selectedPlant = PlantData.getById(_selectedPlantId) ?? PlantData.allPlants.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Focus Session')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Tree preview
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      PlantWidget(
                        plantType: selectedPlant,
                        progress: 0.0,
                        size: 120,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedPlant.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedPlant.rarityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedPlant.rarityColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          selectedPlant.rarityLabel,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selectedPlant.rarityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Duration selection
              Text('Duration', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...AppConstants.kFocusDurations.map((d) {
                    final isSelected = !_customDuration && _selectedDuration == d;
                    return ChoiceChip(
                      label: Text(_formatDuration(d)),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        _selectedDuration = d;
                        _customDuration = false;
                      }),
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.surfaceVariant,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                      ),
                      labelStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                      ),
                    );
                  }),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _customDuration,
                    onSelected: (_) => setState(() => _customDuration = true),
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide(
                      color: _customDuration ? AppColors.primary : AppColors.surfaceBorder,
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: _customDuration ? FontWeight.w700 : FontWeight.w500,
                      color: _customDuration ? AppColors.primaryLight : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              if (_customDuration) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _customController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          suffixText: 'min',
                          suffixStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Category selection
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.kFocusCategories.map((c) {
                  final isSelected = _selectedCategory == c;
                  final catColor = AppColors.categoryColors[c] ?? AppColors.primary;
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = c),
                    selectedColor: catColor.withOpacity(0.25),
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide(
                      color: isSelected ? catColor : AppColors.surfaceBorder,
                      width: isSelected ? 2 : 1,
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Tree selection
              Text('Choose Tree Species', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 105,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: availablePlants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final plant = availablePlants[index];
                    final isSelected = _selectedPlantId == plant.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPlantId = plant.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 88,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.surfaceElevated
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(plant.emoji, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 4),
                            Text(
                              plant.name.split(' ').first,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Start button
              ElevatedButton.icon(
                onPressed: _startSession,
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(
                  'Grow ${_customDuration ? (_customController.text.isNotEmpty ? "${_customController.text} min" : "Custom") : _formatDuration(_selectedDuration)} Tree',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }
}
