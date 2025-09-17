import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/zgloszenia_repository.dart';
import '../data/zgloszenie_model.dart';
import '../../../common_widgets/loading_indicator.dart';
import '../../../common_widgets/error_view.dart';
import '../../../app_router.dart';

class ZgloszenieFormScreen extends ConsumerStatefulWidget {
  final int? id; // null for create, non-null for edit

  const ZgloszenieFormScreen({
    super.key,
    this.id,
  });

  @override
  ConsumerState<ZgloszenieFormScreen> createState() => _ZgloszenieFormScreenState();
}

class _ZgloszenieFormScreenState extends ConsumerState<ZgloszenieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imieController = TextEditingController();
  final _nazwiskoController = TextEditingController();
  final _tytulController = TextEditingController();
  final _opisController = TextEditingController();
  
  String _selectedTyp = 'AWARIA';
  String _selectedPriorytet = 'NORMALNY';
  DateTime? _selectedDateTime;
  bool _isLoading = false;
  Zgloszenie? _existingZgloszenie;

  final List<String> _typOptions = ['AWARIA', 'SERWIS', 'KONSERWACJA', 'INNE'];
  final List<String> _priorytetOptions = ['NISKI', 'NORMALNY', 'WYSOKI', 'KRYTYCZNY'];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadExistingZgloszenie();
    }
  }

  @override
  void dispose() {
    _imieController.dispose();
    _nazwiskoController.dispose();
    _tytulController.dispose();
    _opisController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingZgloszenie() async {
    setState(() => _isLoading = true);
    
    try {
      final repository = ref.read(zgloszeniaRepositoryProvider);
      final zgloszenie = await repository.fetch(widget.id!);
      
      setState(() {
        _existingZgloszenie = zgloszenie;
        _imieController.text = zgloszenie.imie;
        _nazwiskoController.text = zgloszenie.nazwisko;
        _tytulController.text = zgloszenie.tytul ?? '';
        _opisController.text = zgloszenie.opis;
        _selectedTyp = zgloszenie.typ;
        _selectedPriorytet = zgloszenie.priorytet ?? 'NORMALNY';
        _selectedDateTime = zgloszenie.dataGodzina;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load issue: ${_getErrorMessage(error)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Issue' : 'New Issue'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _submitForm,
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
        ],
      ),
      body: _isLoading
          ? LoadingIndicator(
              message: isEdit ? 'Loading issue...' : 'Saving...',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoCard(),
                    const SizedBox(height: 16),
                    _buildDetailsCard(),
                    const SizedBox(height: 16),
                    _buildDescriptionCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isEdit ? 'Save Changes' : 'Create Issue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imieController,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nazwiskoController,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tytulController,
              decoration: const InputDecoration(
                labelText: 'Issue Title',
                prefixIcon: Icon(Icons.title),
                helperText: 'Optional - will auto-generate if empty',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issue Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTyp,
              decoration: const InputDecoration(
                labelText: 'Issue Type *',
                prefixIcon: Icon(Icons.category),
              ),
              items: _typOptions.map((String typ) {
                return DropdownMenuItem<String>(
                  value: typ,
                  child: Text(_getTypDisplayName(typ)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedTyp = newValue);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriorytet,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: _priorytetOptions.map((String priorytet) {
                return DropdownMenuItem<String>(
                  value: priorytet,
                  child: Text(_getPriorytetDisplayName(priorytet)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedPriorytet = newValue);
                }
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Issue Date & Time',
                  prefixIcon: Icon(Icons.access_time),
                  helperText: 'Optional - current time will be used if empty',
                ),
                child: Text(
                  _selectedDateTime != null
                      ? _formatDateTime(_selectedDateTime!)
                      : 'Select date and time',
                  style: _selectedDateTime != null
                      ? null
                      : TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _opisController,
              decoration: const InputDecoration(
                labelText: 'Issue Description *',
                prefixIcon: Icon(Icons.description),
                helperText: 'Provide detailed description of the issue',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter issue description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(zgloszeniaRepositoryProvider);
      
      if (widget.id != null) {
        // Update existing
        final updateRequest = ZgloszenieUpdateRequest(
          imie: _imieController.text.trim(),
          nazwisko: _nazwiskoController.text.trim(),
          tytul: _tytulController.text.trim().isNotEmpty ? _tytulController.text.trim() : null,
          typ: _selectedTyp,
          priorytet: _selectedPriorytet,
          opis: _opisController.text.trim(),
          dataGodzina: _selectedDateTime,
        );
        
        await repository.update(widget.id!, updateRequest);
      } else {
        // Create new
        final createRequest = ZgloszenieCreateRequest(
          imie: _imieController.text.trim(),
          nazwisko: _nazwiskoController.text.trim(),
          tytul: _tytulController.text.trim().isNotEmpty ? _tytulController.text.trim() : null,
          typ: _selectedTyp,
          priorytet: _selectedPriorytet,
          opis: _opisController.text.trim(),
          dataGodzina: _selectedDateTime,
        );
        
        await repository.create(createRequest);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.id != null ? 'Issue updated successfully' : 'Issue created successfully'),
          ),
        );
        context.go(AppRoutes.zgloszenia);
      }
    } catch (error) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.id != null ? 'update' : 'create'} issue: ${_getErrorMessage(error)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getTypDisplayName(String typ) {
    switch (typ) {
      case 'AWARIA':
        return 'Breakdown';
      case 'SERWIS':
        return 'Service';
      case 'KONSERWACJA':
        return 'Maintenance';
      case 'INNE':
        return 'Other';
      default:
        return typ;
    }
  }

  String _getPriorytetDisplayName(String priorytet) {
    switch (priorytet) {
      case 'NISKI':
        return 'Low';
      case 'NORMALNY':
        return 'Normal';
      case 'WYSOKI':
        return 'High';
      case 'KRYTYCZNY':
        return 'Critical';
      default:
        return priorytet;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getErrorMessage(Object error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is UnauthorizedException) {
      return 'Authentication required. Please log in again.';
    } else if (error is ForbiddenException) {
      return 'You do not have permission to perform this action.';
    } else if (error is ApiException) {
      return error.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}