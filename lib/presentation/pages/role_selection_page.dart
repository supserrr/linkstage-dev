import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../bloc/role_selection/role_selection_cubit.dart';
import '../bloc/role_selection/role_selection_state.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/user/upsert_user_usecase.dart';
import '../widgets/atoms/app_button.dart';

/// Role selection after registration (Event Planner vs Creative Professional).
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoleSelectionCubit(sl<UpsertUserUseCase>()),
      child: BlocConsumer<RoleSelectionCubit, RoleSelectionState>(
        listener: (context, state) {
          if (state.status == RoleSelectionStatus.success && state.user != null) {
            context.go(AppRoutes.profileSetup, extra: state.user);
          }
          if (state.status == RoleSelectionStatus.error &&
              state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return _RoleSelectionView(user: user);
        },
      ),
    );
  }
}

class _RoleSelectionView extends StatefulWidget {
  const _RoleSelectionView({required this.user});

  final UserEntity user;

  @override
  State<_RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<_RoleSelectionView> {
  UserRole? _selectedRole;
  final _scrollController = ScrollController();
  bool _keyboardWasVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() => setState(() {});

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoleSelectionCubit>().state;
    final user = widget.user;

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
    final illustrationFullHeight = (screenHeight * 0.52).clamp(200.0, 400.0);
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final illustrationHeight =
        (illustrationFullHeight - scrollOffset).clamp(0.0, illustrationFullHeight);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: illustrationFullHeight),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Choose your role below',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              _RoleCard(
                                title: 'Event Planner',
                                isSelected:
                                    _selectedRole == UserRole.eventPlanner,
                                onTap: () => setState(
                                    () => _selectedRole = UserRole.eventPlanner),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'or',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _RoleCard(
                                title: 'Creative Professional',
                                isSelected: _selectedRole ==
                                    UserRole.creativeProfessional,
                                onTap: () => setState(
                                  () => _selectedRole =
                                      UserRole.creativeProfessional,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (illustrationHeight > 0)
                    Positioned(
                      top: 24,
                      left: 0,
                      right: 0,
                      height: illustrationHeight,
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isDark = Theme.of(context).brightness ==
                                Brightness.dark;
                            final asset = isDark
                                ? 'assets/images/role_page_illustration_dark.svg'
                                : 'assets/images/role_page_illustration_light.svg';
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: AppButton(
                label: 'Get started',
                onPressed: _selectedRole == null ||
                        state.status == RoleSelectionStatus.loading
                    ? null
                    : () => context
                        .read<RoleSelectionCubit>()
                        .selectRole(user, _selectedRole!),
                isLoading: state.status == RoleSelectionStatus.loading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  static const _highlightColor = Color(0xFFFE5924);

  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isSelected ? _highlightColor : colorScheme.surfaceContainerHighest;
    final foregroundColor =
        isSelected ? Colors.white : colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _highlightColor : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
