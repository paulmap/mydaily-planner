import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../services/pdf_export_service.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';

class DateListScreen extends StatefulWidget {
  const DateListScreen({super.key});

  @override
  State<DateListScreen> createState() => _DateListScreenState();
}

class _DateListScreenState extends State<DateListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _dates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllDates();
  }

  Future<void> _loadAllDates() async {
    setState(() => _isLoading = true);
    try {
      final dates = await _dbHelper.getAllTodoListDates();
      setState(() {
        _dates = dates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dates: $e')),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck.isAtSameMomentAs(today)) {
      return 'Today (${DateFormat('MMM d, yyyy').format(date)})';
    } else if (dateToCheck.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday (${DateFormat('MMM d, yyyy').format(date)})';
    } else if (dateToCheck.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow (${DateFormat('MMM d, yyyy').format(date)})';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    }
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (startDate == null) return;

    final endDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: startDate,
      lastDate: DateTime.now(),
    );

    if (endDate == null) return;

    final fileName = 'tasks_${DateFormat('yyyy-MM-dd').format(startDate)}_to_${DateFormat('yyyy-MM-dd').format(endDate)}.pdf';

    try {
      await PdfExportService.exportTasksToPdf(
        startDate: startDate,
        endDate: endDate,
        fileName: fileName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'All Lists',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export_all') {
                await _showExportDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'export_all',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No lists yet!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by creating today\'s list.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final dateString = _dates[index];
                    final date = DateTime.parse(dateString);
                    final isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isToday 
                            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isToday
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_month,
                            color: isToday
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          _formatDate(dateString),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Created on ${DateFormat('MMM d, yyyy').format(date)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpecificDateTodoListScreen(date: dateString),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class SpecificDateTodoListScreen extends StatefulWidget {
  final String date;

  const SpecificDateTodoListScreen({super.key, required this.date});

  @override
  State<SpecificDateTodoListScreen> createState() => _SpecificDateTodoListScreenState();
}

class _SpecificDateTodoListScreenState extends State<SpecificDateTodoListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late TodoList _currentTodoList;
  List<TodoItem> _todoItems = [];
  bool _isLoading = true;
  final TextEditingController _itemController = TextEditingController();
  final Map<int, TextEditingController> _editingControllers = {};
  final Set<int> _editingItems = {};

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    setState(() => _isLoading = true);
    try {
      final todoList = await _dbHelper.getOrCreateTodoList(widget.date);
      final items = await _dbHelper.getTodoItems(todoList.id!);
      
      setState(() {
        _currentTodoList = todoList;
        _todoItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading todo list: $e')),
        );
      }
    }
  }

  Future<void> _addTodoItem() async {
    if (_itemController.text.trim().isEmpty) return;

    try {
      final newItem = TodoItem(
        listId: _currentTodoList.id!,
        title: _itemController.text.trim(),
        createdAt: DateTime.now(),
      );
      
      await _dbHelper.insertTodoItem(newItem);
      _itemController.clear();
      await _loadTodoList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  Future<void> _toggleTodoItem(TodoItem item) async {
    try {
      final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
      await _dbHelper.updateTodoItem(updatedItem);
      await _loadTodoList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  Future<void> _deleteTodoItem(int id) async {
    try {
      await _dbHelper.deleteTodoItem(id);
      await _loadTodoList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }

  Future<void> _updateTodoItem(TodoItem item, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    
    try {
      final updatedItem = item.copyWith(title: newTitle.trim());
      await _dbHelper.updateTodoItem(updatedItem);
      await _loadTodoList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  void _startEditing(TodoItem item) {
    setState(() {
      _editingItems.add(item.id!);
      _editingControllers[item.id!] = TextEditingController(text: item.title);
    });
  }

  void _cancelEditing(int itemId) {
    setState(() {
      _editingItems.remove(itemId);
      _editingControllers[itemId]?.dispose();
      _editingControllers.remove(itemId);
    });
  }

  void _saveEditing(TodoItem item) {
    final controller = _editingControllers[item.id!];
    if (controller != null) {
      _updateTodoItem(item, controller.text);
      _cancelEditing(item.id!);
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    for (final controller in _editingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.date);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE').format(date),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              DateFormat('MMMM d, yyyy').format(date),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_todoItems.where((item) => item.isCompleted).length}/${_todoItems.length}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.task_alt,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No tasks yet!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first task below to get started.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: _todoItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No tasks yet!\nAdd your first task below.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _todoItems.length,
                          itemBuilder: (context, index) {
                            final item = _todoItems[index];
                            final isEditing = _editingItems.contains(item.id!);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Checkbox(
                                  value: item.isCompleted,
                                  onChanged: (value) => _toggleTodoItem(item),
                                ),
                                title: isEditing
                                    ? TextField(
                                        controller: _editingControllers[item.id!],
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          hintText: 'Edit task',
                                        ),
                                        onSubmitted: (_) => _saveEditing(item),
                                      )
                                    : GestureDetector(
                                        onTap: () => _startEditing(item),
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            decoration: item.isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            color: item.isCompleted
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isEditing) ...[
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _saveEditing(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.orange),
                                        onPressed: () => _cancelEditing(item.id!),
                                      ),
                                    ] else ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _startEditing(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteTodoItem(item.id!),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemController,
                          decoration: const InputDecoration(
                            labelText: 'Add new task',
                            border: OutlineInputBorder(),
                            hintText: 'Enter task description',
                          ),
                          onSubmitted: (_) => _addTodoItem(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: _addTodoItem,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
