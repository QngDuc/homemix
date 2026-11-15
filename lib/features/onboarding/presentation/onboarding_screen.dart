import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _background = Color(0xFFFFF8E8);
const _navy = Color(0xFF202A44);
const _coral = Color(0xFFF47F91);
const _muted = Color(0xFF727582);

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;

                return Padding(
                  padding: EdgeInsets.fromLTRB(24, compact ? 8 : 12, 24, 8),
                  child: Column(
                    children: [
                      const _WelcomeHeader(),
                      SizedBox(height: compact ? 8 : 12),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 345,
                              maxHeight: 350,
                            ),
                            child: AspectRatio(
                              aspectRatio: 345 / 350,
                              child: Image.asset(
                                'assets/images/onboarding_cocktail.png',
                                fit: BoxFit.contain,
                                semanticLabel: 'Ly cocktail cam va bac ha',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const _ProgressDots(),
                      SizedBox(height: compact ? 16 : 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.go('/discover'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bắt đầu',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nhà bạn. Nguyên liệu của bạn. Niềm vui của bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'home',
                    style: TextStyle(color: _navy),
                  ),
                  TextSpan(
                    text: 'mix',
                    style: TextStyle(color: _coral),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'PHA MỘT CHÚT. VUI THÊM NHIỀU.',
          style: TextStyle(
            color: Color(0xFFA94A60),
            fontSize: 11,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Tự tay pha',
          style: TextStyle(
            color: _navy,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Đồ uống',
          style: TextStyle(
            color: _coral,
            fontFamily: 'WindSong',
            fontSize: 40,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Khám phá công thức dễ làm và tự tay\n'
          'pha đồ uống ngon ngay tại nhà.',
          style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ProgressDot(width: 24, color: _coral),
        SizedBox(width: 6),
        _ProgressDot(width: 8, color: Color(0xFFE8DAD0)),
        SizedBox(width: 6),
        _ProgressDot(width: 8, color: Color(0xFFE8DAD0)),
      ],
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
