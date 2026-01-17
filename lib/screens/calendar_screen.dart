import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/todo_item.dart';
import 'todo_list_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<TodoItem>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    final allDates = await _dbHelper.getAllTodoListDates();
    final events = <DateTime, List<TodoItem>>{};
    
    for (final dateString in allDates) {
      final date = DateTime.parse(dateString);
      final todoList = await _dbHelper.getOrCreateTodoList(dateString);
      final todoItems = await _dbHelper.getTodoItems(todoList.id!);
      
      if (todoItems.isNotEmpty) {
        events[DateTime(date.year, date.month, date.day)] = todoItems;
      }
    }
    
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  List<TodoItem> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  bool _hasEvents(DateTime day) {
    return _getEventsForDay(day).isNotEmpty;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    
    // Navigate to the todo list for selected date
    final dateString = DateFormat('yyyy-MM-dd').format(selectedDay);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoListScreen(
          title: _formatDateForTitle(selectedDay),
          dateString: dateString,
        ),
      ),
    ).then((_) => _loadEvents()); // Refresh events when returning
  }

  String _formatDateForTitle(DateTime date) {
    final today = DateTime.now();
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateToCheck.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else if (dateToCheck.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
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
          'Calendar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () => _loadEvents(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Month header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDay),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                
                // Calendar grid
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildCalendarGrid(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    
    final days = <Widget>[];
    
    // Add weekday headers
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (final weekday in weekdays) {
      days.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              weekday,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }
    
    // Add empty cells for days before month starts
    for (int i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox());
    }
    
    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
      final hasEvents = _hasEvents(currentDate);
      final isSelected = _isSameDay(currentDate, _selectedDay);
      final isToday = _isSameDay(currentDate, DateTime.now());
      
      days.add(
        GestureDetector(
          onTap: () => _onDaySelected(currentDate, currentDate),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : hasEvents
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : isToday
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) => days[index],
    );
  }

  bool _isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
           day1.month == day2.month &&
           day1.day == day2.day;
  }
}
