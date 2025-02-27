import 'package:flutter/material.dart';
import '../models/study_session.dart';
import 'package:confetti/confetti.dart';

class SessionSummaryWidget extends StatefulWidget {
  final StudySession session;

  const SessionSummaryWidget({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<SessionSummaryWidget> createState() => _SessionSummaryWidgetState();
}

class _SessionSummaryWidgetState extends State<SessionSummaryWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.session.accuracy >= 80) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Resumo da Sessão',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatCard(
                icon: Icons.check_circle,
                title: 'Taxa de Acerto',
                value: '${widget.session.accuracy.toStringAsFixed(1)}%',
                color: _getAccuracyColor(widget.session.accuracy),
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                icon: Icons.flash_on,
                title: 'Pontos Ganhos',
                value: '${widget.session.earnedPoints} XP',
                color: Colors.amber,
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                icon: Icons.library_books,
                title: 'Cards Revisados',
                value: '${widget.session.cardsReviewed}',
                color: Colors.blue,
              ),
              if (widget.session.achievementsUnlocked.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Conquistas Desbloqueadas!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.session.achievementsUnlocked.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildAchievementBadge(
                          widget.session.achievementsUnlocked[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String achievementId) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.star,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          achievementId,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}
