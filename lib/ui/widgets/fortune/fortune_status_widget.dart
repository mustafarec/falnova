import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../backend/repositories/fortune/fortune_repository.dart';

class FortuneStatusWidget extends ConsumerStatefulWidget {
  final String fortuneId;
  final VoidCallback onCompleted;

  const FortuneStatusWidget({
    super.key,
    required this.fortuneId,
    required this.onCompleted,
  });

  @override
  ConsumerState<FortuneStatusWidget> createState() =>
      _FortuneStatusWidgetState();
}

class _FortuneStatusWidgetState extends ConsumerState<FortuneStatusWidget> {
  Timer? _timer;
  String _status = 'pending';
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _elapsedSeconds++;
      });

      final repository = ref.read(fortuneRepositoryProvider.notifier);
      final status = await repository.checkFortuneStatus(widget.fortuneId);

      setState(() {
        _status = status;
      });

      if (status == 'completed') {
        _timer?.cancel();
        widget.onCompleted();
      }
    });
  }

  String get _timeText {
    final minutes = (_elapsedSeconds / 60).floor();
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.discreteCircle(
            color: Colors.deepPurple,
            size: 40,
            secondRingColor: Colors.purple,
            thirdRingColor: Colors.purple.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _status == 'pending'
                ? 'Falınız hazırlanıyor... $_timeText'
                : 'Falınız yorumlanıyor... $_timeText',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Kahve falınız deneyimli falcılarımız tarafından yorumlanıyor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
