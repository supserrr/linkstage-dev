import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  bool _checking = false;
  String? _availabilityError;

  @override
  void initState() {
    super.initState();
    final username = context.read<ProfileSetupCubit>().state.username;
    if (username != null && username.isNotEmpty) {
      _controller.text = username;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final value = _controller.text.trim();
    if (value.length < 3) return;
    setState(() {
      _checking = true;
      _availabilityError = null;
    });
    final available = await context
        .read<ProfileSetupCubit>()
        .checkUsernameAvailable(value);
    if (mounted) {
      setState(() {
        _checking = false;
        _availabilityError = available ? null : 'Username is taken';
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_availabilityError != null) return;
    final value = _controller.text.trim();
    if (value.length < 3) return;
    context.read<ProfileSetupCubit>().setUsername(value);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose your username',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This will be your unique handle. 3-20 characters, letters, numbers, underscore.',
              style: Theme.of(context).textTheme.bodyMedium,
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
              onChanged: (_) {
                setState(() => _availabilityError = null);
              },
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
                return _availabilityError;
              },
            ),
            if (_checking)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 20,
                  child: LinearProgressIndicator(),
                ),
              )
            else if (_availabilityError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _availabilityError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _checking ? null : _checkAvailability,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Check availability'),
            ),
            const Spacer(),
            AppButton(
              label: 'Next',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
