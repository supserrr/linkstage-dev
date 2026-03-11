import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/auth_redirect.dart';
import '../../../domain/usecases/user/change_username_usecase.dart';
import '../../bloc/change_username/change_username_cubit.dart';
import '../../bloc/change_username/change_username_state.dart';

/// Page to change username (rate-limited to once per 30 days).
class ChangeUsernamePage extends StatelessWidget {
  const ChangeUsernamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Change username')),
        body: const Center(child: Text('Please sign in to change your username')),
      );
    }
    return BlocProvider(
      create: (_) => ChangeUsernameCubit(
        sl<ChangeUsernameUseCase>(),
        user,
      ),
      child: const _ChangeUsernameView(),
    );
  }
}

class _ChangeUsernameView extends StatefulWidget {
  const _ChangeUsernameView();

  @override
  State<_ChangeUsernameView> createState() => _ChangeUsernameViewState();
}

class _ChangeUsernameViewState extends State<_ChangeUsernameView> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ChangeUsernameCubit>();
    final current = cubit.state.currentUsername;
    if (current != null && current.isNotEmpty) {
      _controller.text = current.replaceFirst('@', '');
    }
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final value = _controller.text.trim();
      if (value.isNotEmpty) {
        context.read<ChangeUsernameCubit>().checkAvailability(value);
      } else {
        context.read<ChangeUsernameCubit>().clearValidation();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change username')),
      body: BlocConsumer<ChangeUsernameCubit, ChangeUsernameState>(
        listener: (context, state) {
          if (state.status == ChangeUsernameStatus.success) {
            if (context.mounted) {
              sl<AuthRedirectNotifier>().refresh();
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Username updated')),
              );
            }
          }
          if (state.status == ChangeUsernameStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final canChange = state.canChangeUsername;
          String? cooldownMessage;
          if (state.nextChangeDate != null) {
            cooldownMessage =
                'You can change your username again on ${state.nextChangeDate}';
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cooldownMessage != null) ...[
                  Text(
                    cooldownMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixText: '@',
                    hintText: 'username',
                    errorText: state.validationError,
                    suffixIcon: state.isCheckingAvailability
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.done,
                  enabled: canChange && !state.isSubmitting,
                  onSubmitted: (_) => _submit(context),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: canChange &&
                          !state.isSubmitting &&
                          state.isAvailable == true &&
                          _controller.text.trim().length >= 3
                      ? () => _submit(context)
                      : null,
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<ChangeUsernameCubit>().submit(_controller.text.trim());
  }
}
