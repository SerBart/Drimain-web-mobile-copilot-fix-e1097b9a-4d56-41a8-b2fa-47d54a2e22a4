import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_state_notifier.dart';
import '../../data/zgloszenie_provider.dart';
import '../../data/models/zgloszenie_model.dart';

class ZgloszeniaScreen extends StatefulWidget {
  const ZgloszeniaScreen({super.key});

  @override
  State<ZgloszeniaScreen> createState() => _ZgloszeniaScreenState();
}

class _ZgloszeniaScreenState extends State<ZgloszeniaScreen> {
  late ZgloszenieProvider _zgloszenieProvider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _zgloszenieProvider = ZgloszenieProvider();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _zgloszenieProvider.loadZgloszenia();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _zgloszenieProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zgłoszenia'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showCreateDialog(context);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and filters
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Szukaj zgłoszeń...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _zgloszenieProvider.setSearchQuery(null);
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _zgloszenieProvider.setSearchQuery(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  // Filter buttons
                  Row(
                    children: [
                      Consumer<ZgloszenieProvider>(
                        builder: (context, provider, child) {
                          return FilterChip(
                            label: const Text('Wszystkie'),
                            selected: provider.statusFilter == null,
                            onSelected: (selected) {
                              if (selected) provider.setStatusFilter(null);
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Consumer<ZgloszenieProvider>(
                        builder: (context, provider, child) {
                          return FilterChip(
                            label: const Text('Otwarte'),
                            selected: provider.statusFilter == 'OTWARTE',
                            onSelected: (selected) {
                              provider.setStatusFilter(selected ? 'OTWARTE' : null);
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Consumer<ZgloszenieProvider>(
                        builder: (context, provider, child) {
                          return FilterChip(
                            label: const Text('Zamknięte'),
                            selected: provider.statusFilter == 'ZAMKNIETE',
                            onSelected: (selected) {
                              provider.setStatusFilter(selected ? 'ZAMKNIETE' : null);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // List of zgloszenia
            Expanded(
              child: Consumer<ZgloszenieProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              provider.loadZgloszenia();
                            },
                            child: const Text('Spróbuj ponownie'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.zgloszenia.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Brak zgłoszeń',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: provider.loadZgloszenia,
                    child: ListView.builder(
                      itemCount: provider.zgloszenia.length,
                      itemBuilder: (context, index) {
                        final zgloszenie = provider.zgloszenia[index];
                        return _buildZgloszenieCard(context, zgloszenie);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZgloszenieCard(BuildContext context, ZgloszenieModel zgloszenie) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          zgloszenie.tytul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(zgloszenie.opis),
            const SizedBox(height: 4),
            Row(
              children: [
                if (zgloszenie.status != null) ...[
                  Chip(
                    label: Text(
                      zgloszenie.status!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                ],
                if (zgloszenie.typ != null)
                  Text(
                    'Typ: ${zgloszenie.typ}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDialog(context, zgloszenie);
                break;
              case 'delete':
                _showDeleteDialog(context, zgloszenie);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edytuj'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Usuń', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _showDetailsDialog(context, zgloszenie);
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    _showZgloszenieDialog(context, null);
  }

  void _showEditDialog(BuildContext context, ZgloszenieModel zgloszenie) {
    _showZgloszenieDialog(context, zgloszenie);
  }

  void _showZgloszenieDialog(BuildContext context, ZgloszenieModel? zgloszenie) {
    final tytulController = TextEditingController(text: zgloszenie?.tytul ?? '');
    final opisController = TextEditingController(text: zgloszenie?.opis ?? '');
    final typController = TextEditingController(text: zgloszenie?.typ ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zgloszenie == null ? 'Nowe zgłoszenie' : 'Edytuj zgłoszenie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tytulController,
              decoration: const InputDecoration(
                labelText: 'Tytuł',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: opisController,
              decoration: const InputDecoration(
                labelText: 'Opis',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typController,
              decoration: const InputDecoration(
                labelText: 'Typ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tytulController.text.isNotEmpty && opisController.text.isNotEmpty) {
                final authState = Provider.of<AuthStateNotifier>(context, listen: false);
                final newZgloszenie = ZgloszenieModel(
                  id: zgloszenie?.id,
                  tytul: tytulController.text,
                  opis: opisController.text,
                  typ: typController.text.isEmpty ? null : typController.text,
                  imie: authState.userSession?.username.split(' ').first,
                  nazwisko: authState.userSession?.username.split(' ').skip(1).join(' '),
                );

                bool success;
                if (zgloszenie == null) {
                  success = await _zgloszenieProvider.createZgloszenie(newZgloszenie);
                } else {
                  success = await _zgloszenieProvider.updateZgloszenie(zgloszenie.id!, newZgloszenie);
                }

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(zgloszenie == null 
                        ? 'Zgłoszenie zostało utworzone' 
                        : 'Zgłoszenie zostało zaktualizowane'
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(zgloszenie == null ? 'Utwórz' : 'Zapisz'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, ZgloszenieModel zgloszenie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zgloszenie.tytul),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opis: ${zgloszenie.opis}'),
            if (zgloszenie.typ != null) Text('Typ: ${zgloszenie.typ}'),
            if (zgloszenie.status != null) Text('Status: ${zgloszenie.status}'),
            if (zgloszenie.imie != null || zgloszenie.nazwisko != null)
              Text('Zgłaszający: ${zgloszenie.imie ?? ''} ${zgloszenie.nazwisko ?? ''}'),
            if (zgloszenie.maszyna != null) Text('Maszyna: ${zgloszenie.maszyna}'),
            if (zgloszenie.dataUtworzenia != null)
              Text('Data utworzenia: ${zgloszenie.dataUtworzenia!.toLocal().toString().split('.')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ZgloszenieModel zgloszenie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń zgłoszenie'),
        content: Text('Czy na pewno chcesz usunąć zgłoszenie "${zgloszenie.tytul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await _zgloszenieProvider.deleteZgloszenie(zgloszenie.id!);
              if (success && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Zgłoszenie zostało usunięte')),
                );
              }
            },
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }
}