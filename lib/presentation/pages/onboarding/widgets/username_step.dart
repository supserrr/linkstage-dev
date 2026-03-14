import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../bloc/onboarding/profile_setup_cubit.dart';
import '../../../widgets/atoms/app_button.dart';

class UsernameStep extends StatefulWidget {
  const UsernameStep({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  @override
  State<UsernameStep> createState() => _UsernameStepState();
}

class _UsernameStepState extends State<UsernameStep> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _keyboardWasVisible = false;
  bool _checking = false;
  bool? _isAvailable; // null = not checked, true = available, false = taken

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final username = context.read<ProfileSetupCubit>().state.username;
    if (username != null && username.isNotEmpty) {
      _controller.text = username;
    }
  }

  void _onScroll() => setState(() {});

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final value = _controller.text.trim();
    if (value.length < 3) return;
    setState(() {
      _checking = true;
      _isAvailable = null;
    });
    final available = await context
        .read<ProfileSetupCubit>()
        .checkUsernameAvailable(value);
    if (mounted) {
      setState(() {
        _checking = false;
        _isAvailable = available;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isAvailable != true) return;
    final value = _controller.text.trim();
    if (value.length < 3) return;
    context.read<ProfileSetupCubit>().setUsername(value);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
    final illustrationFullHeight = (screenHeight * 0.40).clamp(160.0, 300.0);
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final illustrationHeight =
        (illustrationFullHeight - scrollOffset).clamp(0.0, illustrationFullHeight);

    return Form(
      key: _formKey,
      child: Stack(
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
                              'Choose your username',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3-20 characters. Letters, numbers, underscore only.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixText: '@ ',
                          hintText: 'johndoe',
                        ),
                        autofocus: true,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        onChanged: (_) => setState(() => _isAvailable = null),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Username is required';
                          }
                          if (v.trim().length < 3) {
                            return 'At least 3 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                            return 'Letters, numbers, underscore only';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _checking ||
                                  _controller.text.trim().length < 3
                              ? null
                              : _checkAvailability,
                          icon: _checking
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : Icon(Icons.search,
                                  size: 20,
                                  color: theme.colorScheme.primary),
                          label: Text(_checking
                              ? 'Checking...'
                              : 'Check availability'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (!_checking && _isAvailable != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              _isAvailable!
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 20,
                              color: _isAvailable!
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isAvailable!
                                  ? 'Username is available'
                                  : 'Username is taken',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _isAvailable!
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Next',
                        onPressed: _isAvailable == true ? _submit : null,
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
                        ? 'assets/images/username_page_illustration_dark.svg'
                        : 'assets/images/username_page_illustration_light.svg';
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
      ),
    );
  }
}
