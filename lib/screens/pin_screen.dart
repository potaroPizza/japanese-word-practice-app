import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../data/study_repository.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  // sha256.convert(utf8.encode('0119')).toString()
  static const String _correctPinHash =
      'dd6570d45cfc25d7e0bec8b4ef11da488d983d0a5fa7b30f805ec01f05e8aeb6';

  final StudyRepository _studyRepo = StudyRepository();
  String _enteredPin = '';
  bool _isLocked = false;
  DateTime? _lockUntil;
  String _errorMessage = '';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  Future<void> _checkLockStatus() async {
    final locked = await _studyRepo.isLocked();
    final lockUntil = await _studyRepo.getLockUntil();
    setState(() {
      _isLocked = locked;
      _lockUntil = lockUntil;
    });
  }

  String _formatRemaining(DateTime lockUntil) {
    final remaining = lockUntil.difference(DateTime.now());
    if (remaining.isNegative) return '';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return '$hours시간 $minutes분 남음';
  }

  Future<void> _onNumberPressed(String number) async {
    if (_isLocked || _isChecking || _enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += number;
      _errorMessage = '';
    });

    if (_enteredPin.length == 4) {
      _isChecking = true;
      final inputHash = sha256.convert(utf8.encode(_enteredPin)).toString();

      if (inputHash == _correctPinHash) {
        await _studyRepo.resetFailCount();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        await _studyRepo.incrementFailCount();
        await _checkLockStatus();
        if (!mounted) return;
        setState(() {
          _enteredPin = '';
          _isChecking = false;
          _errorMessage = _isLocked ? '5회 실패. 24시간 잠금됨' : 'PIN이 올바르지 않습니다';
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isEmpty || _isLocked || _isChecking) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: Color(0xFF3F51B5),
                ),
                const SizedBox(height: 16),
                Text(
                  '일본어 단어 연습',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PIN을 입력하세요',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // PIN 표시 (4칸 원형)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < _enteredPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? const Color(0xFF3F51B5)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFF3F51B5),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // 에러 메시지 또는 잠금 시간
                if (_isLocked && _lockUntil != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '잠금 상태',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRemaining(_lockUntil!),
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 14,
                    ),
                  ),

                const SizedBox(height: 32),

                // 숫자 키패드
                _buildKeypad(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final isDisabled = _isLocked || _isChecking;

    return SizedBox(
      width: 280,
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', 'del'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) {
                  if (key.isEmpty) {
                    return const SizedBox(width: 72, height: 72);
                  }
                  if (key == 'del') {
                    return _buildKeyButton(
                      onTap: isDisabled ? null : _onDeletePressed,
                      child: Icon(
                        Icons.backspace_outlined,
                        color: isDisabled
                            ? Colors.grey.shade400
                            : Colors.indigo.shade600,
                        size: 24,
                      ),
                    );
                  }
                  return _buildKeyButton(
                    onTap: isDisabled ? null : () => _onNumberPressed(key),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: isDisabled
                            ? Colors.grey.shade400
                            : Colors.indigo.shade800,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyButton({
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(child: child),
        ),
      ),
    );
  }
}
