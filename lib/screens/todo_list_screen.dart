import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';

class TodoListScreen extends StatefulWidget {
  final String title;
  final String dateString;
  
  const TodoListScreen({
    super.key,
    required this.title,
    required this.dateString,
  });

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late TodoList _currentTodoList;
  List<TodoItem> _todoItems = [];
  bool _isLoading = true;
  final TextEditingController _itemController = TextEditingController();
  final Map<int, TextEditingController> _editingControllers = {};
  final Set<int> _editingItems = {};

  bool get _isPastDate {
    final selectedDate = DateTime.parse(widget.dateString);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return selectedDateOnly.isBefore(todayDate);
  }

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    setState(() => _isLoading = true);
    try {
      TodoList? todoList;
      
      if (_isPastDate) {
        // For past dates, only get existing lists, don't create new ones
        final existingLists = await _dbHelper.getAllTodoListDates();
        if (existingLists.contains(widget.dateString)) {
          todoList = await _dbHelper.getOrCreateTodoList(widget.dateString);
        }
      } else {
        // For today and future dates, create list if it doesn't exist
        todoList = await _dbHelper.getOrCreateTodoList(widget.dateString);
      }
      
      final items = todoList != null ? await _dbHelper.getTodoItems(todoList.id!) : <TodoItem>[];
      
      setState(() {
        _currentTodoList = todoList ?? TodoList(
          id: -1,
          date: widget.dateString,
          createdAt: DateTime.now(),
        );
        _todoItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  Future<void> _addTodoItem() async {
    if (_itemController.text.trim().isEmpty) return;
    
    // Prevent adding tasks to past dates
    if (_isPastDate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot add tasks to past dates'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

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

  Future<void> _updateTodoItem(TodoItem item, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    
    // Prevent editing task titles for past dates
    if (_isPastDate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot edit tasks for past dates'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
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

  Future<void> _deleteTodoItem(int id) async {
    // Prevent deleting tasks for past dates
    if (_isPastDate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete tasks for past dates'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (_isPastDate) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Read Only',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              widget.dateString == DateFormat('yyyy-MM-dd').format(DateTime.now())
                  ? DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now())
                  : DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(widget.dateString)),
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
                    _isPastDate ? 'No tasks for this date' : 'No tasks yet!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPastDate 
                        ? 'Tasks cannot be added to past dates.'
                        : 'Add your first task below to get started.',
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
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _todoItems.length,
                    itemBuilder: (context, index) {
                      final item = _todoItems[index];
                      final isEditing = _editingItems.contains(item.id!);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: item.isCompleted,
                                  onChanged: (value) => _toggleTodoItem(item),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: isEditing
                                    ? TextField(
                                        controller: _editingControllers[item.id!],
                                        autofocus: true,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context).colorScheme.primary,
                                              width: 2,
                                            ),
                                          ),
                                          hintText: 'Edit task',
                                        ),
                                        onSubmitted: (_) => _saveEditing(item),
                                      )
                                    : GestureDetector(
                                        onTap: _isPastDate ? null : () => _startEditing(item),
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            decoration: item.isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            color: item.isCompleted
                                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                                : _isPastDate
                                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                                                    : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isEditing) ...[
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green, size: 20),
                                      onPressed: () => _saveEditing(item),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.green.withOpacity(0.1),
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.orange, size: 20),
                                      onPressed: () => _cancelEditing(item.id!),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.orange.withOpacity(0.1),
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                  ] else ...[
                                    if (!_isPastDate) ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                        onPressed: () => _startEditing(item),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.blue.withOpacity(0.1),
                                          minimumSize: const Size(36, 36),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => _deleteTodoItem(item.id!),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red.withOpacity(0.1),
                                          minimumSize: const Size(36, 36),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Only show input area for today and future dates
                if (!_isPastDate) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                controller: _itemController,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Add a new task...',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                onSubmitted: (_) => _addTodoItem(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _addTodoItem,
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(56, 56),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
