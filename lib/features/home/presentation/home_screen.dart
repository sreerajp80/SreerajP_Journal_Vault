import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';

/// The main home screen showing the list of journals.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final journalsAsync = ref.watch(homeJournalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journals')),
      body: journalsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading journals...'),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load journals'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(homeJournalsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(title: Text(item.journal.title));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New journal',
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
