import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfileState = ref.watch(userProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return userProfileState.when(
            data: (profile) => _buildDashboardContent(context, user, profile),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(userProfileNotifierProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    models.User user,
    UserProfile? profile,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome, ${user.name}!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Profile:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (profile != null) ...[
            _buildProfileInfo(profile),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/profile/edit'), // Add this route
              child: const Text('Edit Profile'),
            ),
          ] else ...[
            const Text(
              'You haven\'t set up your profile yet.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.push('/profile/create'), // Add this route
              child: const Text('Create Profile'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${profile.nama}'),
            const SizedBox(height: 8),
            Text('Email: ${profile.email}'),
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: profile.foto != ''
                    ? Image.network(
                        profile.foto,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
