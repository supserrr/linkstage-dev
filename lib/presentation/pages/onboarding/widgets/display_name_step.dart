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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
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

    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      buildWhen: (a, b) => a.isLoading != b.isLoading,
      builder: (context, state) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final asset = isDark
                            ? 'assets/images/display_name_page_illustration_dark.svg'
                            : 'assets/images/display_name_page_illustration_light.svg';
                        return SvgPicture.asset(
                          asset,
                          width: constraints.maxWidth,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
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
                      onPressed: (hasName && !state.isLoading) ? _submit : null,
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
        );
      },
    );
  }
}
