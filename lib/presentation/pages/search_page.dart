import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../bloc/profiles/profiles_bloc.dart';
import '../bloc/profiles/profiles_state.dart';
import '../widgets/molecules/vendor_card.dart';
import '../../core/di/injection.dart';
import '../../domain/repositories/profile_repository.dart';

/// Search and discovery page for creative professionals.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfilesBloc(sl<ProfileRepository>())
            ..add(ProfilesLoadRequested()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<ProfilesBloc>().add(
              ProfilesSearchQueryChanged(_searchController.text),
            );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by username or name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProfilesBloc, ProfilesState>(
        builder: (context, state) {
          if (state.status == ProfilesStatus.loading &&
              state.profiles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProfilesStatus.error && state.profiles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.error ?? 'Something went wrong',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<ProfilesBloc>().add(
                            ProfilesLoadRequested(),
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final list = state.filteredProfiles;
          if (list.isEmpty) {
            return Center(
              child: Text(
                state.searchQuery.trim().isEmpty
                    ? 'No creatives found'
                    : 'No matches for "${state.searchQuery.trim()}"',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final profile = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VendorCard(
                  profile: profile,
                  onTap: () => context.push(
                    AppRoutes.creativeProfileView(profile.userId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
