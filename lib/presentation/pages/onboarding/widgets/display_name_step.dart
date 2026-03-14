import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../bloc/onboarding/profile_setup_state.dart';
import '../../../widgets/atoms/app_button.dart';
import '../../../widgets/atoms/app_text_field.dart';

class DisplayNameStep extends StatefulWidget {
  const DisplayNameStep({
    super.key,
    required this.initialValue,
    required this.onNext,
  });

  final String initialValue;
  final VoidCallback onNext;

  @override
  State<DisplayNameStep> createState() => _DisplayNameStepState();
}

class _DisplayNameStepState extends State<DisplayNameStep> {
  late final TextEditingController _controller;
  final _scrollController = ScrollController();
  bool _keyboardWasVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() => setState(() {});

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<ProfileSetupCubit>().setDisplayName(_controller.text.trim());
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasName = _controller.text.trim().isNotEmpty;

    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (_keyboardWasVisible && !keyboardVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _keyboardWasVisible = keyboardVisible;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final illustrationFullHeight = (screenHeight * 0.44).clamp(200.0, 340.0);
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final illustrationHeight =
        (illustrationFullHeight - scrollOffset).clamp(0.0, illustrationFullHeight);

    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      buildWhen: (a, b) => a.isLoading != b.isLoading,
      builder: (context, state) {
        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: illustrationFullHeight),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "What's your name?",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'It will be shown on your profile and in messages.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _controller,
                          label: 'Display name',
                          onChanged: (v) {
                            context.read<ProfileSetupCubit>().setDisplayName(v);
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Next',
                          onPressed:
                              (hasName && !state.isLoading) ? _submit : null,
                          isLoading: state.isLoading,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: state.isLoading ? null : widget.onNext,
                          child: const Text('Skip for now'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (illustrationHeight > 0)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                height: illustrationHeight,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final asset = isDark
                          ? 'assets/images/display_name_page_illustration_dark.svg'
                          : 'assets/images/display_name_page_illustration_light.svg';
                      return SizedBox(
                        height: illustrationHeight,
                        width: constraints.maxWidth,
                        child: SvgPicture.asset(
                          asset,
                          width: constraints.maxWidth,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
